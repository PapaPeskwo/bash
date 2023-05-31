#!/bin/bash

# Clear previous definitions and functions
unalias updating &> /dev/null 2>/dev/null || true
sed -i '/function updating()/,/^}/d' ~/.bash_aliases 2>/dev/null || true

# Check if ~/.bashrc already sources ~/.bash_aliases, if not add it
if ! grep -q '. ~/.bash_aliases' ~/.bashrc; then
  echo '
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi' >> ~/.bashrc
fi

# If user is root, use no sudo, else use sudo
if [ $(id -u) -eq 0 ]; then
    SUDO=''
else
    SUDO='sudo'
fi

# Update/upgrade all those damn programs.
echo "
function updating() {
    $SUDO apt update -y
    $SUDO apt upgrade -y
    for pkg in \$($SUDO apt list --upgradable 2>/dev/null | grep -v 'Listing...' | cut -d' ' -f1 | awk -F/ '{print \$1}')
    do
        echo 'Upgrading \$pkg...'
        $SUDO apt install -y \$pkg
    done
    $SUDO apt autoremove -y
    apt list -u
}" >> ~/.bash_aliases

# Echo completion message
echo "The bash script has successfully executed. The 'updating' function has been added to ~/.bash_aliases."
if [ "$SUDO" == "sudo" ]; then
  echo "Note: This script uses 'sudo' for administrative permissions. You may be prompted for your password when using the 'updating' function."
else
  echo "Note: You are currently root user. The 'updating' function will be executed without using 'sudo'."
fi
printf "\n\t Don't forget to source ~/.bash_aliases!\n"
