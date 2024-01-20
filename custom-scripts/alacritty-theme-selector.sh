#!/bin/sh

sed -i -E "s/themes\/[a-zA-Z0-9_\-]+\.yaml/themes\/$1\.yaml/g" ~/.config/alacritty/alacritty.yml
