package gitjobs

import (
	"container/heap"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/config"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/format/index"
	"github.com/go-git/go-git/v5/plumbing/object"
	"github.com/go-git/go-git/v5/plumbing/transport"
	"github.com/go-git/go-git/v5/plumbing/transport/http"
	"github.com/go-git/go-git/v5/storage/memory"
)

const maxPreviewDiffBytes = 1024 * 1024

type commandRequest struct {
	repoPath   string
	command    string
	options    runOptions
	parsed     gitCommand
	resultData map[string]any
}

type runOptions struct {
	Auth gitAuth `json:"auth"`
}

type gitAuth struct {
	Type     string `json:"type"`
	Username string `json:"username"`
	Password string `json:"password"`
	Token    string `json:"token"`
}

type gitCommand struct {
	op          string
	url         string
	paths       []string
	remote      string
	branch      string
	target      string
	message     string
	authorName  string
	authorEmail string
	action      string
	depth       int
	limit       int
	force       bool
	all         bool
	allowEmpty  bool
	amend       bool
	bare        bool
	create      bool
	delete      bool
	staged      bool
	worktree    bool
	confirm     bool
	setUpstream bool
	resetMode   git.ResetMode
}

func StartRun(repoPath, command, optionsJSON string) int64 {
	repoPath = strings.TrimSpace(repoPath)
	command = strings.TrimSpace(command)
	if repoPath == "" {
		return createRejectedJob(repoPath, "run", "repo path is required")
	}
	if command == "" {
		return createRejectedJob(repoPath, "run", "git command is required")
	}
	var options runOptions
	if strings.TrimSpace(optionsJSON) != "" {
		if err := json.Unmarshal([]byte(optionsJSON), &options); err != nil {
			return createRejectedJob(repoPath, "run", fmt.Sprintf("invalid git options: %v", err))
		}
	}
	parsed, err := parseGitCommand(repoPath, command)
	if err != nil {
		return createRejectedJob(repoPath, "run", err.Error())
	}
	return startJob(parsed.op, repoPath, cloneRequest{
		path: repoPath,
		cmd: commandRequest{
			repoPath: repoPath,
			command:  command,
			options:  options,
			parsed:   parsed,
		},
	})
}

func parseGitCommand(repoPath, command string) (gitCommand, error) {
	args, err := splitGitCommand(command)
	if err != nil {
		return gitCommand{}, err
	}
	if len(args) == 0 {
		return gitCommand{}, errors.New("git command is required")
	}
	if args[0] == "git" {
		args = args[1:]
	}
	if len(args) == 0 {
		return gitCommand{}, errors.New("git subcommand is required")
	}
	if args[0] == "-C" || strings.HasPrefix(args[0], "-C") {
		return gitCommand{}, errors.New("git -C is not supported; use the repoPath argument")
	}
	switch args[0] {
	case "init":
		return parseInit(args[1:])
	case "clone":
		return parseClone(repoPath, args[1:])
	case "ls-remote":
		return parseLsRemote(args[1:])
	case "status":
		return gitCommand{op: "status"}, noExtraArgs("status", args[1:])
	case "diff":
		return parseDiff(args[1:])
	case "add":
		return parseAdd(args[1:])
	case "rm":
		return parseRm(args[1:])
	case "commit":
		return parseCommit(args[1:])
	case "pull":
		return parsePull(args[1:])
	case "fetch":
		return parseFetch(args[1:])
	case "push":
		return parsePush(args[1:])
	case "log":
		return parseLog(args[1:])
	case "checkout":
		return parseCheckout(args[1:])
	case "reset":
		return parseReset(args[1:])
	case "restore":
		return parseRestore(args[1:])
	case "clean":
		return parseClean(args[1:])
	case "branch":
		return parseBranch(args[1:])
	case "tag":
		return parseTag(args[1:])
	case "remote":
		return parseRemote(args[1:])
	case "mv":
		return parseMv(args[1:])
	default:
		return gitCommand{}, fmt.Errorf("unsupported git command %q", args[0])
	}
}

func splitGitCommand(command string) ([]string, error) {
	var args []string
	var b strings.Builder
	var quote rune
	escaped := false
	for _, r := range command {
		if escaped {
			b.WriteRune(r)
			escaped = false
			continue
		}
		if quote == 0 {
			switch r {
			case '\\':
				escaped = true
			case '\'', '"':
				quote = r
			case ' ', '\t', '\n', '\r':
				if b.Len() > 0 {
					args = append(args, b.String())
					b.Reset()
				}
			case ';', '|', '>', '<', '`', '$':
				return nil, fmt.Errorf("shell syntax %q is not supported", string(r))
			case '&':
				return nil, errors.New("shell syntax is not supported")
			default:
				b.WriteRune(r)
			}
			continue
		}
		if r == quote {
			quote = 0
			continue
		}
		if r == '\\' && quote == '"' {
			escaped = true
			continue
		}
		b.WriteRune(r)
	}
	if escaped {
		return nil, errors.New("unfinished escape sequence")
	}
	if quote != 0 {
		return nil, errors.New("unterminated quoted string")
	}
	if b.Len() > 0 {
		args = append(args, b.String())
	}
	return args, nil
}

func parseInit(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "init"}
	for _, arg := range args {
		switch arg {
		case "--bare":
			cmd.bare = true
		default:
			return cmd, fmt.Errorf("unsupported init option %q", arg)
		}
	}
	return cmd, nil
}

func parseClone(_ string, args []string) (gitCommand, error) {
	cmd := gitCommand{op: "clone"}
	for i := 0; i < len(args); i++ {
		arg := args[i]
		switch arg {
		case "--branch", "-b":
			i++
			if i >= len(args) {
				return cmd, errors.New("clone branch value is required")
			}
			cmd.branch = args[i]
		case "--depth":
			i++
			depth, err := parsePositiveInt(args, i, "clone depth")
			if err != nil {
				return cmd, err
			}
			cmd.depth = depth
		default:
			if strings.HasPrefix(arg, "-") {
				return cmd, fmt.Errorf("unsupported clone option %q", arg)
			}
			if cmd.url == "" {
				cmd.url = arg
			} else if cmd.target == "" {
				cmd.target = arg
			} else {
				return cmd, fmt.Errorf("unexpected clone argument %q", arg)
			}
		}
	}
	if cmd.url == "" {
		return cmd, errors.New("clone URL is required")
	}
	return cmd, nil
}

func parseLsRemote(args []string) (gitCommand, error) {
	if len(args) != 1 {
		return gitCommand{}, errors.New("ls-remote requires URL")
	}
	if strings.HasPrefix(args[0], "-") {
		return gitCommand{}, fmt.Errorf("unsupported ls-remote option %q", args[0])
	}
	return gitCommand{op: "ls-remote", url: args[0]}, nil
}

func parseDiff(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "diff"}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--cached", "--staged":
			cmd.staged = true
		case "--":
			cmd.paths = append(cmd.paths, args[i+1:]...)
			i = len(args)
		default:
			if strings.HasPrefix(args[i], "-") {
				return cmd, fmt.Errorf("unsupported diff option %q", args[i])
			}
			if cmd.target == "" && len(cmd.paths) == 0 && i+1 < len(args) && args[i+1] == "--" {
				cmd.target = args[i]
				continue
			}
			cmd.paths = append(cmd.paths, args[i])
		}
	}
	if len(cmd.paths) != 1 {
		return cmd, errors.New("diff requires exactly one path")
	}
	if err := validateRelativeGitPath(cmd.paths[0]); err != nil {
		return cmd, err
	}
	return cmd, nil
}

