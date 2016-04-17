
# Example: bash post_vbox_install.sh torrent /mnt/torrents 109 119

echo "MUST have installed VBox Guest Additions"

sudo mkdir -p $2

sudo mount -t vboxsf -o uid=$3,gid=$4 $1 $2

echo
echo "Copy the following line to add to /etc/fstab"
echo
printf '%s\t%s\tvboxsf\tuid=%s,gid=%s,comment=systemd.automount\t0\t0\n' $1 $2 $3 $4


echo
echo "Press any key to enter /etc/fstab"
read
sudo nano /etc/fstab
