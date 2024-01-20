#!/bin/sh

# Read the content from the file
#content=$(cat "$HOME/.git-credentials")

# Read the content from the file and trim leading/trailing whitespace
content=$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' "$HOME/.git-credentials")

# Copy the content to the clipboard
echo "$content" | xclip -selection clipboard

# Paste the copied content from the clipboard
#content=$(xclip -o -selection clipboard)
#echo "$content"
