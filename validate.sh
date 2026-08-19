#!/bin/bash

# Validation script to test the tool-development-utility setup
# This script can be used by peer reviewers to verify functionality

echo "Validating Shell Script Utilities Setup..."
echo

# Check required files exist
echo "Checking file structure..."
required_files=(
    "setup.sh"
    "README.md"
    "USAGE.md"
    "CHANGELOG.md"
    "config/bash-template.txt"
    "config/gitconfig-template.txt"
    "scripts/helpers.sh"
    "scripts/base.sh"
    "scripts/automation.sh"
    "scripts/personal.sh"
    "scripts/contrib.txt"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  [Y] $file"
    else
        echo "  [N] $file (MISSING)"
    fi
done

echo

# Check setup script syntax
echo "Validating setup.sh syntax..."
if bash -n setup.sh; then
    echo "  [Y] setup.sh syntax is valid"
else
    echo "  [N] setup.sh has syntax errors"
fi

echo

# Check for executable permissions
echo "Checking permissions..."
if [ -x setup.sh ]; then
    echo "  [Y] setup.sh is executable"
else
    echo "  [N] setup.sh needs execute permission (run: chmod +x setup.sh)"
fi

echo

# Check scripts directory
echo "Validating scripts..."
script_count=$(find scripts -name "*.sh" -o -name "*.txt" 2>/dev/null | wc -l | tr -d ' ')
echo "  Found $script_count script files in scripts/ directory"

if [ "$script_count" -ge 5 ]; then
    echo "  [Y] Scripts directory properly populated"
else
    echo "  [W] Expected at least 5 script files"
fi

# Check for helpers.sh (required dependency)
if [ -f "scripts/helpers.sh" ]; then
    echo "  [Y] helpers.sh found (required dependency)"
else
    echo "  [N] helpers.sh missing (required for other scripts)"
fi

echo

# Test cleanup functionality
echo "Testing cleanup detection..."
if grep -q "cleanup" setup.sh; then
    echo "  [Y] Cleanup functionality present in setup.sh"
else
    echo "  [N] Cleanup functionality not found"
fi

echo

# Test shell compatibility
echo "Testing shell compatibility..."
if grep -q "BASH_VERSION\|ZSH_VERSION" setup.sh; then
    echo "  [Y] Shell compatibility detection present"
else
    echo "  [N] Shell compatibility detection not found"
fi

# Check for helpers.sh loading in setup
echo "Testing helpers.sh integration..."
if grep -q "helpers.sh" setup.sh; then
    echo "  [Y] helpers.sh integration found in setup.sh"
else
    echo "  [W] helpers.sh integration not found in setup.sh"
fi

echo

echo "Validation complete!"
echo
echo "To test full functionality:"
echo "   1. Run: ./setup.sh"
echo "   2. Follow the prompts"
echo "   3. Test: source ~/.zshrc"
echo "   4. Verify: go (should reload without errors)"
echo
