#!/bin/bash

# --- CONFIGURATION ---
# File where the history of directories will be stored
CD_HISTORY_FILE="$HOME/.cd_history"

# --- FUNCTIONS ---

# 1. History Logging Function
# Logs the current directory path, ensuring it's an absolute path.
_cd_log_history() {
    local current_dir=$(pwd -P) # -P ensures physical path (no symlinks)

    # Check if the history file exists, if not, create it.
    if [[ ! -f "$CD_HISTORY_FILE" ]]; then
        echo "# cd_history file created on $(date)" > "$CD_HISTORY_FILE"
    fi

    # Optimization: Prevent adding the exact same directory path consecutively.
    # We read the last few lines of the file to check if the path is already there.
    local last_entries=$(tail -n 5 "$CD_HISTORY_FILE" | grep "$current_dir$")

    if [[ -z "$last_entries" ]]; then
        echo "$current_dir" >> "$CD_HISTORY_FILE"
    fi
}

# 2. The Main Wrapper Function (Overrides built-in 'cd')
# This function intercepts all calls to 'cd'.
cd() {
    # 1. LOGGING: Always log the directory we are leaving.
    _cd_log_history

    # 2. ARGUMENT HANDLING: Check if the user provided a target directory argument.
    if [ $# -gt 0 ]; then
        # Standard behavior: User explicitly provided a path (e.g., cd /etc/ssh)
        # We skip fzf and use the standard built-in 'cd' command.
        builtin cd "$@"
        return $?
    fi

    # 3. INTERACTIVE HISTORY SEARCH: No arguments provided (just "cd").
    echo ""
    echo "--- CD History Search ---"
    echo "Select a directory from your history list:"
    echo "-------------------------"

    # Check if fzf is available
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf could not be found. Please install it (e.g., 'sudo apt install fzf')."
        echo "Falling back to standard 'cd' behavior..."
        builtin cd
        return $?
    fi

    # Use fzf on the history file content
    local selected_dir=$(
        cat "$CD_HISTORY_FILE" | \
        grep -vE '^(#|$)' | \
        fzf --header="Select directory (Use 'Ctrl+C' to cancel search)" --reverse
    )

    # Check if the user selected a directory
    if [ -n "$selected_dir" ]; then
        echo ""
        echo "=> Changing directory to: $selected_dir"
        # Perform the actual directory change
        builtin cd "$selected_dir"
        return $?
    else
        # User pressed ESC or Ctrl+C
        echo ""
        echo "Search cancelled. Remaining in current directory."
        # Replicate the behavior of calling 'cd' with no args (usually returns to HOME)
        builtin cd
        return $?
    fi
}

# 3. Installation Function
# This function overwrites the existing 'cd' command with our wrapper.
install_cd_wrapper() {
    # Ensure the wrapper function replaces the built-in command
    export -f cd
    echo "✅ Successfully installed custom 'cd' wrapper."
    echo "You can now use 'cd' and it will prompt for history lookup."
}
