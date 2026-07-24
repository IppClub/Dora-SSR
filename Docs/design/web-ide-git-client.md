# Web IDE Git Client Design

## Background

Dora already exposes a high-level `Git.run(repoPath, command, callback, optionsJSON)` API backed by the Go Git runtime. The API runs Git work asynchronously and reports decoded status objects through callbacks. The next step is to add a graphical Git client to the Web IDE so users can perform common repository workflows without manually writing Git commands.

The first UI entry should live in `Tools/dora-dora/src/ProjectWorkspacePanel.tsx`. That panel currently switches between the Dora Agent view and the upload view. Add a third `Git` tab beside those tabs and keep the Git client scoped to the active project root.

## Goals

- Provide a project-scoped graphical Git client for common workflows.
- Keep the UI command surface simple while still mapping clearly to supported `Git.run` commands.
- Store authentication information by Git hosting domain so later commands can run without repeatedly entering credentials.
- Keep long-running Git operations asynchronous and visible to the user.
- Avoid exposing the low-level Git runtime details directly to the Web IDE UI.

## Non-Goals

- Do not implement a full native Git CLI replacement in the first version.
- Do not implement complex merge or rebase UI until conflict behavior is designed.
- Do not store credentials in browser `localStorage`.
- Do not let the frontend run arbitrary shell syntax. All commands must go through the engine Git command parser.

## Placement

`ProjectWorkspacePanel.tsx` should evolve from:

```ts
type WorkspaceView = "agent" | "upload";
```

to:

```ts
type WorkspaceView = "agent" | "upload" | "git";
```

The header tab order should be:

1. Dora, when an Agent session exists.
2. Upload.
3. Git.

The Git tab should render a new component, tentatively `GitPanel`, with:

```ts
interface GitPanelProps {
	projectRoot: string;
	displayPath?: string;
	height: number;
	addAlert?: (msg: string, type: "success" | "info" | "warning" | "error") => void;
	onOpenFile?: (filePath: string) => void;
	onOpenProject?: (projectPath: string) => void;
}
```

The Git tab is always visible when `ProjectWorkspacePanel` is shown. If the current project path is not a Git repository, the Git panel should switch to a repository setup state and show both `Init` and `Clone` actions.

## UI Layout

The Git tab should use a dense operational layout rather than a landing-page style layout. The main workspace uses a left-right split:

- Left pane: file changes, staged/unstaged trees, commit controls, and current task status.
- Right pane: repository summary, history, branches, tags, remotes, and Git Settings access.

The left pane is the primary workflow area. The right pane is the inspection and repository-management area.

### Header Row

- Repository state summary:
  - current branch
  - clean or changed status
  - remote name and URL, when available
  - last commit short hash and subject, when available
- Action buttons:
  - Refresh
  - Pull
  - Push
  - Clone or Init, when the project is not a repository
  - Git Settings, opens a shared settings dialog for credentials and profile

### Main Sections

- Left pane: Changes and Commit
  - split the file tree vertically into `Unstaged` and `Staged` sections
  - each section uses a tree view grouped by directory
  - support single selection and Shift multi-selection
  - use the reference image interaction model: selected rows and directories are highlighted as a contiguous region
  - stage, unstage, and discard buttons are outside the tree, in each section header
  - `Unstaged` section actions: `Stage`, `Discard`, and a weak `More` menu
  - `Staged` section actions: `Unstage` and a weak `More` menu
  - clicking a file opens it through existing Web IDE file-opening behavior
  - selecting a directory and running stage, unstage, or discard applies the operation recursively to all files under that directory
  - discard supports both single-file and multi-file selection and must show a confirmation dialog
  - commit message input is integrated below the staged/unstaged sections rather than being a separate page section
  - author name and email come from Git Profile by default
  - per-commit author override can be added later if needed
  - Commit button is enabled only when there are staged changes and a non-empty message
  - optional `commit -a` toggle can be added later; the first workflow should encourage explicit staging

- Right pane: Repository Summary
  - current branch
  - clean or changed status
  - default pull and push target, using the first remote plus current branch when available
  - remote name and URL, when available
  - last commit short hash and subject, when available

