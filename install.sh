#!/usr/bin/env bash

# Exit immediately if a command fails, if an undefined variable is used,
# or if a command in a pipeline fails.
set -euo pipefail

# Get the absolute path of the directory where this script lives.
# This ensures symlinks point to the correct place no matter where you run the script from.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Color codes for prettier output.
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color (reset)

# ============================================================================
# EXTENDABLE MAPPINGS
# ============================================================================
# Each entry is "source_folder:target_folder".
# The script will loop through every item inside source_folder and symlink
# it into target_folder.
#
# To add more folders later, just add a new line here.
# Example: "bin:$HOME/.local/bin"
# ============================================================================
mappings=(
    "configs:$HOME/.config"
)

# Loop through each "source:target" mapping defined above.
for mapping in "${mappings[@]}"; do

    # ------------------------------------------------------------------------
    # Step 1: Split the mapping into source and target parts.
    # ------------------------------------------------------------------------
    # "${mapping%%:*}"  -> everything BEFORE the first colon (the source dir)
    # "${mapping#*:}"   -> everything AFTER  the first colon (the target dir)
    src_dir="${mapping%%:*}"
    tgt_dir="${mapping#*:}"

    # Build the full absolute path to the source folder inside the dotfiles repo.
    src_path="$DOTFILES_DIR/$src_dir"

    # ------------------------------------------------------------------------
    # Step 2: Skip if the source folder doesn't exist.
    # ------------------------------------------------------------------------
    # This prevents errors if you define a mapping but haven't created the folder yet.
    if [ ! -d "$src_path" ]; then
        continue
    fi

    # ------------------------------------------------------------------------
    # Step 3: Ensure the target directory exists.
    # ------------------------------------------------------------------------
    # "mkdir -p" creates parent directories as needed and does nothing if it already exists.
    mkdir -p "$tgt_dir"

    # ------------------------------------------------------------------------
    # Step 4: Loop through every item inside the source folder.
    # ------------------------------------------------------------------------
    # The "$src_path"/* glob expands to files/folders inside src_path.
    # The "[ -e "$item" ] || continue" guard handles the case where the folder is empty
    # (the glob would literally return "$src_path/*" as a string).
    for item in "$src_path"/*; do
        [ -e "$item" ] || continue

        # Get just the name of the file/folder, e.g. "nvim" from ".../configs/nvim"
        name=$(basename "$item")

        # Build the full path where the symlink should live.
        tgt="$tgt_dir/$name"

        # ----------------------------------------------------------------
        # Step 5: Check if the exact symlink already exists.
        # ----------------------------------------------------------------
        # "[ -L "$tgt" ]"           -> is it a symbolic link?
        # "$(readlink "$tgt")"      -> what path does the symlink point to?
        # If both match our source item, we skip it (idempotent).
        if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$item" ]; then
            printf "${YELLOW}%-20s -> skipped${NC}\n" "$name"
            continue
        fi

        # ----------------------------------------------------------------
        # Step 6: If something else is blocking the path, skip it.
        # ----------------------------------------------------------------
        # "[ -e "$tgt" ]" checks for any file, directory, or symlink.
        # If something already exists here and it's NOT the correct symlink
        # from Step 5, we warn the user and skip so we don't overwrite anything.
        if [ -e "$tgt" ] || [ -L "$tgt" ]; then
            printf "${RED}%-20s -> blocked (already exists)${NC}\n" "$name"
            continue
        fi

        # ----------------------------------------------------------------
        # Step 7: Create the symlink.
        # ----------------------------------------------------------------
        # "ln -s" creates a symbolic link from $tgt pointing back to $item.
        ln -s "$item" "$tgt"
        printf "${GREEN}%-20s -> linked${NC}\n" "$name"
    done
done

# Final success message.
echo ""
echo -e "${GREEN}Done!${NC}"
