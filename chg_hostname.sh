printf "\n%s\n%s" "1. Edit the hostname in /etc/hostname." "  - Press key to edit.."
read
sudo nano /etc/hostname

printf "\n%s\n%s" "2. Edit the hostname for 127.0.0.1 in /etc/hosts." "  - Press key to edit.."
read
sudo nano /etc/hosts

printf "\n%s" "3. Press key to reboot now.."
read
sudo reboot now