- Right pane: History
  - recent commits from `git log -n <limit>`
  - checkout/reset controls should be present but guarded by confirmation
  - reset hard should use the same normal confirmation dialog as other destructive commands

- Right pane: Branches and Tags
  - list local branches
  - create branch
  - delete branch
  - list and create tags
  - delete tags

- Right pane: Remotes
  - list remotes
  - add remote
  - set URL
  - remove remote

- Right pane: Git Settings
  - single settings dialog with `Credentials` and `Profile` tabs
  - no separate Auth and Profile dialogs

### File Tree Visual Style

The file tree should follow the supplied reference image:

- dark Web IDE background
- directory rows with disclosure arrows and folder icons
- file rows with small status badges and file-type icons
- semantic Git status colors only:
  - added: green
  - modified: yellow or orange
  - deleted: red
  - untracked: green plus marker
  - conflict or warning: orange or red
- selected rows use a strong accent background
- text remains high-contrast and compact
- status is expressed with color plus icon or badge, not color alone

### Repository Setup State

When the current project path is not a Git repository:

- Show `Init Repository` for creating a repository in the current project folder.
- Show `Clone Repository` for cloning a repository into a new folder.
- Before clone starts, block target directories that already exist and are non-empty.
- The backend must still validate the target path because UI checks can race or be bypassed.
- After clone completes, automatically open the cloned project folder through the existing project-opening flow.
- Keep the Git tab visible after opening the new project so the user lands directly in the repository context.

Clone should use `repoPath` as the parent directory and the optional `dir` argument as the new repository folder name. If `dir` is omitted, the backend should use the Git runtime URL-derived folder name and return the resulting path from the clone status data.

## Backend API Shape

The Web IDE should not call `Git.run` directly from browser code. Add WebServer routes that accept structured requests and call engine-side `Git.run`.

The first version should use summary routes for normal UI workflows. These routes keep command composition and result parsing on the backend while still using `Git.run` internally:

- `POST /git/summary`
- `POST /git/status-files`
- `POST /git/history`
- `POST /git/remotes`
- `POST /git/branches`
- `POST /git/run`
- `POST /git/status`
- `POST /git/cancel`

`/git/run` is still useful as the low-level primitive and debugging escape hatch, but normal UI panels should prefer the summary routes.

Low-level API:

```ts
POST /git/run
{
  "repoPath": "/project/path",
  "command": "status",
  "authDomain": "github.com" // optional
}

{
  "success": true,
  "jobId": 12
}
```

```ts
POST /git/status
{
  "jobId": 12
}

{
  "success": true,
  "status": {
    "id": 12,
    "state": "done",
    "kind": "status",
    "repoPath": "/project/path",
    "progress": 1,
    "message": "git status completed",
    "data": {
      "clean": false,
      "files": [
        {"path": "main.lua", "staging": " ", "worktree": "M"}
      ]
    }
  }
}
```

```ts
POST /git/cancel
{
  "jobId": 12
}
```

Composite routes should be implemented through `Git.run` internally. They reduce UI round trips and centralize parsing of command results.

## Credential Manager

Authentication should be configured in an `Auth` dialog in the Git tab.

Credential records:

```ts
interface GitCredential {
	id: string;
	host: string;
	label: string;
	type: "basic" | "token";
	username?: string;
	password?: string;
	token?: string;
}
```

Storage rules:

- Store credentials engine-side using the engine database or file data storage interface.
- Group credentials globally by normalized host, for example `github.com`, `gitcode.com`, or a private Git server host.
- Allow multiple credential records under the same host.
- Each record should have a user-facing label, such as `Personal`, `Work`, or the account name.
- The frontend should never persist secrets in `localStorage`.
- The frontend may display only metadata, such as host, label, type, username, and last used time.
- When running `clone`, `ls-remote`, `fetch`, `pull`, or `push`, the backend resolves the command URL or remote URL to a host and injects `optionsJSON.auth`.

Credential selection rules:

