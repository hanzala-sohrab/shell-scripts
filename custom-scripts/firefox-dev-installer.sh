#!/bin/zsh

if [ $# -eq 0 ];
then
	echo "$0: Missing arguments"
	exit 1
fi

file_name=$1

# Unpack the tar file
sudo tar xjf $file_name -C /opt/

# Remove the tar file
# rm -r $file_name

# Create a symlink of the executable binary
# sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox-dev

# Uninstall
# sudo rm -r /opt/firefox/

# Remove symlink
# sudo rm /usr/local/bin/firefox-dev

# Remove shortcut
# sudo rm /usr/share/applications/firefox-dev.desktop

# rm $HOME/Desktop/firefox-dev.desktop

