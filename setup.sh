#!/bin/bash

# Shell Script Utilities Setup
# This script sets up the shell utility environment
# Usage: 
#   ./setup.sh           - Normal setup
#   ./setup.sh cleanup   - Remove existing configuration

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
CONFIG_START_MARKER="# >>> Shell Script Utilities >>>"
CONFIG_END_MARKER="# <<< Shell Script Utilities <<<"

remove_config_block() {
    local rc_file="$1"
    local tmp_file

    [ -f "$rc_file" ] || return 1

    tmp_file="${rc_file}.tmp"

    if grep -qF "$CONFIG_START_MARKER" "$rc_file"; then
        sed "/$CONFIG_START_MARKER/,/$CONFIG_END_MARKER/d" "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"
        return 0
    elif grep -q "# Shell Script Utilities - CONFIGURED" "$rc_file"; then
        # Legacy cleanup support for previously generated blocks.
        sed '/# Shell Script Utilities - CONFIGURED/,/^$/d' "$rc_file" > "$tmp_file" && mv "$tmp_file" "$rc_file"
        return 0
    fi

    return 1
}

# Handle cleanup mode
if [ "$1" = "cleanup" ]; then
    echo -e "${BLUE}Cleaning up Shell Script Utilities configuration...${NC}"

    if remove_config_block "$HOME/.zshrc"; then
        echo -e "${GREEN}Removed Shell Script Utilities configuration from ~/.zshrc${NC}"
    fi

    if remove_config_block "$HOME/.bashrc"; then
        echo -e "${GREEN}Removed Shell Script Utilities configuration from ~/.bashrc${NC}"
    fi
    
    # Remove generated config files
    rm -f "$CONFIG_DIR/bash-config.txt"
    rm -f "$CONFIG_DIR/gitconfig-personal.txt"
    echo -e "${GREEN}Removed generated configuration files${NC}"
    
    echo -e "${GREEN}Cleanup completed!${NC}"
    exit 0
fi

echo -e "${BLUE}Setting up Shell Script Utilities...${NC}"

# Check if already configured
check_if_configured() {
    if { [ -f "$HOME/.zshrc" ] && grep -qE "# Shell Script Utilities - CONFIGURED|# >>> Shell Script Utilities >>>" "$HOME/.zshrc"; } || \
       { [ -f "$HOME/.bashrc" ] && grep -qE "# Shell Script Utilities - CONFIGURED|# >>> Shell Script Utilities >>>" "$HOME/.bashrc"; }; then
        echo -e "${YELLOW}Shell Script Utilities already configured in ~/.zshrc or ~/.bashrc${NC}"
        echo -e "${YELLOW}If you want to reconfigure, please run cleanup first:${NC}"
        echo -e "${BLUE}  ./setup.sh cleanup${NC}"
        echo -e "${BLUE}Then run the setup again:${NC}"
        echo -e "${BLUE}  ./setup.sh${NC}"
        exit 0
    fi
}

# Function to prompt for user input
prompt_for_input() {
    local prompt="$1"
    local var_name="$2"
    local default_value="$3"
    
    if [ -n "$default_value" ]; then
        read -r -p "$prompt [$default_value]: " user_input
        # shellcheck disable=SC2034 # user_input is consumed via eval below
        eval "$var_name=\"\${user_input:-\$default_value}\""
    else
        # shellcheck disable=SC2034 # user_input is consumed via eval below
        read -r -p "$prompt: " user_input
        eval "$var_name=\"\$user_input\""
    fi
}

escape_for_double_quotes() {
    # shellcheck disable=SC2016 # single quotes are intentional: literal backtick, not expansion
    printf '%s' "$1" | sed \
        -e 's/\\/\\\\/g' \
        -e 's/"/\\"/g' \
        -e 's/\$/\\$/g' \
        -e 's/`/\\`/g'
}

find_default_workspace() {
    local current_workspace repo_name candidate current_repo_physical candidate_repo_physical
    current_workspace="$(cd "$SCRIPT_DIR/.." && pwd)"
    repo_name="$(basename "$SCRIPT_DIR")"
    current_repo_physical="$(cd "$SCRIPT_DIR" && pwd -P)"

    for candidate in "$HOME/alias-workspace" "$HOME/workspace"; do
        if [ -L "$candidate" ] && [ -d "$candidate/$repo_name" ]; then
            candidate_repo_physical="$(cd "$candidate/$repo_name" && pwd -P)"
            if [ "$candidate_repo_physical" = "$current_repo_physical" ]; then
                printf '%s' "$candidate"
                return 0
            fi
        fi
    done

    printf '%s' "$current_workspace"
}

# Collect user information
echo -e "${YELLOW}Please provide the following information:${NC}"

# Check if already configured first
check_if_configured

prompt_for_input "Your first.last name" "USERNAME" "$(whoami)"
prompt_for_input "Your org/employee ID (optional, press Enter to skip)" "USERID" ""
prompt_for_input "Your JIRA account ID (optional, press Enter to skip)" "JIRA_USERID" ""
prompt_for_input "Your GitHub username" "CODE_ID" ""
# Prefer an ASCII-only workspace symlink when one points at this repo.
DEFAULT_WORKSPACE="$(find_default_workspace)"
if [ "$DEFAULT_WORKSPACE" != "$(cd "$SCRIPT_DIR/.." && pwd)" ]; then
    echo -e "${BLUE}Using detected workspace symlink: $DEFAULT_WORKSPACE${NC}"
fi
prompt_for_input "Your workspace path" "WORKSPACE" "$DEFAULT_WORKSPACE"