- If no credential exists for the resolved host, run without auth or prompt the user to add one when the command fails with auth-related errors.
- If exactly one credential exists for the resolved host, use it automatically.
- If multiple credentials exist for the resolved host, show a credential selection dialog before running the command.
- The selection dialog should show `label`, `username`, and `type`, but never reveal password or token values.
- Remembering the last selected credential per repository can be considered later, but the first version should require selection whenever multiple credentials match the host.

Suggested routes:

```ts
POST /git/auth/list
POST /git/auth/save
POST /git/auth/delete
POST /git/auth/test
```

`/git/auth/test` can run `git ls-remote <url>` with the selected credential.

## Git Profile

Commit author information should be configured through a Git Profile dialog in the Git tab.

```ts
interface GitProfile {
	name: string;
	email: string;
}
```

Storage rules:

- Store the profile engine-side.
- Use the profile to fill `--author-name` and `--author-email` for `git commit`.
- If no profile is configured, prompt the user before the first commit.
- Do not rely on the Go Git runtime default `Dora <dora@example.com>` for user-facing commits except as a last-resort fallback.

Suggested routes:

```ts
POST /git/profile/get
POST /git/profile/save
```

## Command Mapping

The UI should map controls to the supported Git commands:

- Clone: `git clone <url> [dir] [-b <branch>] [--depth <n>]`
- Init: `git init`
- Status: `git status`
- Stage: `git add <path...>` or `git add -A`
- Unstage: `git restore --staged <path...>`
- Remove: `git rm <path...>`
- Commit: `git commit -m <msg> [--author-name <name>] [--author-email <email>]`
- Pull: `git pull [remote] [branch] [-f]`
- Fetch: `git fetch [remote] [-p] [--depth <n>]`
- Push: `git push [remote] [branch] [-f]`
- Log: `git log -n <limit>`
- Checkout: `git checkout <branch-or-commit>`
- Create branch: `git branch <name>`
- Delete branch: `git branch -d <name>`
- Tags: `git tag`, `git tag <name>`, `git tag -a <name> -m <msg>`, `git tag -d <name>`
- Remotes: `git remote -v`, `git remote add <name> <url>`, `git remote set-url <name> <url>`, `git remote remove <name>`
- Move: `git mv <from> <to>`
- Reset: `git reset --soft|--mixed|--hard <commit> --confirm`
- Clean: `git clean -f`

Push and pull default selection:

- Do not read or set upstream in the first version.
- Default `remote` to the first entry from `git remote -v`.
- Default `branch` to the current branch from `git branch`.
- Run pull and push with explicit arguments: `git pull <remote> <branch>` and `git push <remote> <branch>`.
- If there is no remote, prompt the user to add or select a remote before running pull or push.
- If the repository is in detached HEAD state and has no current branch, prompt the user to choose or enter a branch.
- If multiple remotes exist, preselect the first remote but allow the user to change it in the pull or push dialog.

File staging:

- The first version supports whole-file stage and unstage only.
- Hunk-level staging is deferred.
- Tree selection supports both files and directories.
- Directory operations expand to all changed files under that directory.
- Shift multi-selection can operate across files and directories in the same tree section.

Destructive commands are allowed but must use a normal confirmation dialog:

- `reset --hard`
- `clean -f`
- `checkout -f`
- force pull or force push
- unstaged discard for one or more files
- unstaged discard for a directory

The confirmation dialog should clearly show the command and affected repository path. Extra typed confirmation is not required for the first version.

Dangerous or low-frequency operations should be visually weakened by placing them in a `More` menu instead of the main action row. This includes force operations, reset, and clean. Discard remains an explicit `Unstaged` section action because it is part of the primary file-change workflow, but it must still show a confirmation dialog.

## Job State Model

Frontend state should track active jobs by returned `jobId`:

```ts
interface GitJobViewState {
	jobId: number;
	command: string;
	startedAt: number;
	status?: GitStatus;
}
```

Polling rules:

- Poll until `state` is `done`, `error`, or `canceled`.
- Show `message` and `progress` while running.
- On terminal state, refresh repository summary.
- Cancel should call `/git/cancel` and keep the terminal status visible until the user dismisses it.

