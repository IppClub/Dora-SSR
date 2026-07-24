# Web IDE Git Client Task Tracker

This tracker breaks the Web IDE Git client design into implementation tasks. Keep it updated while working so CLI `/goal` sessions can resume from a concrete state.

Status values:

- Todo: not started
- Doing: currently being implemented
- Done: implemented and verified
- Blocked: waiting for a decision or dependency

## Phase 1: Backend Git Routes

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Done | Add `/git/run` route | Accept `repoPath`, `command`, optional auth selector/options, call engine `Git.run`, return `jobId`. | Route returns a valid job id for `git status`. |
| Done | Add `/git/status` route | Poll a running Git job and return decoded status data. | Running and done states can be read for a sample command. |
| Done | Add `/git/cancel` route | Cancel an active Git job by handle. | Long-running clone/fetch can be canceled without leaking the job. |
| Done | Add `/git/summary` route | Return repository state for the active project: is repo, current branch, remotes, last commit, clean/dirty. | Non-repo and repo project both return usable summary data. |
| Done | Add `/git/status-files` route | Return staged and unstaged file status grouped from `git status`. | Modified, added, deleted, and untracked files appear in correct sections. |
| Done | Add `/git/remotes` route | Return `git remote -v` data and route add/set-url/remove operations if needed. | First remote is available for default pull/push target. |
| Done | Add `/git/branches` route | Return local branches and current branch from `git branch`. | Current branch is detected; detached HEAD is handled. |
| Done | Add `/git/history` route | Return recent commits from `git log -n <limit>`. | History list shows short hash, subject, author/date when available. |

## Phase 2: Frontend Shell

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Doing | Add Git tab to `ProjectWorkspacePanel.tsx` | Extend workspace view state with `git`; preserve existing Dora/Upload behavior. | Git tab appears and switching tabs does not break Agent or Upload. |
| Doing | Create `GitPanel` component | Add main left-right layout, header summary area, and bottom task status area. | Panel renders inside current workspace height without overflow glitches. |
| Doing | Add repository setup state | Show Init and Clone actions when active project is not a Git repo. | Non-repo project shows setup UI; repo project shows normal UI. |
| Doing | Implement task status footer | Show current command, progress/message/result, and cancel action. | Footer updates during a running job and clears or settles after completion. |

## Phase 3: Repository Setup

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Done | Implement Init flow | Run `git init` for current project path and refresh summary. | Current folder becomes a Git repo and Git panel switches to normal state. |
| Done | Implement Clone form | URL, optional branch, optional target dir, optional depth if kept in UI. | Valid clone command starts and reports progress. |
| Done | Validate clone target | UI blocks existing non-empty target directories; backend also validates. | Existing non-empty folder cannot be overwritten by clone. |
| Doing | Open cloned project | On successful clone, call existing project-opening flow with cloned folder path. | Web IDE opens cloned project and keeps Git tab context. |

## Phase 4: File Changes Workflow

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Doing | Parse status files | Convert backend status data into staged and unstaged file models. | Same file can appear in both sections when index and worktree differ. |
| Doing | Build file tree data | Group files by directory, include status badges and file-type icons. | Nested folders render correctly for staged and unstaged sections. |
| Doing | Implement selection | Support single selection and Shift multi-selection per section. | Multi-selected file operations apply to every selected file. |
| Doing | Implement directory operations | Stage, unstage, and discard recurse through selected directory entries. | Directory selection applies to all changed descendants. |
| Done | Implement stage | Run `git add <path...>` for selected unstaged files. | Files move from unstaged to staged after refresh. |
| Done | Implement unstage | Run `git restore --staged <path...>` for selected staged files. | Files move from staged to unstaged after refresh. |
| Done | Implement discard | Confirm, then run `git restore --worktree <path...>` or matching supported command. | Modified files are reverted only after confirmation. |
| Done | Handle deleted/untracked cases | Use supported Git commands for deleted and untracked file cleanup. | Deleted and untracked files can be staged and discarded correctly. |

## Phase 5: Commit And Sync

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Doing | Add commit controls | Message input, staged-count summary, commit button. | Commit is disabled until message and staged changes exist. |
| Doing | Add Git Profile use | Default author name/email from Git Profile settings. | Commit uses configured profile when present. |
| Done | Implement commit | Run `git commit -m <msg>` with optional author fields. | New commit appears in history; staged list becomes clean. |
| Done | Implement pull dialog | Default remote = first `git remote -v` remote; branch = current branch. | `git pull <remote> <branch>` runs explicitly. |
| Done | Implement push dialog | Default remote = first `git remote -v` remote; branch = current branch. | `git push <remote> <branch>` runs explicitly. |
| Doing | Handle missing remote/branch | Prompt when no remote exists or HEAD is detached. | Pull/push cannot run with missing target values. |

## Phase 6: Settings And Credentials

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Doing | Add Git Settings dialog | Single dialog with Credentials and Profile tabs. | Dialog opens from Git panel and preserves tab state while open. |
| Done | Implement Git Profile storage | Store author name/email using engine-side data storage. | Profile persists after Web IDE reload. |
| Done | Implement credential list by host | Store credentials globally by host, with multiple entries per host. | Multiple credentials for `github.com` can coexist. |
| Done | Implement credential selection | One credential auto-selects; multiple credentials prompt each command. | Auth-required command receives selected credential. |
| Done | Avoid frontend credential persistence | Do not store secrets in browser localStorage/sessionStorage. | Browser storage does not contain credential secrets. |

## Phase 7: Secondary Repository Operations

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Done | Branch list/create/delete | Use supported `git branch` commands. | Branches refresh after create/delete. |
| Done | Tag list/create/delete | Use supported `git tag` commands. | Tags refresh after create/delete. |
| Done | Remote list/add/set-url/remove | Use supported `git remote` commands. | Remote UI reflects each operation. |
| Doing | History checkout/reset actions | Provide guarded checkout/reset operations. | Destructive actions show command and confirmation first. |
| Done | Move file action | Use supported single-file `git mv <from> <to>` if exposed in UI. | Single file move updates status correctly. |

## Phase 8: Verification

| Status | Task | Scope | Verification |
| --- | --- | --- | --- |
| Done | Run TypeScript checks | Validate changed Web IDE TypeScript. | Project check/build command passes or known unrelated failures are documented. |
| Done | Run Dora-side binding checks | Validate affected `.d.ts`, `.d.tl`, and Lua wrapper changes as available. | Parser/type checks pass or missing local tools are documented. |
| Doing | Local Web IDE smoke test | Open Web IDE and exercise Git tab against a sample repo. | Status, stage, commit, pull/push dialogs render and call routes. |
| Todo | Android smoke test | Exercise core Git UI path through Android command service if required. | At least `status`, `init`, and one async command complete on Android. |
| Todo | Regression check existing tabs | Verify Dora Agent and Upload tabs still work. | Existing tab behavior is unchanged. |

## Current Product Decisions

- Git tab is always visible.
- Non-repository projects show Init and Clone.
- Clone completion opens the cloned project folder.
- First version uses summary routes for normal UI workflows.
- `/git/run` remains the backend primitive and debugging route.
- Pull and push do not read or set upstream in the first version.
- Pull and push default to current branch plus first remote and run with explicit arguments.
- Credentials are grouped by host; multiple credentials for the same host are allowed.
- Git Profile is shared through Git Settings.
- Stage, unstage, and discard are whole-file operations.
- Directory stage, unstage, and discard recurse through changed descendants.
- Dangerous actions use a normal confirmation dialog and display the raw command.
- The panel shows only the current Git task status in a fixed bottom footer.
- Agent integration is out of scope for the first version.
