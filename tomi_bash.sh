#!/bin/bash

# Clear previous definitions and functions
unalias updating &> /dev/null
sed -i '/function updating()/,/^}/d' ~/.bash_aliases
unalias r &> /dev/null
sed -i '/function r()/,/^}/d' ~/.bash_aliases

# Check if ~/.bashrc already sources ~/.bash_aliases, if not add it
if ! grep -q '. ~/.bash_aliases' ~/.bashrc; then
  echo '
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi' >> ~/.bashrc
fi

# Start a application in the terminal in the background
echo '
function r() {
    setsid "$@" >/dev/null 2>&1 < /dev/null &
}' >> ~/.bash_aliases


# Update/upgrade all those damn programs.
echo '
function updating() {
    sudo apt update -y
    sudo apt upgrade -y
    for pkg in $(apt list --upgradable 2>/dev/null | grep -v "Listing..." | cut -d" " -f1 | awk -F/ '\''{print $1}'\'')
    do
        echo "Upgrading $pkg..."
        sudo apt install -y $pkg
    done
    sudo apt autoremove -y
    apt list -u
}' >> ~/.bash_aliases

# Does not really work lol
source ~/.bash_aliases
source ~/.bashrc

# Make the laptop go to sleep when lid is closed
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=suspend/g' /etc/systemd/logind.conf
#sudo systemctl restart systemd-logind
printf "\nPlease reboot your computer for the changes to take effect.\n"

# Create a new script file (kinda redundant)
script_path="$HOME/fix_scroll.sh"
service_name="fix_scroll"

# Correct scroll direction 💕
echo '#!/usr/bin/bash
synclient VertScrollDelta=-42
synclient HorizScrollDelta=-42' > $script_path

# Make sure the script is executable, don't think it works?
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

# Scroll should now work on reboot/boot. No more manual script-running! :D

# Remove telemetry 🤮
ubuntu-report -f send no
sudo apt remove -y popularity-contest

# Fuck you Microsoft. Remove .NET telemetry.
if ! sudo grep -q 'DOTNET_CLI_TELEMETRY_OPTOUT=1' /etc/environment; then
    echo 'DOTNET_CLI_TELEMETRY_OPTOUT=1' | sudo tee -a /etc/environment > /dev/null
fi
source /etc/environment
printf "\n/etc/environment:\n"
cat /etc/environment

printf "\n\tFunction 'updating' has been added\n\tScroll boot script has been set up.\n\tTelemetry has been disabled.\n\tRemove 'Problem Reporting' in Settings > Privacy > Problem Reporting > Off\n\tLaptop is set to sleep when lid is closed.\n"
