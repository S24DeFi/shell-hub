# Description

Provide a brief summary of changes to the shell utility library.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] New script/module
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring/Code organization
- [ ] Performance improvement
- [ ] CI/CD or tooling update

## Changes Made

- List the key changes made in this PR
- Use bullet points for clarity
- Reference which scripts/functions were modified (e.g., `scripts/base.sh`, `activate-hub()`)

**Files Changed:**

- <!-- e.g. scripts/base.sh -->

## Shell Compatibility

- [ ] Tested in **bash** (v4.0+)
- [ ] Tested in **zsh** (v5.0+)
- [ ] Uses only POSIX-compatible syntax (no bash-isms)
- [ ] Verified with `bash -n` and `sh -n` syntax checking

## Testing

- [ ] Verified with `./validate.sh`
- [ ] Tested with `source scripts/hub.sh`
- [ ] Tested `activate-hub` in a test project
- [ ] Verified existing aliases/functions work: `cleanbranches`, `newbranch`, `syncenv`, etc.
- [ ] Checked that no hardcoded paths or personal info were added
- [ ] Ran `bash -n` on modified scripts

## Impact

**Affected Components:**

- [ ] `setup.sh` installation flow
- [ ] `hub.sh` modular sourcing
- [ ] Project initialization (`activate-hub`)
- [ ] Git workflow functions
- [ ] Network utilities
- [ ] Automation workflows

**Breaking Changes?** (describe if yes)

- **Migration Path** (if breaking):

- <!-- Describe the migration steps for existing users -->

## Documentation

- [ ] Updated `USAGE.md` with new commands or options
- [ ] Updated `README.md` if new features affect installation/setup
- [ ] Added/updated inline function comments
- [ ] Updated `CHANGELOG.md` entry

## Security & PII Check

- [ ] No hardcoded paths (e.g., `/Users/username`, `/home/user`)
- [ ] No API keys, tokens, or passwords
- [ ] No personal email addresses or account IDs
- [ ] All credentials are environment-variable-based or prompted by setup

## Code Quality

- [ ] Follows existing code style (indentation, naming conventions)
- [ ] Consistent error handling with proper stderr output
- [ ] Functions include usage documentation
- [ ] No unnecessary external dependencies

## Reference

Related issue/ticket: <!-- Link if applicable -->

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Changes tested locally (bash + zsh)
- [ ] All syntax checks pass
- [ ] No PII or sensitive data in commit
- [ ] Documentation updated
- [ ] Changelog updated
