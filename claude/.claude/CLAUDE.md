## Git
Never run git stash, git commit, git push, gh pr merge, or any write/publish git op yourself — ever, in any repo.

## Comments
Comment only what the code cannot say itself: a non-obvious *why*, a workaround with a link, an invariant, a public API contract. Never restate what the line already does, never add section banners or file-header essays.

A stale comment is worse than no comment — readers and agents trust it instead of reading the code. If a comment would need updating whenever the code changes, it is the wrong comment.

Prefer a clearer name or a smaller function over an explanation. If a block's comments approach the size of its code, delete comments until they don't.
