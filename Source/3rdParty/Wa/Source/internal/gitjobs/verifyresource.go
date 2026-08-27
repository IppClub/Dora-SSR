package gitjobs

import (
	"fmt"
	"strings"

	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
	"github.com/go-git/go-git/v5/plumbing/filemode"
	"github.com/go-git/go-git/v5/plumbing/object"
)

const maxResourceFiles = 100000

func execVerifyResource(repoPath string, cmd gitCommand) (map[string]any, error) {
	repo, err := git.PlainOpen(repoPath)
	if err != nil {
		return nil, fmt.Errorf("open resource repository: %w", err)
	}
	commitHash := cmd.commitHash
	if commitHash == "" {
		head, err := repo.Head()
		if err != nil {
			return nil, fmt.Errorf("read resource HEAD: %w", err)
		}
		commitHash = head.Hash().String()
	}
	commit, err := repo.CommitObject(plumbing.NewHash(commitHash))
	if err != nil {
		return nil, fmt.Errorf("read resource commit: %w", err)
	}
	tree, err := commit.Tree()
	if err != nil {
		return nil, fmt.Errorf("read resource tree: %w", err)
	}
	files := tree.Files()
	defer files.Close()
	count := 0
	err = files.ForEach(func(file *object.File) error {
		count++
		if count > maxResourceFiles {
			return fmt.Errorf("resource contains more than %d files", maxResourceFiles)
		}
		if file.Mode == filemode.Symlink {
			return fmt.Errorf("resource contains unsupported symbolic link %q", file.Name)
		}
		if file.Mode == filemode.Submodule {
			return fmt.Errorf("resource contains unsupported Git submodule %q", file.Name)
		}
		if strings.EqualFold(file.Name, ".gitmodules") {
			return fmt.Errorf("resource contains unsupported .gitmodules file")
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"commit": commitHash,
		"files":  count,
	}, nil
}
