# GitHub Setup Instructions

The local git repo is ready to push. Follow these steps to publish to GitHub.

## 1. Authenticate GitHub CLI

```bash
gh auth login
# Select: GitHub.com
# Select: HTTPS
# Authenticate and authorize in browser
```

## 2. Create Remote Repository

```bash
cd ~/.openclaw/extensions/skill-preflight
gh repo create openclaw-skill-preflight --public --source=. --remote=origin --push
```

This will:
- Create a new public repo `thekhemistai/openclaw-skill-preflight`
- Set it as the origin remote
- Push all commits

## 3. Verify

```bash
git remote -v
# Should show:
# origin  https://github.com/thekhemistai/openclaw-skill-preflight.git (fetch)
# origin  https://github.com/thekhemistai/openclaw-skill-preflight.git (push)

git log --oneline
# Should show:
# c9e6d05 Fix plugin ID mismatch: use scoped package name
# 3d334f9 Add ROADMAP, CONTRIBUTING, LICENSE, and .gitignore
# f77e4dc Initial commit: skill-preflight plugin ready for publication
```

## 4. Add GitHub Topics (Optional)

In the repository Settings → About section, add these topics:
- `openclaw`
- `plugin`
- `rag`
- `embeddings`
- `agent`

## 5. Publish to npm (When Ready)

```bash
# Publish to npm
npm publish --access public

# Or publish as pre-release for testing
npm publish --tag next
```

## 6. Publish to ClawHub

```bash
# Get current commit SHA
COMMIT=$(git rev-parse HEAD)

# Publish to clawhub
clawhub package publish . --source-repo thekhemistai/openclaw-skill-preflight --source-commit $COMMIT
```

Or use the web interface: clawhub.ai/upload

---

All code is committed and ready. Just authenticate and push!
