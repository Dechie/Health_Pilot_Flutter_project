# Stacked PR workflow (after `main` moves)

Use this together with `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` and `docs/FEATURE_BRANCH_PLAN.md`.

## 1) When `main` advances (e.g. upgrade PR merged)

On each **open feature branch** that should stay compatible with `main`:

```bash
git fetch origin
git checkout <your-branch>
git merge origin/main
```

Resolve conflicts, run `flutter analyze`, commit the merge, push.

**Prefer `git merge origin/main`** on shared PR branches (less history rewrite than rebase).

## 2) When a **parent** branch in your stack advances (e.g. `health-assessment`)

Child branches (e.g. `refactor/features-boundaries`, then `refactor/profile-feature`) should **merge or rebase** the updated parent so they do not drift:

```bash
git fetch origin
git checkout refactor/features-boundaries
git merge origin/health-assessment
# resolve if needed, commit

git checkout refactor/profile-feature
git merge origin/refactor/features-boundaries
```

Expect occasional overlaps in **shared seams** (e.g. `home_page_screen.dart`). Resolve once per layer.

## 3) Keeping merge conflicts small

- Put feature work under **that feature’s directory** (`features/health_assessment/`, etc.).
- Touch **shared files** only when necessary; keep diffs **small** and documented in `docs/BACKLOG.md`.

## 4) Child branches: worktrees (from Branch C onward)

For parallel work without mixing trees:

```bash
git worktree add -b <new-branch> ../wt-<short-name>
```

See `docs/FEATURE_BRANCH_WORKTREE_PLAN.md` §3 and §8.

## 5) Force-push

Avoid `git push --force` on branches others base work on unless the team agrees. Use `--force-with-lease` only when you intentionally rewrote history.

## 6) Import cycles (assessment ↔ home)

`HomePageScreen` imports `AssessmentHistoryScreen`, which imports the assessment flow and (via `SummaryScreen`) `ResultBackToHomeScreen`. **Do not** import `HomePageScreen` from `result_back_to_home_screen.dart` (or other assessment screens on that chain) without refactoring, or Dart will report a circular import. Prefer navigating to `GeneralChatScreen` (or another leaf screen) instead of constructing `HomePageScreen` from that layer.

## 7) Assessment history → API (planning only)

Assessment completions are held in **`InMemoryAssessmentHistory`** today; that layer is intended to become the basis for **backend integration**, with **in-memory retained as a cache** of server-backed data. Details and file pointers: **`docs/BACKLOG.md`** (Decision log + Implementation log, **2026-04-18**). Update that backlog when API contracts or cache invalidation rules are decided.
