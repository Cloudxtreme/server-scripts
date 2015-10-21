# Example: bash post_vbox_install.sh torrent /mnt/torrents/

echo "Must have installed VBox Guest Additions"

sudo mkdir -p $2

sudo mount -t vboxsf -o uid=1000,gid=1000 $1 $2

echo
echo "Copy the following line to add to /etc/fstab"
echo
printf '%s\t%s\tvboxsf\tuid=1000,gid=1000\t0\t0' $1 $2

echo
echo
echo "Press any key to enter /etc/fstab"
read
sudo nano /etc/fstab
