echo "Must have installed VBox Guest Additions"

sudo mkdir -p $2

sudo mount -t vboxsf -0 uid=1000,gid=1000 $1 $2

sudo printf '%s\t%s\tvboxsf\tuid=1000,gid=1000\t0\t0' $1 $2 >> /etc/fstab
