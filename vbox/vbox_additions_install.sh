sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms

sudo apt-get install -y xserver-xorg xserver-xorg-core

printf "\n%s\n\n" "*** Must have VBoxGuestAdditions.iso in cdrom!!"
sudo mkdir /media/cdrom

sudo mount /dev/cdrom /media/cdrom

cd /media/cdrom

sudo ./VBoxLinuxAdditions.run

printf "\n%s\n\n" "*** Rebooting NOW!"
#sudo reboot now