func parseAdd(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "add"}
	for _, arg := range args {
		switch arg {
		case "-A", "--all":
			cmd.all = true
		default:
			if strings.HasPrefix(arg, "-") {
				return cmd, fmt.Errorf("unsupported add option %q", arg)
			}
			cmd.paths = append(cmd.paths, arg)
		}
	}
	if len(cmd.paths) == 0 && !cmd.all {
		return cmd, errors.New("add path is required")
	}
	return cmd, nil
}

func parseRm(args []string) (gitCommand, error) {
	if len(args) == 0 {
		return gitCommand{}, errors.New("rm path is required")
	}
	cmd := gitCommand{op: "rm"}
	for _, arg := range args {
		if strings.HasPrefix(arg, "-") {
			return cmd, fmt.Errorf("unsupported rm option %q", arg)
		}
		cmd.paths = append(cmd.paths, arg)
	}
	return cmd, nil
}

func parseCommit(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "commit"}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "-m", "--message":
			i++
			if i >= len(args) {
				return cmd, errors.New("commit message is required")
			}
			cmd.message = args[i]
		case "-a", "--all":
			cmd.all = true
		case "--allow-empty":
			cmd.allowEmpty = true
		case "--amend":
			cmd.amend = true
		case "--author-name":
			i++
			if i >= len(args) {
				return cmd, errors.New("author name is required")
			}
			cmd.authorName = args[i]
		case "--author-email":
			i++
			if i >= len(args) {
				return cmd, errors.New("author email is required")
			}
			cmd.authorEmail = args[i]
		default:
			return cmd, fmt.Errorf("unsupported commit option %q", args[i])
		}
	}
	if cmd.message == "" {
		return cmd, errors.New("commit message is required")
	}
	return cmd, nil
}

func parsePull(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "pull", remote: "origin"}
	return parseRemoteBranchForce(cmd, args)
}

func parseFetch(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "fetch", remote: "origin"}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--force", "-f":
			cmd.force = true
		case "--prune", "-p":
			cmd.all = true
		case "--depth":
			i++
			depth, err := parsePositiveInt(args, i, "fetch depth")
			if err != nil {
				return cmd, err
			}
			cmd.depth = depth
		default:
			if strings.HasPrefix(args[i], "-") {
				return cmd, fmt.Errorf("unsupported fetch option %q", args[i])
			}
			if cmd.remote == "origin" {
				cmd.remote = args[i]
			} else {
				return cmd, fmt.Errorf("unexpected fetch argument %q", args[i])
			}
		}
	}
	return cmd, nil
}

func parsePush(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "push", remote: "origin"}
	return parseRemoteBranchForce(cmd, args, true)
}

func parseRemoteBranchForce(cmd gitCommand, args []string, allowSetUpstream ...bool) (gitCommand, error) {
	remoteSet := false
	for _, arg := range args {
		switch arg {
		case "--force", "-f":
			cmd.force = true
		case "--set-upstream", "-u":
			if len(allowSetUpstream) == 0 || !allowSetUpstream[0] {
				return cmd, fmt.Errorf("unsupported %s option %q", cmd.op, arg)
			}
			cmd.setUpstream = true
		default:
			if strings.HasPrefix(arg, "-") {
				return cmd, fmt.Errorf("unsupported %s option %q", cmd.op, arg)
			}
			if !remoteSet {
				cmd.remote = arg
				remoteSet = true
			} else if cmd.branch == "" {
				cmd.branch = arg
			} else {
				return cmd, fmt.Errorf("unexpected %s argument %q", cmd.op, arg)
			}
		}
	}
	return cmd, nil
}

func parseLog(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "log", limit: 20}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--limit", "-n":
			i++
			limit, err := parsePositiveInt(args, i, "log limit")
			if err != nil {
				return cmd, err
			}
			cmd.limit = limit
		case "--":
			cmd.paths = append(cmd.paths, args[i+1:]...)
			return cmd, nil
		default:
			return cmd, fmt.Errorf("unsupported log option %q", args[i])
		}
	}
	return cmd, nil
}

func parseCheckout(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "checkout"}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "-b":
			cmd.create = true
			i++
			if i >= len(args) {
				return cmd, errors.New("checkout branch name is required")
			}
			cmd.branch = args[i]
		case "--force", "-f":
			cmd.force = true
		default:
			if strings.HasPrefix(args[i], "-") {
				return cmd, fmt.Errorf("unsupported checkout option %q", args[i])
			}
			if cmd.target != "" {
				return cmd, fmt.Errorf("unexpected checkout argument %q", args[i])
			}
			cmd.target = args[i]
		}
	}
	if cmd.create {
		return cmd, nil
	}
	if cmd.target == "" {
		return cmd, errors.New("checkout target is required")
	}
	return cmd, nil
}

func parseReset(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "reset", resetMode: git.MixedReset}
	for _, arg := range args {
		switch arg {
		case "--soft":
			cmd.resetMode = git.SoftReset
		case "--mixed":
			cmd.resetMode = git.MixedReset
		case "--hard":
			cmd.resetMode = git.HardReset
		case "--confirm":
			cmd.confirm = true
		default:
			if strings.HasPrefix(arg, "-") {
				return cmd, fmt.Errorf("unsupported reset option %q", arg)
			}
			if cmd.target != "" {
				return cmd, fmt.Errorf("unexpected reset argument %q", arg)
			}
			cmd.target = arg
		}
	}
	if cmd.target == "" {
		return cmd, errors.New("reset commit is required")
	}
	if cmd.resetMode == git.HardReset && !cmd.confirm {
		return cmd, errors.New("reset --hard requires --confirm")
	}
	return cmd, nil
}

func parseClean(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "clean"}
	for _, arg := range args {
		switch arg {
		case "-f", "--force":
			cmd.force = true
		default:
			return cmd, fmt.Errorf("unsupported clean option %q", arg)
		}
	}
	if !cmd.force {
		return cmd, errors.New("clean requires -f")
	}
	return cmd, nil
}

func parseRestore(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "restore"}
	for _, arg := range args {
		switch arg {
		case "--staged":
			cmd.staged = true
		case "--worktree":
			cmd.worktree = true
		default:
			if strings.HasPrefix(arg, "-") {
				return cmd, fmt.Errorf("unsupported restore option %q", arg)
			}
			if err := validateRelativeGitPath(arg); err != nil {
				return cmd, err
			}
			cmd.paths = append(cmd.paths, arg)
		}
	}
	if len(cmd.paths) == 0 {
		return cmd, errors.New("restore path is required")
	}
	if !cmd.staged && !cmd.worktree {
		cmd.worktree = true
	}
	return cmd, nil
}

func parseBranch(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "branch"}
	switch len(args) {
	case 0:
		return cmd, nil
	case 2:
		if args[0] != "-d" {
			return cmd, fmt.Errorf("unsupported branch option %q", args[0])
		}
		if strings.HasPrefix(args[1], "-") {
			return cmd, errors.New("branch name is required")
		}
		cmd.branch = args[1]
		cmd.delete = true
		return cmd, nil
	case 1:
		if strings.HasPrefix(args[0], "-") {
			return cmd, fmt.Errorf("unsupported branch option %q", args[0])
		}
		cmd.branch = args[0]
		cmd.create = true
		return cmd, nil
	default:
		return cmd, fmt.Errorf("unexpected branch argument %q", args[1])
	}
}

