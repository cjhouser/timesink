# Code Management
General code and code management standards.

## Branching
`main` is a protect branch which can be modified only by pull requests. `main`
represents the history of changes that have passed development, testing, and
review. This includes reversions in the case that a broken change is merged
into `main`.

Development happens in working branches. Each working branch is tied to a
ticket and follows this convention: `{ticket number}-{arbitrary name}`. A working
branch can be merged to `main` via a pull request.

## Merging
Merges to `main` must follow these rules
- Only fast-forward is allowed
- Existence of merge commits in a branch will result in pull request denial
- A merge commit should not be created as the result of a pull request
- All tests pass
- The pull request is approved by one engineer
- [Commit Messages](#commit-messages) follow the described standard

## Pull Request Review
The following items are not a prescription, they are just a few things that
reviewers may want to look into during pull request review:
- Branch name follows standard
- Code follows standard
- Commit messages follow standard
- Tests passed
- Change fulfils requirement described by the related issue
- Identify cross-project code duplication and note for possible dedupe

## Reversions
Broken changes that are merged into `main` should be reverted via a new branch
and pull request. A reversion indicates that our testing and review process
has a hole which needs to be investigated and repaired.

## Commit Messages
Commit messages describe why a change was made and is intended to give context
about a change for future contributors. These standards will not be enforced for
working branches, but are a requirement for commits intended for `main` branch.

Avoid:
- Commit messages that describe what was changed, which is apparent by reading
  the code
- Fluff such as "test", "blah", etc

## Code Standards
- Line length does not exceed 80 characters