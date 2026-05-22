---
name: feedback-no-git-commits
description: User does not want Claude or subagents to run git commands or make commits
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a0de8c18-a213-4f64-9797-d551fe7a32f3
---

Do not run git commands directly or via subagents. Just write the files.

**Why:** User explicitly said "stop running git commands" and "just write the files" — they handle their own commits.

**How to apply:** Skip all commit/git steps in plans. Write files only. Do not stage, commit, push, or run any git operations.