func parseTag(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "tag"}
	if len(args) == 0 {
		return cmd, nil
	}
	if len(args) == 2 {
		if args[0] != "-d" {
			return cmd, fmt.Errorf("unsupported tag option %q", args[0])
		}
		if strings.HasPrefix(args[1], "-") {
			return cmd, errors.New("tag name is required")
		}
		cmd.target = args[1]
		cmd.delete = true
		return cmd, nil
	}
	if len(args) == 1 {
		if strings.HasPrefix(args[0], "-") {
			return cmd, fmt.Errorf("unsupported tag option %q", args[0])
		}
		cmd.target = args[0]
		cmd.create = true
		return cmd, nil
	}
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "-a":
			i++
			if i >= len(args) {
				return cmd, errors.New("tag name is required")
			}
			cmd.target = args[i]
			cmd.create = true
			cmd.action = "annotated"
		case "-m", "--message":
			i++
			if i >= len(args) {
				return cmd, errors.New("tag message is required")
			}
			cmd.message = args[i]
		default:
			return cmd, fmt.Errorf("unsupported tag option %q", args[i])
		}
	}
	if cmd.action == "annotated" && cmd.message == "" {
		return cmd, errors.New("annotated tag message is required")
	}
	return cmd, nil
}

func parseRemote(args []string) (gitCommand, error) {
	cmd := gitCommand{op: "remote"}
	if len(args) == 0 {
		return cmd, nil
	}
	switch args[0] {
	case "-v":
		return cmd, noExtraArgs("remote -v", args[1:])
	case "add":
		if len(args) != 3 {
			return cmd, errors.New("remote add requires name and URL")
		}
		cmd.action = "add"
		cmd.remote = args[1]
		cmd.url = args[2]
		return cmd, nil
	case "remove":
		if len(args) != 2 {
			return cmd, errors.New("remote remove requires name")
		}
		cmd.action = "remove"
		cmd.remote = args[1]
		return cmd, nil
	case "set-url":
		if len(args) != 3 {
			return cmd, errors.New("remote set-url requires name and URL")
		}
		cmd.action = "set-url"
		cmd.remote = args[1]
		cmd.url = args[2]
		return cmd, nil
	default:
		return cmd, fmt.Errorf("unsupported remote command %q", args[0])
	}
}

func parseMv(args []string) (gitCommand, error) {
	if len(args) != 2 {
		return gitCommand{}, errors.New("mv requires source and destination paths")
	}
	for _, arg := range args {
		if strings.HasPrefix(arg, "-") {
			return gitCommand{}, fmt.Errorf("unsupported mv option %q", arg)
		}
		if err := validateRelativeGitPath(arg); err != nil {
			return gitCommand{}, err
		}
	}
	return gitCommand{op: "mv", paths: []string{args[0]}, target: args[1]}, nil
}

func noExtraArgs(name string, args []string) error {
	if len(args) != 0 {
		return fmt.Errorf("%s does not accept arguments", name)
	}
	return nil
}

func parsePositiveInt(args []string, index int, label string) (int, error) {
	if index >= len(args) {
		return 0, fmt.Errorf("%s value is required", label)
	}
	value, err := strconv.Atoi(args[index])
	if err != nil || value < 1 {
		return 0, fmt.Errorf("%s must be a positive integer", label)
	}
	return value, nil
}

func runCommand(ctx context.Context, j *job) {
	cmd := j.req.cmd.parsed
	j.setRunning("running git " + cmd.op)
	var data map[string]any
	var err error
	switch cmd.op {
	case "init":
		data, err = execInit(j.req.cmd.repoPath, cmd)
	case "clone":
		data, err = execClone(ctx, j, cmd)
	case "ls-remote":
		data, err = execLsRemote(j, cmd)
	case "status":
		data, err = execStatus(j.req.cmd.repoPath)
	case "diff":
		data, err = execDiff(j.req.cmd.repoPath, cmd)
	case "add":
		data, err = execAdd(j.req.cmd.repoPath, cmd)
	case "rm":
		data, err = execRm(j.req.cmd.repoPath, cmd)
	case "commit":
		data, err = execCommit(j.req.cmd.repoPath, cmd)
	case "pull":
		data, err = execPull(ctx, j, cmd)
	case "fetch":
		data, err = execFetch(ctx, j, cmd)
	case "push":
		data, err = execPush(ctx, j, cmd)
	case "log":
		data, err = execLog(j.req.cmd.repoPath, cmd)
	case "checkout":
		data, err = execCheckout(ctx, j, cmd)
	case "reset":
		data, err = execReset(ctx, j, cmd)
	case "restore":
		data, err = execRestore(ctx, j, cmd)
	case "clean":
		data, err = execClean(j.req.cmd.repoPath)
	case "branch":
		data, err = execBranch(j.req.cmd.repoPath, cmd)
	case "tag":
		data, err = execTag(j.req.cmd.repoPath, cmd)
	case "remote":
		data, err = execRemote(j.req.cmd.repoPath, cmd)
	case "mv":
		data, err = execMv(j.req.cmd.repoPath, cmd)
	default:
		err = fmt.Errorf("unsupported git command %q", cmd.op)
	}
	if err != nil {
		if errors.Is(ctx.Err(), context.Canceled) {
			j.setCanceled()
			return
		}
		j.setError(err)
		return
	}
	j.setResult(data)
	j.setDone("git " + cmd.op + " completed")
}

func execClone(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	targetPath, err := cloneTargetPath(j.req.cmd.repoPath, cmd.url, cmd.target)
	if err != nil {
		return nil, err
	}
	if err := prepareClonePath(targetPath); err != nil {
		return nil, err
	}
	opts := &git.CloneOptions{
		URL:      cmd.url,
		Depth:    cmd.depth,
		Progress: progressWriter{job: j},
		Auth:     authMethod(j.req.cmd.options),
	}
	if cmd.branch != "" {
		opts.ReferenceName = plumbingBranch(cmd.branch)
		opts.SingleBranch = true
	}
	repo, err := git.PlainCloneContext(ctx, targetPath, false, opts)
	if err != nil {
		return nil, err
	}
	lfsData, err := fetchLFS(ctx, j, targetPath, "origin", true, false)
	if err != nil {
		return nil, err
	}
	head, _ := repo.Head()
	data := hashData(head)
	if data == nil {
		data = map[string]any{}
	}
	data["path"] = targetPath
	data["lfs"] = lfsData
	return data, nil
}

func execInit(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainInit(repoPath, cmd.bare)
	if err != nil {
		return nil, err
	}
	data := map[string]any{"path": repoPath, "bare": cmd.bare}
	if head, err := repo.Head(); err == nil {
		data["ref"] = head.Name().String()
	}
	return data, nil
}

func execLsRemote(j *job, cmd gitCommand) (map[string]any, error) {
	remote := git.NewRemote(memory.NewStorage(), &config.RemoteConfig{
		Name: "origin",
		URLs: []string{cmd.url},
	})
	refs, err := remote.ListContext(j.ctx, &git.ListOptions{
		Auth: authMethod(j.req.cmd.options),
	})
	if err != nil {
		return nil, err
	}
	data := make([]map[string]any, 0, len(refs))
	for _, ref := range refs {
		item := map[string]any{
			"name": ref.Name().String(),
			"type": refKind(ref.Name()),
		}
		if !ref.Hash().IsZero() {
			item["hash"] = ref.Hash().String()
		}
		if ref.Target() != "" {
			item["target"] = ref.Target().String()
		}
		data = append(data, item)
	}
	return map[string]any{"url": cmd.url, "refs": data}, nil
}

