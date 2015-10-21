# Example: bash set_vbox_shared.sh "Transmission Server" torrents /mnt/media/Torrents
echo
echo "Make sure you are vboxuser first!"
echo
VBoxManage sharedfolder add "$1" -name $2 -hostpath $3