# Create personalized bash template
echo -e "${BLUE}Creating personalized bash configuration...${NC}"
BASH_CONFIG="$CONFIG_DIR/bash-config.txt"

ESCAPED_USERNAME="$(escape_for_double_quotes "$USERNAME")"
ESCAPED_USERID="$(escape_for_double_quotes "$USERID")"
ESCAPED_JIRA_USERID="$(escape_for_double_quotes "$JIRA_USERID")"
ESCAPED_CODE_ID="$(escape_for_double_quotes "$CODE_ID")"
ESCAPED_WORKSPACE="$(escape_for_double_quotes "$WORKSPACE")"
ESCAPED_SCRIPT_DIR="$(escape_for_double_quotes "$SCRIPT_DIR")"

cat > "$BASH_CONFIG" << EOF
#!/bin/bash
$CONFIG_START_MARKER
# Shell Script Utilities - CONFIGURED
# Generated Shell Script Utilities Configuration
# Generated on: $(date)

UserName="$ESCAPED_USERNAME"
UserId="$ESCAPED_USERID"
JiraUserid="$ESCAPED_JIRA_USERID"
CodeId="$ESCAPED_CODE_ID"
Workspace="$ESCAPED_WORKSPACE"
Me="/Users/\$UserName"
BashShells="$ESCAPED_SCRIPT_DIR"

# Load all shell scripts (with proper glob handling)
# Helpers must load first as other scripts depend on its functions
if [ -f "\$BashShells/scripts/helpers.sh" ]; then
    source "\$BashShells/scripts/helpers.sh"
fi

# Check if we're in bash or zsh and handle accordingly
if [ -n "\$BASH_VERSION" ]; then
    # Bash
    shopt -s nullglob
    for f in "\$BashShells/scripts"/*.sh; do 
        # Skip helpers.sh as it's already loaded
        if [ -f "\$f" ] && [ "\$(basename "\$f")" != "helpers.sh" ]; then
            source "\$f"
        fi
    done
    shopt -u nullglob
elif [ -n "\$ZSH_VERSION" ]; then
    # Zsh - use different approach
    setopt NULL_GLOB
    for f in "\$BashShells/scripts"/*.sh; do 
        # Skip helpers.sh as it's already loaded
        if [ -f "\$f" ] && [ "\$(basename "\$f")" != "helpers.sh" ]; then
            source "\$f"
        fi
    done
    unsetopt NULL_GLOB
else
    # Generic shell - check if files exist first
    if ls "\$BashShells/scripts"/*.sh 1> /dev/null 2>&1; then
        for f in "\$BashShells/scripts"/*.sh; do 
            # Skip helpers.sh as it's already loaded
            if [ -f "\$f" ] && [ "\$(basename "\$f")" != "helpers.sh" ]; then
                source "\$f"
            fi
        done
    fi
fi

# Load contrib script if it exists
if [ -f "\$BashShells/scripts/contrib.txt" ]; then
    alias contrib='bash "\$BashShells/scripts/contrib.txt"'
fi
$CONFIG_END_MARKER
EOF

# Backup existing configurations
echo -e "${BLUE}Backing up existing configurations...${NC}"
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backed up existing .zshrc${NC}"
fi

if [ -f "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backed up existing .bashrc${NC}"
fi

if [ -f ~/.gitconfig ]; then
    cp ~/.gitconfig ~/.gitconfig.backup."$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backed up existing .gitconfig${NC}"
fi

# Setup Git configuration
echo -e "${BLUE}Setting up Git configuration...${NC}"
prompt_for_input "Your Git email" "GIT_EMAIL" "$USERNAME@example.com"

# Create personalized gitconfig
sed "s/githubUserName/$USERNAME/g; s/your\.email@example\.com/$GIT_EMAIL/g" \
    "$CONFIG_DIR/gitconfig-template.txt" > "$CONFIG_DIR/gitconfig-personal.txt"

# Ask user if they want to apply configurations
echo -e "${YELLOW}Do you want to apply the configurations now? (y/n)${NC}"
read -r apply_config

if [ "$apply_config" = "y" ] || [ "$apply_config" = "Y" ]; then
    # Apply primary shell configuration (zsh on modern macOS)
    cat "$BASH_CONFIG" >> "$HOME/.zshrc"
    echo -e "${GREEN}Applied shell configuration to ~/.zshrc (primary)${NC}"

    echo -e "${YELLOW}Also apply to ~/.bashrc for compatibility? (y/n)${NC}"
    read -r apply_bash_compat
    if [ "$apply_bash_compat" = "y" ] || [ "$apply_bash_compat" = "Y" ]; then
        cat "$BASH_CONFIG" >> "$HOME/.bashrc"
        echo -e "${GREEN}Applied shell configuration to ~/.bashrc (compatibility)${NC}"
    fi
    
    # Apply git configuration
    cat "$CONFIG_DIR/gitconfig-personal.txt" > ~/.gitconfig
    echo -e "${GREEN}Applied git configuration to ~/.gitconfig${NC}"
    
    echo -e "${GREEN}Setup complete! Please run 'source ~/.zshrc' (or restart your terminal).${NC}"
    echo -e "${BLUE}You can now use 'go' command to reload configurations.${NC}"
else
    echo -e "${YELLOW}Configurations created but not applied.${NC}"
    echo -e "${YELLOW}Manual setup files created in: $CONFIG_DIR${NC}"
fi

# Make scripts executable
chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true

echo -e "${GREEN}Setup script completed successfully!${NC}"