func execStatus(repoPath string) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	status, err := worktree.Status()
	if err != nil {
		return nil, err
	}
	if err := normalizeLFSStatus(repoPath, status); err != nil {
		return nil, err
	}
	files := make([]map[string]string, 0, len(status))
	for path, file := range status {
		if file.Staging == git.Unmodified && file.Worktree == git.Unmodified {
			continue
		}
		files = append(files, map[string]string{
			"path":     path,
			"staging":  string(file.Staging),
			"worktree": string(file.Worktree),
		})
	}
	return map[string]any{"clean": status.IsClean(), "files": files}, nil
}

func execDiff(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, _, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	path := cmd.paths[0]
	if cmd.target != "" {
		return execCommitFileDiff(repo, cmd.target, path)
	}
	statusData, err := execStatus(repoPath)
	if err != nil {
		return nil, err
	}
	fileStatus, ok := statusForPath(statusData["files"], path)
	if !ok {
		return map[string]any{"path": path, "staged": cmd.staged, "mode": "empty", "oldText": "", "newText": ""}, nil
	}
	var oldBytes, newBytes []byte
	if cmd.staged {
		if fileStatus["staging"] == " " || fileStatus["staging"] == "" {
			return map[string]any{"path": path, "staged": true, "mode": "empty", "oldText": "", "newText": ""}, nil
		}
		oldBytes, err = readHeadFile(repo, path)
		if err != nil && !errors.Is(err, plumbing.ErrReferenceNotFound) && !errors.Is(err, object.ErrFileNotFound) {
			return nil, err
		}
		newBytes, err = readIndexFile(repo, path)
		if err != nil && !errors.Is(err, index.ErrEntryNotFound) {
			return nil, err
		}
	} else {
		if fileStatus["worktree"] == " " || fileStatus["worktree"] == "" {
			return map[string]any{"path": path, "staged": false, "mode": "empty", "oldText": "", "newText": ""}, nil
		}
		oldBytes, err = readIndexFile(repo, path)
		if err != nil && !errors.Is(err, index.ErrEntryNotFound) {
			return nil, err
		}
		newBytes, err = os.ReadFile(filepath.Join(repoPath, filepath.Clean(path)))
		if err != nil && !os.IsNotExist(err) {
			return nil, err
		}
	}
	if isProbablyBinary(oldBytes) || isProbablyBinary(newBytes) {
		return map[string]any{"path": path, "staged": cmd.staged, "mode": "binary", "binary": true, "oldSize": len(oldBytes), "newSize": len(newBytes)}, nil
	}
	if len(oldBytes)+len(newBytes) > maxPreviewDiffBytes {
		return map[string]any{"path": path, "staged": cmd.staged, "mode": "large", "message": "File is too large to preview"}, nil
	}
	mode := "diff"
	if string(oldBytes) == string(newBytes) {
		mode = "empty"
	}
	return map[string]any{
		"path":    path,
		"staged":  cmd.staged,
		"mode":    mode,
		"oldText": string(oldBytes),
		"newText": string(newBytes),
	}, nil
}

func execCommitFileDiff(repo *git.Repository, commitHash, path string) (map[string]any, error) {
	commit, err := repo.CommitObject(plumbing.NewHash(commitHash))
	if err != nil {
		return nil, err
	}
	var parent *object.Commit
	parentIter := commit.Parents()
	parent, err = parentIter.Next()
	if errors.Is(err, plumbing.ErrObjectNotFound) {
		err = io.EOF
	}
	if err != nil && err != io.EOF {
		return nil, err
	}
	oldBytes := []byte{}
	if parent != nil {
		oldBytes, err = readCommitFile(parent, path)
		if err != nil && !errors.Is(err, object.ErrFileNotFound) {
			return nil, err
		}
	}
	newBytes, err := readCommitFile(commit, path)
	if err != nil && !errors.Is(err, object.ErrFileNotFound) {
		return nil, err
	}
	if isProbablyBinary(oldBytes) || isProbablyBinary(newBytes) {
		return map[string]any{"path": path, "commit": commitHash, "mode": "binary", "binary": true, "oldSize": len(oldBytes), "newSize": len(newBytes)}, nil
	}
	if len(oldBytes)+len(newBytes) > maxPreviewDiffBytes {
		return map[string]any{"path": path, "commit": commitHash, "mode": "large", "message": "File is too large to preview"}, nil
	}
	mode := "diff"
	if string(oldBytes) == string(newBytes) {
		mode = "empty"
	}
	return map[string]any{
		"path":    path,
		"commit":  commitHash,
		"mode":    mode,
		"oldText": string(oldBytes),
		"newText": string(newBytes),
	}, nil
}

func execAdd(repoPath string, cmd gitCommand) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	if cmd.all && len(cmd.paths) == 0 {
		if err := worktree.AddWithOptions(&git.AddOptions{All: true}); err != nil {
			return nil, err
		}
		lfsPaths, err := cleanLFSIndex(repoPath)
		return map[string]any{"paths": []string{"."}, "lfs": lfsPaths}, err
	}
	for _, p := range cmd.paths {
		if p == "." {
			if err := worktree.AddWithOptions(&git.AddOptions{All: true}); err != nil {
				return nil, err
			}
			continue
		}
		if hasGlob(p) {
			if err := worktree.AddGlob(p); err != nil {
				return nil, err
			}
			continue
		}
		if err := worktree.AddWithOptions(&git.AddOptions{Path: p, All: cmd.all}); err != nil {
			return nil, err
		}
	}
	lfsPaths, err := cleanLFSIndex(repoPath)
	return map[string]any{"paths": cmd.paths, "lfs": lfsPaths}, err
}

func execRm(repoPath string, cmd gitCommand) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	for _, p := range cmd.paths {
		if hasGlob(p) {
			if err := worktree.RemoveGlob(p); err != nil {
				return nil, err
			}
			continue
		}
		if _, err := worktree.Remove(p); err != nil {
			return nil, err
		}
	}
	return map[string]any{"paths": cmd.paths}, nil
}

func execCommit(repoPath string, cmd gitCommand) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	if cmd.all {
		if err := worktree.AddWithOptions(&git.AddOptions{All: true}); err != nil {
			return nil, err
		}
		if _, err := cleanLFSIndex(repoPath); err != nil {
			return nil, err
		}
		cmd.all = false
	}
	author := &object.Signature{
		Name:  firstNonEmpty(cmd.authorName, "Dora"),
		Email: firstNonEmpty(cmd.authorEmail, "dora@example.com"),
		When:  time.Now(),
	}
	hash, err := worktree.Commit(cmd.message, &git.CommitOptions{
		All:               cmd.all,
		AllowEmptyCommits: cmd.allowEmpty,
		Amend:             cmd.amend,
		Author:            author,
		Committer:         author,
	})
	if err != nil {
		return nil, err
	}
	return map[string]any{"commit": hash.String()}, nil
}

