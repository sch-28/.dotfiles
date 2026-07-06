## Tool routing

Prefer Read/Grep/Glob over Bash `cat`/`grep`/`find`. No permission prompts, handles `$var` paths (TanStack routes). Bash only for pipelines, `wc -l`, `find -size/-mtime`, `sed`/`awk` transforms.

## Git
Never run git stash, git commit, git push, gh pr merge, or any write/publish git op yourself — ever, in any repo.
