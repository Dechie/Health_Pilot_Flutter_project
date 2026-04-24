# Stacked PRs + git worktrees (Health Pilot)

This document **extends** `docs/FEATURE_BRANCH_PLAN.md` with a practical workflow: **one branch per layer**, **stacked PR bases**, and **optional git worktrees** so you never edit the wrong tree.

**App code root:** `healthpilot/` (Flutter package). **Docs / git root:** repo root.

---

## 1) Mental model: build upward, not sideways

Each merged (or pending) PR is a **layer** on top of the previous one:

```text
main
 └── health-assessment          (PR: assessment UI + flow + docs)
      └── refactor/features-boundaries   (PR: Branch A — medication/subscription extraction)
           └── refactor/profile-feature   (PR: Branch B)
                └── refactor/onboarding-flow   (PR: Branch C)
                     └── …
```

- **Stacked PR rule:** open PR *N+1* with **base = branch for PR *N***, not `main`, until the stack is merged down (or you explicitly rebase onto `main` after parent merges).
- **Reviewer-friendly:** PR description should say *“Stacked on #… / branch X”* so the reviewer picks the correct base in the GitHub UI.

---

## 2) Optional: folder layout with worktrees

Keep the **canonical clone** at your usual path; add **sibling folders** per active branch:

```text
Health_Pilot_Flutter_project/     ← primary repo (e.g. on refactor/features-boundaries)
../wt-profile/                    ← git worktree: refactor/profile-feature
../wt-onboarding/               ← git worktree: refactor/onboarding-flow
../wt-subscription/             ← git worktree: refactor/subscription-feature
```

Naming is arbitrary; stay consistent.

---

## 3) Commands cheat sheet

### Sync remotes

```bash
git fetch origin
```

When you are **starting the next plan slice from `main`** (after earlier PRs merged), also sync the remote that owns integrated `main` (often `upstream` for a fork workflow), update `main`, then branch:

```bash
git fetch upstream
git checkout main
git pull upstream main
git checkout -b refactor/<slice-name>
```

Use `origin` instead of `upstream` if that is where you pull merged `main` from. Details and when to use parent-branch bases instead are in `docs/FEATURE_BRANCH_PLAN.md` §1 (“Starting the next slice from updated `main`”).

### After a branch is merged: what to do with completed branches (A/B/C…)

Once a PR is merged into `main` (either via stacked bases landing, or directly), **new work** should usually start from updated **`main`** (or the correct stacked parent).

**Keeping branches for mobile QA (preferred here):** we **retain** merged feature branch names on the remote/local clone for **device testing** and **small follow-up fixes**. Deleting them is **optional**, not required.

**Option A — merge `main` into a retained branch** (no force-push):

```bash
git checkout refactor/profile-feature    # example merged branch
git fetch origin
git merge origin/main
git push origin refactor/profile-feature
```

**If a PR is still open** (pre-merge): same idea—merge or rebase onto latest `origin/main` / parent to reduce conflicts; rebase is optional and needs **force-with-lease** only if you already pushed that branch and rewrote commits.

**Cleanup (optional):** delete local/remote branch names only when you are sure you will not QA or patch on that branch again.

### List worktrees

```bash
git worktree list
```

### Add a new worktree **and** create the next branch (from your current HEAD)

From the parent branch checkout (e.g. after `refactor/features-boundaries` is checked out):

```bash
git worktree add -b refactor/profile-feature ../wt-profile
```

Work inside it:

```bash
cd ../wt-profile
# edit under healthpilot/…
git add -A
git commit -m "refactor(profile): …"
git push -u origin refactor/profile-feature
```

### Remove a worktree after merge

```bash
git worktree remove ../wt-profile
git branch -d refactor/profile-feature   # local cleanup after merge
git worktree prune                         # if refs look stale
```

### When a parent branch merges into `main`

Rebase **your** open branch onto updated `main` (or onto the new remote default):

```bash
git fetch origin
git rebase origin/main
# if you had stacked on a feature branch that is now in main:
# git rebase origin/main
git push --force-with-lease
```

If the **parent is not merged yet**, rebase onto the parent branch instead:

```bash
git fetch origin
git rebase origin/refactor/features-boundaries
git push --force-with-lease
```

Only rebase branches **you** own unless the team agrees.

---

## 4) A→I plan mapped to branches + suggested PR bases

Aligned with `docs/FEATURE_BRANCH_PLAN.md` §2. **Base column** = GitHub PR target when stacking (adjust if your team merges to `main` earlier).

| Step | Branch | Suggested PR base (stacked) | One-line intent |
|------|--------|-----------------------------|-----------------|
| A | `refactor/features-boundaries` | `health-assessment` (or `main` if already merged) | Medication/subscription folders + imports |
| B | `refactor/profile-feature` | `refactor/features-boundaries` | Profile module + tab entry |
| C | `refactor/onboarding-flow` | `refactor/profile-feature` | Single onboarding controller |
| D | `refactor/subscription-feature` | **Deferred — run last** (see `FEATURE_BRANCH_PLAN.md` §2) | Subscription owns routing + entrypoints |
| E | `refactor/medication-feature` | **`main`** while D is deferred | Medication discoverable from health/home |
| F | `refactor/language-settings` | `refactor/medication-feature` | Language under profile/settings |
| G | `feat/tutorials` | `refactor/language-settings` | Tutorials module + Home entry |
| H | `refactor/navigation-cleanup` | `feat/tutorials` | Entry screens + fewer ad-hoc pushes |
| I | `chore/final-cleanup` | `refactor/navigation-cleanup` | Smoke + analyzer + dead code |

If a step is **skipped or merged to `main` early**, rebase the next branch onto **`origin/main`** and set PR base to `main`.

**2026-04-24:** Row **D** is intentionally **out of sequence**; complete **E** (and follow-on rows) first, then return to **D** when subscription work is in scope again.

---

## 5) Common mistakes

| Mistake | Why it hurts |
|--------|----------------|
| Creating every branch from `main` while stack is mid-flight | Duplicate/conflicting changes; painful rebases |
| Opening all PRs to `main` | GitHub shows huge conflicts; reviewer merges wrong order |
| Editing two features in one working tree | Easy to commit to wrong branch |
| Wrong PR base | Merges wrong diff; breaks stack |

---

## 6) PR description template (stacked)

```text
Stacked refactor (see docs/FEATURE_BRANCH_WORKTREE_PLAN.md).

Depends on: <parent-branch-name> (PR #___)
Scope: <one sentence>
```

---

## 7) Relation to `FEATURE_BRANCH_PLAN.md`

- **Roadmap + acceptance criteria:** stay in `docs/FEATURE_BRANCH_PLAN.md`.
- **How to run branches in parallel / stack PRs:** this file (`FEATURE_BRANCH_WORKTREE_PLAN.md`).
- **Decisions + file moves log:** `docs/BACKLOG.md`.

---

## 8) Next branch after profile: **always use a worktree** (Branch C)

From **this repo root** (`Health_Pilot_Flutter_project/`), with `refactor/profile-feature` at the commit you want to extend:

```bash
git fetch origin
git checkout refactor/profile-feature
git pull
git worktree add -b refactor/onboarding-flow ../wt-onboarding
cd ../wt-onboarding
```

Then do all Branch C work only under `../wt-onboarding/`. Push from that folder:

```bash
git push -u origin refactor/onboarding-flow
```

GitHub PR: base = `refactor/profile-feature` (stacked), unless your team has already merged the stack to `main`.
