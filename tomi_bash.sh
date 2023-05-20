#!/bin/bash

# Clear previous definition of the 'updating' function and alias
unalias updating &> /dev/null
sed -i '/function updating()/,/^}/d' ~/.bash_aliases

# Check if ~/.bashrc already sources ~/.bash_aliases, if not add it
if ! grep -q '. ~/.bash_aliases' ~/.bashrc; then
  echo '
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi' >> ~/.bashrc
fi

# Define the function in .bash_aliases
echo '
function updating() {
    sudo apt update -y
    sudo apt upgrade -y
    for pkg in $(apt list --upgradable 2>/dev/null | grep -v "Listing..." | awk -F"/" "{print $1}")
    do
        echo "Upgrading $pkg..."
        sudo apt install -y $pkg
    done
    sudo apt autoremove -y
    apt list -u
}' >> ~/.bash_aliases

# Make the changes take effect in your current terminal session
source ~/.bash_aliases

# Create a new script file
script_path="$HOME/fix_scroll.sh"
service_name="fix_scroll"

echo '#!/usr/bin/bash
synclient VertScrollDelta=-42
synclient HorizScrollDelta=-42' > $script_path

# Make sure the script is executable
chmod +x $script_path

# Add the script to cron
(crontab -l 2>/dev/null; echo "@reboot $script_path") | crontab -

# Create a systemd service file for the script
echo "[Unit]
Description=My Synclient Script

[Service]
ExecStart=$script_path

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/$service_name.service

# Reload the systemd daemon
sudo systemctl daemon-reload

# Enable the service to start on boot
sudo systemctl enable $service_name.service

# Start the service immediately
sudo systemctl start $service_name.service

# Remove telemetry
ubuntu-report -f send no
sudo apt remove -y popularity-contest

printf "\n\tFunction 'updating' has been added\n\tScroll boot script has been set up.\n\tTelemetry has been disabled.\n\tRemove 'Problem Reporting' in Settings > Privacy > Problem Reporting > Off\n"