func execPull(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repo, worktree, err := openWorktree(j.req.cmd.repoPath)
	if err != nil {
		return nil, err
	}
	dehydrated, err := dehydrateCleanLFSFiles(j.req.cmd.repoPath)
	if err != nil {
		return nil, err
	}
	applied := false
	defer func() {
		if !applied {
			_ = rehydrateLFSFiles(j.req.cmd.repoPath, dehydrated)
		}
	}()
	opts := &git.PullOptions{
		RemoteName: cmd.remote,
		Force:      cmd.force,
		Progress:   progressWriter{job: j},
		Auth:       authMethod(j.req.cmd.options),
	}
	depth, err := fetchDepth(repo, cmd.depth)
	if err != nil {
		return nil, err
	}
	opts.Depth = depth
	if cmd.branch != "" {
		opts.ReferenceName = plumbingBranch(cmd.branch)
		opts.SingleBranch = true
	}
	err = worktree.PullContext(ctx, opts)
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		lfsData, lfsErr := fetchLFS(ctx, j, j.req.cmd.repoPath, cmd.remote, true, false)
		applied = lfsErr == nil
		return map[string]any{"upToDate": true, "lfs": lfsData}, lfsErr
	}
	if err != nil {
		return nil, err
	}
	applied = true
	lfsData, err := fetchLFS(ctx, j, j.req.cmd.repoPath, cmd.remote, true, false)
	return map[string]any{"lfs": lfsData}, err
}

func execFetch(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(j.req.cmd.repoPath)
	if err != nil {
		return nil, err
	}
	depth, err := fetchDepth(repo, cmd.depth)
	if err != nil {
		return nil, err
	}
	err = repo.FetchContext(ctx, &git.FetchOptions{
		RemoteName: cmd.remote,
		Depth:      depth,
		Force:      cmd.force,
		Prune:      cmd.all,
		Progress:   progressWriter{job: j},
		Auth:       authMethod(j.req.cmd.options),
	})
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		lfsData, lfsErr := fetchLFS(ctx, j, j.req.cmd.repoPath, cmd.remote, false, true)
		return map[string]any{"upToDate": true, "lfs": lfsData}, lfsErr
	}
	if err != nil {
		return nil, err
	}
	lfsData, err := fetchLFS(ctx, j, j.req.cmd.repoPath, cmd.remote, false, true)
	return map[string]any{"lfs": lfsData}, err
}

func fetchDepth(repo *git.Repository, requested int) (int, error) {
	if requested != 0 {
		return requested, nil
	}
	shallow, err := repo.Storer.Shallow()
	if err != nil {
		return 0, nil
	}
	if len(shallow) == 0 {
		return 0, nil
	}
	return 1, nil
}

func execPush(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(j.req.cmd.repoPath)
	if err != nil {
		return nil, err
	}
	if isUnbornHead(repo) {
		return nil, errors.New("cannot push before first commit")
	}
	lfsData, err := pushLFS(ctx, j, j.req.cmd.repoPath, cmd.remote, cmd.branch)
	if err != nil {
		return nil, err
	}
	opts := &git.PushOptions{
		RemoteName: cmd.remote,
		Force:      cmd.force,
		Progress:   progressWriter{job: j},
		Auth:       authMethod(j.req.cmd.options),
	}
	if cmd.branch != "" {
		ref := plumbingBranch(cmd.branch)
		opts.RefSpecs = []config.RefSpec{config.RefSpec(ref + ":" + ref)}
	}
	err = repo.PushContext(ctx, opts)
	if errors.Is(err, git.NoErrAlreadyUpToDate) {
		data := map[string]any{"upToDate": true, "lfs": lfsData}
		if cmd.setUpstream {
			upstream, err := setPushUpstream(repo, cmd)
			if err != nil {
				return nil, err
			}
			data["upstream"] = upstream
		}
		return data, nil
	}
	if err != nil {
		return nil, err
	}
	data := map[string]any{"lfs": lfsData}
	if cmd.setUpstream {
		upstream, err := setPushUpstream(repo, cmd)
		if err != nil {
			return nil, err
		}
		data["upstream"] = upstream
	}
	return data, nil
}

func setPushUpstream(repo *git.Repository, cmd gitCommand) (map[string]any, error) {
	localBranch := cmd.branch
	if localBranch == "" {
		localBranch = currentBranchName(repo)
	}
	if localBranch == "" {
		return nil, errors.New("cannot set upstream without a current branch")
	}
	remoteBranch := cmd.branch
	if remoteBranch == "" {
		remoteBranch = localBranch
	}
	return setBranchUpstream(repo, localBranch, cmd.remote, remoteBranch)
}

func setBranchUpstream(repo *git.Repository, localBranch, remote, remoteBranch string) (map[string]any, error) {
	cfg, err := repo.Config()
	if err != nil {
		return nil, err
	}
	if cfg.Branches == nil {
		cfg.Branches = make(map[string]*config.Branch)
	}
	cfg.Branches[localBranch] = &config.Branch{
		Name:   localBranch,
		Remote: remote,
		Merge:  plumbingBranch(remoteBranch),
	}
	if err := repo.SetConfig(cfg); err != nil {
		return nil, err
	}
	return map[string]any{"branch": localBranch, "remote": remote, "merge": plumbingBranch(remoteBranch).String()}, nil
}

func execLog(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	head, err := repo.Head()
	if errors.Is(err, plumbing.ErrReferenceNotFound) {
		return map[string]any{"commits": []map[string]any{}}, nil
	}
	if err != nil {
		return nil, err
	}
	path := ""
	if len(cmd.paths) != 0 {
		path = cmd.paths[0]
	}
	commits, err := shallowAwareLog(repo, head.Hash(), cmd.limit, path)
	return map[string]any{"commits": commits}, err
}

func shallowAwareLog(repo *git.Repository, from plumbing.Hash, limit int, path string) ([]map[string]any, error) {
	shallowSet := map[plumbing.Hash]struct{}{}
	if shallow, err := repo.Storer.Shallow(); err == nil {
		for _, hash := range shallow {
			shallowSet[hash] = struct{}{}
		}
	}
	queue := &commitPriorityQueue{}
	heap.Init(queue)
	if err := pushCommit(repo, queue, from); err != nil {
		if errors.Is(err, plumbing.ErrObjectNotFound) {
			return []map[string]any{}, nil
		}
		return nil, err
	}
	seen := map[plumbing.Hash]struct{}{}
	commits := []map[string]any{}
	for queue.Len() != 0 && len(commits) < limit {
		commit := heap.Pop(queue).(*object.Commit)
		if _, ok := seen[commit.Hash]; ok {
			continue
		}
		seen[commit.Hash] = struct{}{}
		data, err := commitLogData(commit)
		if err != nil {
			return nil, err
		}
		if path == "" || commitLogDataTouchesPath(data, path) {
			commits = append(commits, data)
		}
		if _, shallow := shallowSet[commit.Hash]; shallow {
			continue
		}
		for _, parentHash := range commit.ParentHashes {
			if _, ok := seen[parentHash]; ok {
				continue
			}
			if err := pushCommit(repo, queue, parentHash); err != nil && !errors.Is(err, plumbing.ErrObjectNotFound) {
				return nil, err
			}
		}
	}
	return commits, nil
}

func pushCommit(repo *git.Repository, queue *commitPriorityQueue, hash plumbing.Hash) error {
	commit, err := repo.CommitObject(hash)
	if err != nil {
		return err
	}
	heap.Push(queue, commit)
	return nil
}

type commitPriorityQueue []*object.Commit

func (q commitPriorityQueue) Len() int {
	return len(q)
}

func (q commitPriorityQueue) Less(i, j int) bool {
	left := q[i]
	right := q[j]
	if left.Committer.When.Equal(right.Committer.When) {
		return left.Hash.String() > right.Hash.String()
	}
	return left.Committer.When.After(right.Committer.When)
}

func (q commitPriorityQueue) Swap(i, j int) {
	q[i], q[j] = q[j], q[i]
}

func (q *commitPriorityQueue) Push(x any) {
	*q = append(*q, x.(*object.Commit))
}

func (q *commitPriorityQueue) Pop() any {
	old := *q
	n := len(old)
	item := old[n-1]
	*q = old[:n-1]
	return item
}

