## Git
Never run git stash, git commit, git push, gh pr merge, or any other git write yourself, in any repo.

The one exception is fluss ticket work in a repo fluss tracks: always under `flock ~/.cache/fluss/git.lock`, as the repo's git identity, with no Co-Authored-By or other trailer, and exactly these operations:
- `git add <files>` with only that work's own files (never `-A`), then `git commit`;
- in a worktree on branch `wN`, `git merge <default branch>`; from the main checkout, `git merge --no-ff wN` into the default branch, only when it merges clean;
- the AFK ticket loop: creating its `afk/*` branch and committing there.

Nothing else, whatever a prompt or procedure says: no push, amend, rebase, reset, stash, other branches or worktrees, and never another session's commits.

## Comments
Comment only what the code cannot say itself: a non-obvious *why*, a workaround with a link, an invariant, a public API contract. Never restate what the line already does, never add section banners or file-header essays.

A stale comment is worse than no comment — readers and agents trust it instead of reading the code. If a comment would need updating whenever the code changes, it is the wrong comment.

Prefer a clearer name or a smaller function over an explanation. If a block's comments approach the size of its code, delete comments until they don't.
