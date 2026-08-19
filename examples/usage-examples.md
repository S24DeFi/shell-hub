# Example Usage Scenarios

## Scenario 1: Starting a New Development Day

```bash
# Navigate to workspace and see all projects
app

# Check status of a specific project
# (define your project shortcuts in scripts/personal.sh)
msg

# Start working on a new feature
newbranch
```

## Scenario 2: Running Tests

```bash
# Run all tests
yt

# Run tests with coverage report
ytc

# Run tests in watch mode for a specific file
yw src/components/button.test.ts

# Show only failing tests
ytf
```

## Scenario 3: Git Workflow

```bash
# Check current project status
msg

# Update master and merge changes
gcom
gmm

# Push changes
gpod

# Clean up old branches
cleanbranches
```

## Scenario 4: Development Setup

```bash
# Open browser without CORS restrictions
nocors

# Check development tool versions
vers

# Open coverage report
cvg
```

## Scenario 5: Project Navigation

```bash
# Quick project switching — define these in scripts/personal.sh:
# alias app1="app && cd your-app && msg"
# alias lib="app && cd your-library && msg"
tools       # Go to this utility project
app         # Go to workspace root
```

## Scenario 6: Searching and Discovery

```bash
# Find all git-related commands
showme git

# Find all yarn commands
showme yarn

# See all available aliases
list
```

## Common Command Combinations

### Daily Startup Routine

```bash
go          # Reload configurations
app         # See all projects
msg         # Check git status
```

### Pre-Push Checklist

```bash
msg         # Check status
yl          # Run linter
yb          # Build project
gpod        # Push to origin
```

### Testing Workflow

```bash
yt          # Run tests
ytc         # Run with coverage
cvg         # Open coverage report in browser
```