func commitLogDataTouchesPath(data map[string]any, path string) bool {
	files, ok := data["files"].([]map[string]any)
	if !ok {
		return false
	}
	for _, file := range files {
		filePath, ok := file["path"].(string)
		if !ok {
			continue
		}
		if filePath == path || strings.HasPrefix(filePath, path+"/") || strings.HasPrefix(path, filePath+"/") {
			return true
		}
	}
	return false
}

func commitLogData(commit *object.Commit) (map[string]any, error) {
	files, err := commitChangedFiles(commit)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"hash":    commit.Hash.String(),
		"message": strings.TrimSpace(commit.Message),
		"author":  commit.Author.Name,
		"email":   commit.Author.Email,
		"when":    commit.Author.When.Format(time.RFC3339),
		"files":   files,
	}, nil
}

func commitChangedFiles(commit *object.Commit) ([]map[string]any, error) {
	parentIter := commit.Parents()
	parent, err := parentIter.Next()
	if errors.Is(err, plumbing.ErrObjectNotFound) {
		return commitTreeFiles(commit)
	}
	if err != nil && err != io.EOF {
		return nil, err
	}
	if parent == nil {
		return commitTreeFiles(commit)
	}
	var files []map[string]any
	parentTree, err := parent.Tree()
	if err != nil {
		return nil, err
	}
	tree, err := commit.Tree()
	if err != nil {
		return nil, err
	}
	changes, err := parentTree.Diff(tree)
	if err != nil {
		return nil, err
	}
	for _, change := range changes {
		action, err := change.Action()
		if err != nil {
			return nil, err
		}
		path := change.To.Name
		status := "M"
		switch action.String() {
		case "Insert":
			status = "A"
		case "Delete":
			status = "D"
			path = change.From.Name
		default:
			status = "M"
		}
		files = append(files, map[string]any{"path": path, "status": status})
	}
	return files, nil
}

func commitTreeFiles(commit *object.Commit) ([]map[string]any, error) {
	tree, err := commit.Tree()
	if err != nil {
		return nil, err
	}
	files := []map[string]any{}
	err = tree.Files().ForEach(func(file *object.File) error {
		files = append(files, map[string]any{"path": file.Name, "status": "A"})
		return nil
	})
	return files, err
}

func execCheckout(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repoPath := j.req.cmd.repoPath
	repo, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	dehydrated, err := dehydrateCleanLFSFiles(repoPath)
	if err != nil {
		return nil, err
	}
	applied := false
	defer func() {
		if !applied {
			_ = rehydrateLFSFiles(repoPath, dehydrated)
		}
	}()
	if cmd.create && isUnbornHead(repo) {
		refName := plumbingBranch(cmd.branch)
		if _, err := repo.Reference(refName, false); err == nil {
			return nil, git.ErrBranchExists
		} else if !errors.Is(err, plumbing.ErrReferenceNotFound) {
			return nil, err
		}
		if err := repo.Storer.SetReference(plumbing.NewSymbolicReference(plumbing.HEAD, refName)); err != nil {
			return nil, err
		}
		return map[string]any{"branch": cmd.branch, "unborn": true}, nil
	}
	opts := &git.CheckoutOptions{Create: cmd.create, Force: cmd.force}
	if cmd.create {
		opts.Branch = plumbingBranch(cmd.branch)
		if cmd.target != "" {
			hash, _, _, err := checkoutStartPoint(repo, cmd.target)
			if err != nil {
				return nil, err
			}
			opts.Hash = hash
		}
	} else if hash, ok := parseHash(cmd.target); ok {
		opts.Hash = hash
	} else {
		branchRef := plumbingBranch(cmd.target)
		if _, err := repo.Reference(branchRef, false); err == nil {
			opts.Branch = branchRef
		} else if errors.Is(err, plumbing.ErrReferenceNotFound) {
			remoteRef := plumbing.ReferenceName("refs/remotes/" + cmd.target)
			if ref, err := repo.Reference(remoteRef, true); err == nil {
				opts.Hash = ref.Hash()
			} else {
				opts.Branch = branchRef
			}
		} else {
			return nil, err
		}
	}
	if !opts.Hash.IsZero() {
		if _, err := repo.CommitObject(opts.Hash); err != nil {
			return nil, err
		}
	}
	if err := worktree.Checkout(opts); err != nil {
		return nil, err
	}
	applied = true
	if cmd.create && cmd.target != "" {
		if _, remote, remoteBranch, err := checkoutStartPoint(repo, cmd.target); err == nil && remote != "" && remoteBranch != "" {
			if _, err := setBranchUpstream(repo, cmd.branch, remote, remoteBranch); err != nil {
				return nil, err
			}
		}
	}
	head, _ := repo.Head()
	data := hashData(head)
	lfsData, err := fetchLFS(ctx, j, repoPath, firstRemoteName(repo), true, false)
	if err != nil {
		return nil, err
	}
	if data == nil {
		data = map[string]any{}
	}
	data["lfs"] = lfsData
	return data, nil
}

func checkoutStartPoint(repo *git.Repository, target string) (plumbing.Hash, string, string, error) {
	if hash, ok := parseHash(target); ok {
		return hash, "", "", nil
	}
	branchRef := plumbingBranch(target)
	if ref, err := repo.Reference(branchRef, true); err == nil {
		return ref.Hash(), "", "", nil
	} else if !errors.Is(err, plumbing.ErrReferenceNotFound) {
		return plumbing.ZeroHash, "", "", err
	}
	remoteTarget := strings.TrimPrefix(target, "refs/remotes/")
	remoteRef := plumbing.ReferenceName("refs/remotes/" + remoteTarget)
	ref, err := repo.Reference(remoteRef, true)
	if err != nil {
		return plumbing.ZeroHash, "", "", err
	}
	remote, branch, ok := strings.Cut(remoteTarget, "/")
	if !ok || remote == "" || branch == "" {
		return plumbing.ZeroHash, "", "", fmt.Errorf("invalid remote branch %q", target)
	}
	return ref.Hash(), remote, branch, nil
}

func execReset(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repoPath := j.req.cmd.repoPath
	repo, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	hash, ok := parseHash(cmd.target)
	if !ok {
		return nil, errors.New("reset target must be a commit hash")
	}
	if err := worktree.Reset(&git.ResetOptions{Commit: hash, Mode: cmd.resetMode}); err != nil {
		return nil, err
	}
	head, _ := repo.Head()
	data := hashData(head)
	if cmd.resetMode == git.HardReset {
		lfsData, err := fetchLFS(ctx, j, repoPath, firstRemoteName(repo), true, false)
		if err != nil {
			return nil, err
		}
		if data == nil {
			data = map[string]any{}
		}
		data["lfs"] = lfsData
	}
	return data, nil
}