The Git panel should show only the current task. Put the task state in a fixed footer at the bottom of the Git panel, with:

- command label
- raw Git command string
- current status message
- progress bar when `progress` is available
- cancel button while running
- terminal success or error message after completion

Do not add a full task history list in the first version.

## First Implementation Phase

Phase 1 should focus on safe read and simple write operations:

1. Add Git tab to `ProjectWorkspacePanel.tsx`.
2. Add `GitPanel`.
3. Add WebServer routes for `git run`, `git status`, and `git cancel`.
4. Implement repository summary:
   - `status`
   - `branch`
   - `remote -v`
   - `log -n 20`
5. Implement stage, unstage, commit, pull, and push.
6. Add credential manager with global host-based records.
7. Add Git Profile settings for commit author name and email.
8. Implement non-repository setup state with `Init` and `Clone`.
9. After clone completes, open the cloned project folder.

## Second Implementation Phase

Phase 2 can add repository management:

1. Branch create/delete and checkout.
2. Tag create/delete.
3. Remote add/set-url/remove.
4. File move through `git mv`.

## Deferred Features

- Merge UI.
- Conflict editor.
- Rebase.
- Stash.
- Submodule support.
- Visual diff viewer.

Merge should be deferred because the current Git command set does not expose conflict detection and resolution workflow in a UI-friendly way. Until merge is added, users can approximate simple fast-forward workflows with `fetch`, `checkout`, and `pull`, but true divergent-branch merge needs explicit conflict handling.

Agent integration is also deferred. The Git tab should be independent in the first version. Agent access to the same Git API can be designed later as a separate mechanism.

## Risks

- Credential leakage: keep secrets engine-side and never show full token values after saving.
- Destructive commands: require confirmation and avoid default force options.
- Long jobs: keep every Git operation asynchronous and cancelable.
- Path handling: all file paths in UI commands should be relative to `repoPath` and quoted when needed.
- Android behavior: preserve the current async Go Git job queue design and avoid UI-thread blocking.

## Confirmed Decisions

- The Git tab is always visible.
- Non-repository projects show both `Init` and `Clone`.
- Clone target directories that exist and are non-empty are blocked in the UI, with backend validation as a second guard.
- Clone completion automatically opens the cloned project folder.
- First-version UI workflows use summary routes; `/git/run` remains the backend primitive and debugging escape hatch.
- Credentials are global per host.
- The same host may have multiple credentials; one match is automatic, multiple matches require user selection.
- Pull and push default to the current branch plus the first remote.
- Pull and push always run with explicit remote and branch arguments in the first version.
- Commit author defaults come from Git Profile.
- Stage and unstage are whole-file only in the first version.
- The changes area uses two vertical tree sections: `Unstaged` and `Staged`.
- Tree rows support single selection and Shift multi-selection.
- Directory stage, unstage, and discard recursively apply to all changed files under the selected directory.
- File status uses semantic color plus icon or badge, following the supplied reference image.
- Destructive operations are allowed behind a normal confirmation dialog.
- Dangerous operations are visually weakened in a `More` menu.
- Git settings are combined into one dialog with `Credentials` and `Profile` tabs.
- The UI shows only the current task status and progress in a fixed bottom footer.
- Confirmation dialogs and task status display the raw Git command string.
- The Git tab is independent from Agent workflows in the first version.

## Technical Validation Results

- go-git v5.16.2 supports setting branch tracking config through `repo.Config()` and `repo.SetConfig(cfg)`, but the first Web IDE Git client version does not need upstream tracking.
- `config.Branch` exposes `Name`, `Remote`, and `Merge` fields. `Merge` should be `plumbing.NewBranchReferenceName(remoteBranch)` if upstream tracking is added later.
- A local verification wrote the expected `.git/config` section:
  - `[branch "main"]`
  - `remote = origin`
  - `merge = refs/heads/main`
- Current exported engine commands do not expose upstream data, so the first version uses `git remote -v` plus `git branch` instead.
