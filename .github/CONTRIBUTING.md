# Contributing to webui-lib-shellscripts

Thanks for contributing! This guide explains how to submit changes to the shell utilities library.

## Setup Your Environment

### 1. Install Required Tools

```bash
# ShellCheck (shell linter)
brew install shellcheck          # macOS
# or: sudo apt-get install shellcheck  # Linux

# shfmt (shell formatter)
brew install shfmt               # macOS
# or: GO111MODULE=on go install mvdan.cc/sh/v3/cmd/shfmt@latest  # Linux/any OS

# Lefthook (git hooks manager)
brew install lefthook            # macOS
# or: npm install -g @evilmartians/lefthook  # any OS
```

### 2. Install Git Hooks

```bash
cd /path/to/webui-lib-shellscripts
lefthook install
```

This sets up automatic validation on `git commit` and `git push`.

## Before You Start

1. **Auto-format your scripts** (optional but recommended):

   ```bash
   # Format all shell scripts with shfmt (2-space indentation)
   shfmt -i 2 -w scripts/*.sh setup.sh validate.sh
   ```

2. **Auto-format documentation** with Prettier (no install needed, runs via `npx`):

   ```bash
   npx --yes prettier --write "**/*.md"
   ```

3. **Test locally** with both bash and sh:

   ```bash
   bash -n scripts/your-script.sh
   sh -n scripts/your-script.sh
   ```

4. **Lint** with ShellCheck:

   ```bash
   shellcheck -x scripts/your-script.sh
   ```

5. **Validate** using our validation script:

   ```bash
   ./validate.sh
   ```

6. **Test in practice**:
   ```bash
   source scripts/hub.sh
   # Test your new functions/aliases
   ```

## Git Hooks (Automatic Checks)

Once you've run `lefthook install`, git will automatically:

**On `git commit`:**

- ✅ Run ShellCheck on staged .sh files
- ✅ Check formatting with shfmt
- ✅ Run quick validation

**On `git push`:**

- ✅ Run ShellCheck on all scripts
- ✅ Check formatting on all scripts
- ✅ Run full repository validation

To bypass hooks (not recommended): `git commit --no-verify`

## Writing Shell Scripts for This Repo

### Compatibility

- **Write POSIX-compatible shell code** unless bash-specific features are unavoidable
- Use `#!/bin/sh` shebangs when possible (not `#!/bin/bash`)
- When bash is required, use `#!/bin/bash` and document why
- Test in both bash and zsh before submitting

### Style Guidelines

```bash
# Function naming: use hyphens, not underscores
my-function() {
    local var="value"  # Always quote variables

    # Error handling
    if ! command -v git >/dev/null 2>&1; then
        printf "[my-function] Error: git is required\n" >&2
        return 1
    fi
}

# Aliases: clear, descriptive names
alias mycommand='actual-command --flag'
```

### Function Structure

```bash
# my-command — Brief description of what it does
# Purpose: Longer explanation if needed
# Usage: my-command [options]
# Example: my-command --verbose

my-command() {
    local option="${1:-default}"

    # Validate inputs
    if [ -z "$option" ]; then
        printf "[my-command] Error: option is required\n" >&2
        return 1
    fi

    # Function body
    echo "Processing: $option"
}
```

### No Hardcoded Personal Info

❌ **Don't do this:**

```bash
WORKSPACE="/Users/spence/Developer"
EMAIL="spence@s24defi.com"
```

✅ **Do this instead:**

```bash
WORKSPACE="${WORKSPACE:-$(cd ~/../.. && pwd)}"
EMAIL="${GIT_EMAIL:-your@example.com}"
```

## Submitting Changes

1. **Create a branch**:

   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes** to `scripts/*.sh` files

3. **Update CHANGELOG.md**:

   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD

   ### Added

   - New feature description

   ### Fixed

   - Bug fix description
   ```

4. **Update USAGE.md** if adding new commands

5. **Commit with clear messages**:

   ```bash
   git commit -m "Add my-command function for X purpose"
   ```

6. **Submit PR** with:
   - ✅ All tests passing
   - ✅ Shell compatibility verified (bash + sh/zsh)
   - ✅ No PII or hardcoded paths
   - ✅ Documentation updated
   - ✅ CHANGELOG.md entry

## Automated Checks

Our GitHub Actions CI will automatically:

- ✅ **ShellCheck Linting** — Checks for shell coding issues
- ✅ **Markdown Formatting (Prettier)** — Checks that docs are consistently formatted
- ✅ **Bash/POSIX Syntax** — Verifies syntax in bash and sh
- ✅ **Repository Validation** — Ensures all required files present
- ✅ **PII/Security Scan** — Checks for hardcoded paths, emails, keys
- ✅ **activate-hub Test** — Verifies project setup still works
- ✅ **hub.sh Integration** — Tests modular sourcing

Your PR will be reviewed once CI passes (look for the green checkmark ✅).

## Common Mistakes to Avoid

| ❌ Wrong                    | ✅ Right                           | Why                       |
| --------------------------- | ---------------------------------- | ------------------------- |
| `#!/bin/bash` for utilities | `#!/bin/sh` (POSIX)                | Maximum portability       |
| `$WORKSPACE` hardcoded      | `"${WORKSPACE:-.}"`                | Works for all users       |
| `email=spence@s24defi.com`  | `"${GIT_EMAIL:-user@example.com}"` | No personal info in code  |
| `source file.sh`            | `. file.sh`                        | POSIX compatible          |
| No error handling           | Return codes + stderr              | Easier debugging          |
| Single quoted vars          | Double quoted: `"$var"`            | Allows variable expansion |
| No function comments        | Include usage docs                 | Helps other developers    |

## Questions?

Check [USAGE.md](../USAGE.md) or [README.md](../README.md) for detailed documentation.