func execRestore(ctx context.Context, j *job, cmd gitCommand) (map[string]any, error) {
	repoPath := j.req.cmd.repoPath
	repo, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	if cmd.staged {
		if err := worktree.Restore(&git.RestoreOptions{
			Staged:   true,
			Worktree: cmd.worktree,
			Files:    cmd.paths,
		}); err != nil {
			if errors.Is(err, plumbing.ErrReferenceNotFound) && !cmd.worktree {
				if indexErr := unstageFromUnbornIndex(repo, cmd.paths); indexErr == nil {
					return map[string]any{"paths": cmd.paths, "staged": true, "worktree": false}, nil
				} else {
					return nil, indexErr
				}
			}
			return nil, err
		}
		return map[string]any{"paths": cmd.paths, "staged": true, "worktree": cmd.worktree}, nil
	}
	head, err := repo.Head()
	if err != nil {
		if errors.Is(err, plumbing.ErrReferenceNotFound) {
			return nil, errors.New("cannot restore worktree before first commit")
		}
		return nil, err
	}
	commit, err := repo.CommitObject(head.Hash())
	if err != nil {
		return nil, err
	}
	tree, err := commit.Tree()
	if err != nil {
		return nil, err
	}
	for _, path := range cmd.paths {
		if err := restoreWorktreePath(repoPath, tree, path); err != nil {
			return nil, err
		}
	}
	lfsData, err := fetchLFS(ctx, j, repoPath, firstRemoteName(repo), true, false)
	return map[string]any{"paths": cmd.paths, "staged": false, "worktree": true, "lfs": lfsData}, err
}

func unstageFromUnbornIndex(repo *git.Repository, paths []string) error {
	idx, err := repo.Storer.Index()
	if err != nil {
		return err
	}
	for _, path := range paths {
		if _, err := idx.Remove(path); err != nil {
			return err
		}
	}
	return repo.Storer.SetIndex(idx)
}

func execClean(repoPath string) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	return nil, worktree.Clean(&git.CleanOptions{Dir: true})
}

func execBranch(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	if cmd.create {
		head, err := repo.Head()
		if errors.Is(err, plumbing.ErrReferenceNotFound) {
			refName := plumbing.NewBranchReferenceName(cmd.branch)
			if _, err := repo.Reference(refName, false); err == nil {
				return nil, git.ErrBranchExists
			} else if !errors.Is(err, plumbing.ErrReferenceNotFound) {
				return nil, err
			}
			if err := repo.Storer.SetReference(plumbing.NewSymbolicReference(plumbing.HEAD, refName)); err != nil {
				return nil, err
			}
			return map[string]any{"branch": cmd.branch, "unborn": true}, nil
		} else if err != nil {
			return nil, err
		}
		refName := plumbing.NewBranchReferenceName(cmd.branch)
		if _, err := repo.Reference(refName, false); err == nil {
			return nil, git.ErrBranchExists
		} else if !errors.Is(err, plumbing.ErrReferenceNotFound) {
			return nil, err
		}
		ref := plumbing.NewHashReference(refName, head.Hash())
		if err := repo.Storer.SetReference(ref); err != nil {
			return nil, err
		}
		return map[string]any{"branch": cmd.branch, "hash": head.Hash().String()}, nil
	}
	if cmd.delete {
		refName := plumbing.NewBranchReferenceName(cmd.branch)
		if _, err := repo.Reference(refName, false); err != nil {
			return nil, err
		}
		if err := repo.Storer.RemoveReference(refName); err != nil {
			return nil, err
		}
		if err := repo.DeleteBranch(cmd.branch); err != nil && !errors.Is(err, git.ErrBranchNotFound) {
			return nil, err
		}
		return map[string]any{"branch": cmd.branch, "deleted": true}, nil
	}

	current := currentBranchName(repo)
	iter, err := repo.Branches()
	if err != nil {
		return nil, err
	}
	defer iter.Close()
	branches := []map[string]any{}
	err = iter.ForEach(func(ref *plumbing.Reference) error {
		name := ref.Name().Short()
		branches = append(branches, map[string]any{
			"name":    name,
			"hash":    ref.Hash().String(),
			"current": name == current,
		})
		return nil
	})
	if err != nil {
		return nil, err
	}
	refIter, err := repo.References()
	if err != nil {
		return nil, err
	}
	defer refIter.Close()
	err = refIter.ForEach(func(ref *plumbing.Reference) error {
		if !ref.Name().IsRemote() {
			return nil
		}
		short := ref.Name().Short()
		remote, branch, ok := strings.Cut(short, "/")
		if !ok || remote == "" || branch == "" || branch == "HEAD" {
			return nil
		}
		branches = append(branches, map[string]any{
			"name":   branch,
			"hash":   ref.Hash().String(),
			"remote": remote,
		})
		return nil
	})
	return map[string]any{"branches": branches, "current": current}, err
}

func currentBranchName(repo *git.Repository) string {
	head, err := repo.Head()
	if err == nil && head != nil && head.Name().IsBranch() {
		return head.Name().Short()
	}
	head, err = repo.Storer.Reference(plumbing.HEAD)
	if err == nil && head != nil && head.Target().IsBranch() {
		return head.Target().Short()
	}
	return ""
}

func isUnbornHead(repo *git.Repository) bool {
	if _, err := repo.Head(); !errors.Is(err, plumbing.ErrReferenceNotFound) {
		return false
	}
	head, err := repo.Storer.Reference(plumbing.HEAD)
	return err == nil && head != nil && head.Target().IsBranch()
}

func execTag(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	if cmd.delete {
		if err := repo.DeleteTag(cmd.target); err != nil {
			return nil, err
		}
		return map[string]any{"tag": cmd.target, "deleted": true}, nil
	}
	if cmd.create {
		head, err := repo.Head()
		if errors.Is(err, plumbing.ErrReferenceNotFound) {
			return nil, errors.New("cannot create tag before first commit")
		} else if err != nil {
			return nil, err
		}
		var opts *git.CreateTagOptions
		if cmd.action == "annotated" {
			opts = &git.CreateTagOptions{
				Tagger: &object.Signature{
					Name:  firstNonEmpty(cmd.authorName, "Dora"),
					Email: firstNonEmpty(cmd.authorEmail, "dora@example.com"),
					When:  time.Now(),
				},
				Message: cmd.message,
			}
		}
		ref, err := repo.CreateTag(cmd.target, head.Hash(), opts)
		if err != nil {
			return nil, err
		}
		return map[string]any{"tag": cmd.target, "hash": ref.Hash().String(), "annotated": cmd.action == "annotated"}, nil
	}

	iter, err := repo.Tags()
	if err != nil {
		return nil, err
	}
	defer iter.Close()
	tags := []map[string]any{}
	err = iter.ForEach(func(ref *plumbing.Reference) error {
		hash := peelTagHash(repo, ref.Hash())
		tags = append(tags, map[string]any{
			"name": ref.Name().Short(),
			"hash": hash.String(),
			"ref":  ref.Hash().String(),
		})
		return nil
	})
	return map[string]any{"tags": tags}, err
}

func peelTagHash(repo *git.Repository, hash plumbing.Hash) plumbing.Hash {
	for i := 0; i < 8; i++ {
		tag, err := repo.TagObject(hash)
		if err != nil {
			return hash
		}
		hash = tag.Target
	}
	return hash
}

func execRemote(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, err
	}
	switch cmd.action {
	case "add":
		if _, err := repo.CreateRemote(&config.RemoteConfig{Name: cmd.remote, URLs: []string{cmd.url}}); err != nil {
			return nil, err
		}
		return map[string]any{"remote": cmd.remote, "urls": []string{cmd.url}}, nil
	case "remove":
		if err := repo.DeleteRemote(cmd.remote); err != nil {
			return nil, err
		}
		return map[string]any{"remote": cmd.remote, "removed": true}, nil
	case "set-url":
		cfg, err := repo.Config()
		if err != nil {
			return nil, err
		}
		remote := cfg.Remotes[cmd.remote]
		if remote == nil {
			return nil, git.ErrRemoteNotFound
		}
		remote.URLs = []string{cmd.url}
		if err := remote.Validate(); err != nil {
			return nil, err
		}
		if err := repo.SetConfig(cfg); err != nil {
			return nil, err
		}
		return map[string]any{"remote": cmd.remote, "urls": []string{cmd.url}}, nil
	}

	remotes, err := repo.Remotes()
	if err != nil {
		return nil, err
	}
	data := []map[string]any{}
	for _, remote := range remotes {
		cfg := remote.Config()
		data = append(data, map[string]any{
			"name": cfg.Name,
			"urls": append([]string(nil), cfg.URLs...),
		})
	}
	return map[string]any{"remotes": data}, nil
}

