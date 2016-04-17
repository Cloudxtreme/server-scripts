#!/bin/bash


thishost=$(hostname)
printf '\n%s %s\n%s' 'Current Hostname:' $thishost 'Would you like to change it? (y/n) : '
read ans


if [ $ans == 'y' ] || [ $ans == 'Y' ]; then
    printf "\n%s\n%s" "Edit the hostname in /etc/hostname." "  - Press key to edit.."
    read
    sudo nano /etc/hostname

    printf "\n%s\n%s" "Edit the hostname for 127.0.0.1 in /etc/hosts." "  - Press key to edit.."
    read
    sudo nano /etc/hosts

    printf "\n%s" "Would you like to reboot now? (y/n) : "
    read ans2
    if [ $ans2 == 'y' ] || [ $ans2 == 'Y' ]; then
        sudo reboot now
    else
        printf "\n%s\n" "This change will not take effect until you reboot!"
    fi
fi
