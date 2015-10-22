printf "\n%s\n\n" "** Installing Transmission **"
sudo apt-get install -y transmission-cli transmission-common transmission-daemon

printf "\n%s\n\n" "** Stopping transmission-daemon"
sudo service transmission-daemon stop

sudo nano /etc/transmission-daemon/settings.json
sudo cp /etc/transmission-daemon/settings.json ./settings.json.bak
sudo chown josh settings.json.bak
sudo chgrp josh settings.json.bak

printf "\n%s\n\n" "** Starting transmission-daemon"
sudo service transmission-daemon start