func execMv(repoPath string, cmd gitCommand) (map[string]any, error) {
	_, worktree, err := openWorktree(repoPath)
	if err != nil {
		return nil, err
	}
	from := cmd.paths[0]
	to := cmd.target
	if err := rejectDirectoryPath(repoPath, from, "mv source"); err != nil {
		return nil, err
	}
	hash, err := worktree.Move(from, to)
	if err != nil {
		return nil, err
	}
	lfsPaths, err := cleanLFSIndex(repoPath)
	return map[string]any{"from": from, "to": to, "hash": hash.String(), "lfs": lfsPaths}, err
}

func openWorktree(repoPath string) (*git.Repository, *git.Worktree, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, nil, err
	}
	worktree, err := repo.Worktree()
	if err != nil {
		return nil, nil, err
	}
	return repo, worktree, nil
}

func authMethod(options runOptions) transport.AuthMethod {
	auth := options.Auth
	switch strings.ToLower(auth.Type) {
	case "basic":
		if auth.Username == "" && auth.Password == "" {
			return nil
		}
		return &http.BasicAuth{Username: auth.Username, Password: auth.Password}
	case "token":
		if auth.Token == "" {
			return nil
		}
		return &http.BasicAuth{Username: firstNonEmpty(auth.Username, "token"), Password: auth.Token}
	default:
		return nil
	}
}

func parseHash(value string) (plumbing.Hash, bool) {
	if len(value) != 40 {
		return plumbing.ZeroHash, false
	}
	for _, r := range value {
		if !strings.ContainsRune("0123456789abcdefABCDEF", r) {
			return plumbing.ZeroHash, false
		}
	}
	return plumbing.NewHash(value), true
}

func plumbingBranch(branch string) plumbing.ReferenceName {
	if strings.HasPrefix(branch, "refs/") {
		return plumbing.ReferenceName(branch)
	}
	return plumbing.ReferenceName("refs/heads/" + branch)
}

func hashData(ref *plumbing.Reference) map[string]any {
	if ref == nil {
		return nil
	}
	return map[string]any{"head": ref.Hash().String(), "ref": ref.Name().String()}
}

func hasGlob(path string) bool {
	return strings.ContainsAny(path, "*?[")
}

func validateRelativeGitPath(path string) error {
	if path == "" {
		return errors.New("path is required")
	}
	clean := filepath.Clean(path)
	if filepath.IsAbs(path) || clean == "." || clean == ".." || strings.HasPrefix(clean, ".."+string(filepath.Separator)) {
		return fmt.Errorf("path must be relative to the repository: %q", path)
	}
	return nil
}

func rejectDirectoryPath(repoPath, path, label string) error {
	info, err := filepath.Abs(filepath.Join(repoPath, filepath.Clean(path)))
	if err != nil {
		return err
	}
	root, err := filepath.Abs(repoPath)
	if err != nil {
		return err
	}
	if info != root && !strings.HasPrefix(info, root+string(filepath.Separator)) {
		return fmt.Errorf("%s must stay inside the repository", label)
	}
	fileInfo, err := os.Lstat(info)
	if err != nil {
		return err
	}
	if fileInfo.IsDir() {
		return fmt.Errorf("%s must be a single file", label)
	}
	return nil
}

func statusForPath(files any, path string) (map[string]string, bool) {
	items, ok := files.([]map[string]string)
	if !ok {
		return nil, false
	}
	for _, file := range items {
		if file["path"] == path {
			return file, true
		}
	}
	return nil, false
}

func readHeadFile(repo *git.Repository, path string) ([]byte, error) {
	head, err := repo.Head()
	if err != nil {
		return nil, err
	}
	commit, err := repo.CommitObject(head.Hash())
	if err != nil {
		return nil, err
	}
	file, err := commit.File(path)
	if err != nil {
		return nil, err
	}
	reader, err := file.Reader()
	if err != nil {
		return nil, err
	}
	defer reader.Close()
	return io.ReadAll(reader)
}

func readCommitFile(commit *object.Commit, path string) ([]byte, error) {
	file, err := commit.File(path)
	if err != nil {
		return nil, err
	}
	reader, err := file.Reader()
	if err != nil {
		return nil, err
	}
	defer reader.Close()
	return io.ReadAll(reader)
}

func readIndexFile(repo *git.Repository, path string) ([]byte, error) {
	idx, err := repo.Storer.Index()
	if err != nil {
		return nil, err
	}
	entry, err := idx.Entry(path)
	if err != nil {
		return nil, err
	}
	blob, err := object.GetBlob(repo.Storer, entry.Hash)
	if err != nil {
		return nil, err
	}
	reader, err := blob.Reader()
	if err != nil {
		return nil, err
	}
	defer reader.Close()
	return io.ReadAll(reader)
}

func isProbablyBinary(data []byte) bool {
	if len(data) == 0 {
		return false
	}
	if bytesContainNUL(data) {
		return true
	}
	return !utf8.Valid(data)
}

func bytesContainNUL(data []byte) bool {
	for _, b := range data {
		if b == 0 {
			return true
		}
	}
	return false
}

func restoreWorktreePath(repoPath string, tree *object.Tree, path string) error {
	file, err := tree.File(path)
	if err != nil {
		return err
	}
	reader, err := file.Reader()
	if err != nil {
		return err
	}
	defer reader.Close()
	target := filepath.Join(repoPath, filepath.Clean(path))
	if err := os.MkdirAll(filepath.Dir(target), 0777); err != nil {
		return err
	}
	out, err := os.OpenFile(target, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0666)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, reader)
	return err
}

func refKind(name plumbing.ReferenceName) string {
	switch {
	case name == plumbing.HEAD:
		return "head"
	case name.IsBranch():
		return "branch"
	case name.IsTag():
		return "tag"
	case name.IsRemote():
		return "remote"
	default:
		return "ref"
	}
}

func firstNonEmpty(values ...string) string {
	for _, value := range values {
		if value != "" {
			return value
		}
	}
	return ""
}

func cloneTargetPath(parentPath, url, dir string) (string, error) {
	parentPath = strings.TrimSpace(parentPath)
	dir = strings.TrimSpace(dir)
	if parentPath == "" {
		return "", errors.New("clone parent path is required")
	}
	if dir == "" {
		dir = repoNameFromURL(url)
		if dir == "" {
			return "", errors.New("clone directory could not be inferred from URL")
		}
	}
	if filepath.IsAbs(dir) || dir != filepath.Base(dir) || dir == "." || dir == ".." {
		return "", errors.New("clone directory must be a folder name")
	}
	return filepath.Join(parentPath, dir), nil
}

func repoNameFromURL(url string) string {
	url = strings.TrimSpace(url)
	url = strings.TrimRight(url, "/")
	if url == "" {
		return ""
	}
	if i := strings.LastIndex(url, ":"); i >= 0 && !strings.Contains(url[i+1:], "/") {
		url = url[i+1:]
	}
	name := filepath.Base(url)
	name = strings.TrimSuffix(name, ".git")
	if name == "." || name == "/" {
		return ""
	}
	return name
}
