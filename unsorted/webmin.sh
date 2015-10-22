mkdir tmp
cd tmp
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.620_all.deb
sudo apt-get install libnet-ssleay-perl libapt-pkg-perl libauthen-pam-perl libio-pty-perl libapt-pkg-perl apt-show-versions
sudo dpkg -i *.deb
cd .. && rm -rf tmp
sudo /usr/share/webmin/changepass.pl /etc/webmin root jessandjosh10
