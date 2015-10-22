clear
#
FIRST_ACCT_NAME="user"
FIRST_ACCT_PW="password"
EMU_SHORT_NAME="SMALLEQEMU"
EMU_LONG_NAME="Rebellion"
EXT_IP=`ifconfig eth0 | grep "inet addr:" | awk -F: '{ print $2 }' | awk '{ print $1 }'`
#
echo ' '
echo ' ################################################# '
echo " ### Josh's EQEQMU Installer Version 1.0 ### "
echo ' ### Author : Joshua Phipps Date : 16 April 2013 ### '
echo ' ################################################# '
echo ' '
echo ' ================================================= '
echo ' === So easy, a complete git could do it... === '
echo ' === This script was made so that a person === '
echo ' === could get a eqemu installed and running === '
echo ' === on a virgin Ubuntu server within less === '
echo ' === than an hour and with the LEAST amount === '
echo ' === of file editing and complex stuff! === '
echo ' ================================================= '
echo ' '
echo "Your current eth0 (second network card) is set to "
echo "the IP address of $EXT_IP."
echo ' '
echo "That address will be used in all the configuration files."
echo ' '
echo '+--------------------------------------------------------------+'
echo '! About to start installing. !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+'
echo ' '
cd /home
#
# Change the sysctl.conf to reflect the sharedmem parameter change
# This should take far less than a second. Should require root.
#
cp /etc/sysctl.conf /etc/sysctl.conf_original
grep -v "kernel.shm" /etc/sysctl.conf | grep -v "TJL" > /etc/new_sysctl.conf
mv /etc/new_sysctl.conf /etc/sysctl.conf
echo "# added by TJL - 2012-02-27 for eqemu" >> /etc/sysctl.conf
echo "kernel.shmmax = 134217728" >> /etc/sysctl.conf
echo "kernel.shmall=65536" >> /etc/sysctl.conf
echo ' '
echo '+--------------------------------------------------------------+'
echo '! Modified sysctl !'
echo '! About to install packages as needed. !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+'
echo ' '
#
# Removing eqemu directories, if they exist.
#
rm -rf /home/eqemu
#
# If user eqemu does not exist, it will give a tiny error message
# but it will be swallowed up in the huge list of packages that
# mercifully scroll past.
userdel eqemu
useradd eqemu
#
# Update package list
#
apt-get clean
apt-get update
#
# Thus is the first critical part...
# It installs all the needed packages...
# So you don't have to!
#
apt-get -y install subversion gcc g++ cpp libmysqlclient-dev libio-stringy-perl
apt-get -y install cvs zlib-bin zlibc unzip make
apt-get -y install git libperl-dev mysql-client-5.5
#
echo ' '
echo '+--------------------------------------------------------------+'
echo '! About to install database server (if needed) !'
echo '! !'
echo '! Please be aware that the database server installation will !'
echo '! ask for a root password THREE TIMES! !'
echo '! !'
echo '! Each time that it asks, just hit ENTER to choose NO PASSWORD !'
echo '! !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+'
echo ' '
apt-get -y install mysql-server
#
# Once the server software is installed, the my.cnf exists, but it
# binds to localhost or 127.0.0.1 and I think that the real IP
# is a better point. So this next part changes the bind address
# automatically.
#
cat /etc/mysql/my.cnf | sed s/bind-address.*/bind-address=$EXT_IP/ > tmp.cnf
cp tmp.cnf /etc/mysql/my.cnf
#
echo ' '
echo '+--------------------------------------------------------------+'
echo '! Downloading all the source-code, maps, db stuff from the net.!'
echo '! !'
echo '! This could take a few minutes and there might be pauses,,, !'
echo '+--------------------------------------------------------------+'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+ '
echo ' '
#
# Prepare everything by making the necessary directories
#
mkdir -p /home/eqemu/server/logs
mkdir -p /home/eqemu/source
mkdir -p /home/eqemu/server/Maps
mkdir -p /home/eqemu/server/quests
mkdir -p /home/eqemu/server/plugins
mkdir -p /home/eqemu/server/shared
#
# Make sure we are about to pull everything into the right directories..
#
cd /home/eqemu/source
#
# Second critical part -- getting all the most recent code,
# database items, quests, maps and plugins from the source.
# With super-fast connection speeds, this may still take a few
# minutes.
#
git clone git://github.com/EQEmu/Server.git .
svn co http://projecteqdb.googlecode.com/svn/trunk/peqdatabase
svn co http://projecteqquests.googlecode.com/svn/trunk/quests
svn co http://eqemumaps.googlecode.com/svn/trunk/Maps
svn co http://allaclone-eoc.googlecode.com/svn/trunk/ allaclone-eoc-read-only
cd /home/eqemu/source/dependencies
wget https://projecteqemu.googlecode.com/files/ubuntu_LoginServerCrypto_x86.zip
unzip *.zip
rm -rf *.zip
cd ..
#
# Now copy from the SOURCE directories to the SERVER directories
# as needed. Might take a bit.
#
cp -r /home/eqemu/source/Maps/* /home/eqemu/server/Maps/
cp -r /home/eqemu/source/quests/* /home/eqemu/server/quests/
chmod --recursive ugo+rwx /home/eqemu/server/quests/
cp -r /home/eqemu/source/quests/plugins/* /home/eqemu/server/plugins/
chmod --recursive ugo+rwx /home/eqemu/server/plugins/
#
echo ' '
echo '+--------------------------------------------------------------+ '
echo '! Loading the database (could take a few minutes)... !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+ '
echo ' '
echo ' Loading database -- please wait... '
echo ' '
cd /home/eqemu/source/peqdatabase/
#
# Set the root DB password to passw0rd
# Creating eqemu user with initial password to eqemupw
#
echo "set password for 'root'@'localhost' = PASSWORD('passw0rd');" > /home/eqemu/server/logs/db_users.sql
echo "GRANT ALL PRIVILEGES ON *.* TO 'eqemu'@'%' IDENTIFIED BY 'eqemupw';" >> /home/eqemu/server/logs/db_users.sql
echo "flush privileges;" >> /home/eqemu/server/logs/db_users.sql
mysql -u root -ppassw0rd < /home/eqemu/server/logs/db_users.sql
rm -rf /home/eqemu/server/logs/db_users.sql
#
# Get ready to load the database
#
mysql -u root -ppassw0rd -e "drop database if exists peqdb; create database if not exists peqdb;"
gunzip peqdb_rev*.sql.gz
mysql -u root -ppassw0rd -f -D peqdb < /home/eqemu/source/peqdatabase/peqdb_*.sql
# that might take a little time -- just under two minutes on my machine...
mysql -u root -ppassw0rd -f -D peqdb < /home/eqemu/source/peqdatabase/load_player.sql
mysql -u root -ppassw0rd -f -D peqdb < /home/eqemu/source/peqdatabase/load_login.sql
mysql -u root -ppassw0rd -f -D peqdb < /home/eqemu/source/peqdatabase/load_bots.sql
mysql -uroot -ppassw0rd -D peqdb < /home/eqemu/source/loginserver/login_util/EQEmuLoginServerDBInstall.sql
#
# Now we load that first account so we can have a GM account (or just muck around)
#
echo "insert into tblLoginServerAccounts (AccountName, AccountPassword ) values('xFN', sha('xPW') );" | sed s/xFN/$FIRST_ACCT_NAME/ | sed s/xPW/$FIRST_ACCT_PW/ > lsa.sql
mysql -u root -ppassw0rd -D peqdb < lsa.sql
echo "UPDATE tblWorldServerRegistration SET ServerLongName = 'xLN', ServerShortName = 'xSN' WHERE ServerID = 1;" | sed s/xLN/$EMU_LONG_NAME/| sed s/xSN/$EMU_SHORT_NAME/ > wsr.sql
mysql -u root -ppassw0rd -D peqdb < wsr.sql
#
#
cd /home/eqemu/server
cp /home/eqemu/source/utils/defaults/eqemu_config.xml.full eqemu_config.xml
cp /home/eqemu/source/utils/defaults/log.ini .
cp /home/eqemu/source/utils/defaults/*.pl .
cp /home/eqemu/source/utils/defaults/mime.types .
cp -r /home/eqemu/source/utils/defaults/templates .
cp -r /home/eqemu/source/utils/defaults/updated_templates .
cp /home/eqemu/source/loginserver/login_util/login.ini .
cp /home/eqemu/source/loginserver/login_util/login_opcodes.conf .
cp /home/eqemu/source/loginserver/login_util/login_opcodes_sod.conf .
cp /home/eqemu/source/utils/patches/*.conf .
echo ' '
echo '+--------------------------------------------------------------+ '
echo '! About to compile source code for a lot of stuff... !'
echo '! Expect this to take at least several minutes -- !'
echo '! Dont be surprised if this takes up to 20ish minutes. !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+ '
echo ' '
echo ' Compiling source-code -- please wait... '
echo ' '
cd /home/eqemu/source/
cmake -i
make &> /home/eqemu/compile_eqemuserver.log
echo ' '
echo '+--------------------------------------------------------------+ '
echo '! Copying compiled executables in the server directory.!'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+ '
echo ' '
ln -s /home/eqemu/source/Bin/queryserv /home/eqemu/server/queryserv
ln -s /home/eqemu/source/Bin/shared_memory /home/eqemu/server/shared_memory
ln -s /home/eqemu/source/Bin/ucs /home/eqemu/server/ucs
ln -s /home/eqemu/source/Bin/world /home/eqemu/server/world
ln -s /home/eqemu/source/Bin/zone /home/eqemu/server/zone
ln -s /home/eqemu/source/Bin/loginserver /home/eqemu/server/loginserver
ln -s /home/eqemu/source/Bin/eqlaunch /home/eqemu/server/eqlaunch
#
cd /home/eqemu/server
#
echo ' '
echo '+--------------------------------------------------------------+ '
echo '! Writing Startup Script... !'
read -p "[ Press [ENTER] to continue... ]"
echo '+--------------------------------------------------------------+ '
echo ' '
echo 'ulimit -c unlimited ' > /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'cd /home/eqemu/server ' >> /home/eqemu/server/startup.sh
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:. ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'rm -rf /home/eqemu/server/logs/login.log ' >> /home/eqemu/server/startup.sh
echo 'rm -rf /home/eqemu/server/logs/world.log ' >> /home/eqemu/server/startup.sh
echo 'rm -rf /home/eqemu/server/logs/zones.log ' >> /home/eqemu/server/startup.sh
echo 'rm -rf /home/eqemu/server/logs/*.log ' >> /home/eqemu/server/startup.sh
echo 'chmod --recursive ugo+rwx /home/eqemu/server/quests ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'echo Starting Login Server... ' >> /home/eqemu/server/startup.sh
echo ' ./loginserver 2>&1 >> /home/eqemu/server/logs/login.log & ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'echo Waiting about 5 seconds before starting World Server... ' >> /home/eqemu/server/startup.sh
echo 'sleep 5 ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo './world 2>&1 > /home/eqemu/server/logs/world.log & ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'echo Waiting 10 seconds before starting the zones via launcher ' >> /home/eqemu/server/startup.sh
echo 'sleep 10 ' >> /home/eqemu/server/startup.sh
echo './eqlaunch zone 2>&1 > /home/eqemu/server/logs/zones.log & ' >> /home/eqemu/server/startup.sh
echo ' ' >> /home/eqemu/server/startup.sh
echo 'echo The server is mostly ready... give it a couple of minutes ' >> /home/eqemu/server/startup.sh
echo 'echo to load stuff from the databases for the zones and users ' >> /home/eqemu/server/startup.sh
echo 'echo can start logging in. ' >> /home/eqemu/server/startup.sh
chmod ugo+x /home/eqemu/server/startup.sh
#
# CREATE db.ini
#
echo '+--------------------------------------------------------------+'
echo '! Writing db.ini !
'
echo '+--------------------------------------------------------------+'
echo '[Database] ' > /home/eqemu/server/db.ini
echo "host=$EXT_IP " >> /home/eqemu/server/db.ini
echo 'user=eqemu ' >> /home/eqemu/server/db.ini
echo 'password=eqemupw ' >> /home/eqemu/server/db.ini
echo 'database=peqdb ' >> /home/eqemu/server/db.ini
#
# CREATE login.ini
#
echo '+--------------------------------------------------------------+'
echo '! Writing login.ini !'
echo '+--------------------------------------------------------------+'
echo '[database] ' > /home/eqemu/server/login.ini
echo "host = $EXT_IP " >> /home/eqemu/server/login.ini
echo 'port = 3306 ' >> /home/eqemu/server/login.ini
echo 'db = peqdb ' >> /home/eqemu/server/login.ini
echo 'user = eqemu ' >> /home/eqemu/server/login.ini
echo 'password = eqemupw ' >> /home/eqemu/server/login.ini
echo 'subsystem = MySQL ' >> /home/eqemu/server/login.ini
echo ' ' >> /home/eqemu/server/login.ini
echo '[options] ' >> /home/eqemu/server/login.ini
echo 'unregistered_allowed = TRUE ' >> /home/eqemu/server/login.ini
echo 'reject_duplicate_servers = FALSE ' >> /home/eqemu/server/login.ini
echo 'trace = TRUE ' >> /home/eqemu/server/login.ini
echo 'world_trace = FALSE ' >> /home/eqemu/server/login.ini
echo 'dump_packets_in = FALSE ' >> /home/eqemu/server/login.ini
echo 'dump_packets_out = FALSE ' >> /home/eqemu/server/login.ini
echo 'listen_port = 5998 ' >> /home/eqemu/server/login.ini
echo 'local_network = 10.135.242. ' >> /home/eqemu/server/login.ini
echo ' ' >> /home/eqemu/server/login.ini
echo '[security] ' >> /home/eqemu/server/login.ini
echo 'plugin = EQEmuAuthCrypto ' >> /home/eqemu/server/login.ini
echo 'mode = 5 ' >> /home/eqemu/server/login.ini
echo ' ' >> /home/eqemu/server/login.ini
echo '[Titanium] ' >> /home/eqemu/server/login.ini
echo 'port = 5998 ' >> /home/eqemu/server/login.ini
echo 'opcodes = login_opcodes.conf ' >> /home/eqemu/server/login.ini
echo ' ' >> /home/eqemu/server/login.ini
echo '[SoD] ' >> /home/eqemu/server/login.ini
echo 'port = 5999 ' >> /home/eqemu/server/login.ini
echo 'opcodes = login_opcodes_sod.conf ' >> /home/eqemu/server/login.ini
echo ' ' >> /home/eqemu/server/login.ini
echo '[schema] ' >> /home/eqemu/server/login.ini
echo 'account_table = tblLoginServerAccounts ' >> /home/eqemu/server/login.ini
echo 'world_registration_table = tblWorldServerRegistration ' >> /home/eqemu/server/login.ini
echo 'world_admin_registration_table = tblServerAdminRegistration ' >> /home/eqemu/server/login.ini
echo 'world_server_type_table = tblServerListType ' >> /home/eqemu/server/login.ini
#
# CREATE LoginServer.ini
#
echo '+--------------------------------------------------------------+ '
echo '! Writing LoginServer.ini !'
echo '+--------------------------------------------------------------+ '
echo '[LoginServer] ' > /home/eqemu/server/LoginServer.ini
echo 'loginserver=EQ-Server ' >> /home/eqemu/server/LoginServer.ini
echo 'loginport=5998 ' >> /home/eqemu/server/LoginServer.ini
echo "worldname=$EMU_LONG_NAME " >> /home/eqemu/server/LoginServer.ini
echo "worldaddress=$EXT_IP " >> /home/eqemu/server/LoginServer.ini
echo 'locked=false ' >> /home/eqemu/server/LoginServer.ini
echo 'account= ' >> /home/eqemu/server/LoginServer.ini
echo 'password= ' >> /home/eqemu/server/LoginServer.ini
echo ' ' >> /home/eqemu/server/LoginServer.ini
echo '[WorldServer] ' >> /home/eqemu/server/LoginServer.ini
echo 'Defaultstatus=0 ' >> /home/eqemu/server/LoginServer.ini
echo 'Unavailzone= ' >> /home/eqemu/server/LoginServer.ini
echo ' ' >> /home/eqemu/server/LoginServer.ini
echo '[ChatChannelServer] ' >> /home/eqemu/server/LoginServer.ini
echo 'worldshortname=- ' >> /home/eqemu/server/LoginServer.ini
echo 'chataddress= ' >> /home/eqemu/server/LoginServer.ini
echo 'chatport= ' >> /home/eqemu/server/LoginServer.ini
#
# CREATE eqemu_config.xml
#
echo '+--------------------------------------------------------------+ '
echo '! Writing eqemu_config.xml !'
echo '+--------------------------------------------------------------+ '
echo '<?xml version="1.0"> ' > /home/eqemu/server/eqemu_config.xml
echo '<server> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <world> ' >> /home/eqemu/server/eqemu_config.xml
echo " <shortname>SMALLEQEMU</shortname> " >> /home/eqemu/server/eqemu_config.xml
echo " <longname>Rebellion</longname> " >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <address>EQ-Server</address> --> ' >> /home/eqemu/server/eqemu_config.xml
echo " <localaddress>10.135.242.200</localaddress> --> " >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- Loginserver information. Defaults shown --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <loginserver> ' >> /home/eqemu/server/eqemu_config.xml
echo " <host>10.135.242.200</host> " >> /home/eqemu/server/eqemu_config.xml
echo ' <port>5998</port> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <account>Admin</account> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <password>Password</password> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </loginserver> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- Server status. Default is unlocked --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!--<locked/>--> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <unlocked/> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo " <tcp ip=10.135.242.200 port=9000 telnet=disable /> " >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <key>some long random string</key> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <http port="9080" enabled="false" mimefile="mime.types" /> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </world> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- Chatserver (channels) information. Defaults shown --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <chatserver> ' >> /home/eqemu/server/eqemu_config.xml
echo " <host>10.135.242.200</host> " >> /home/eqemu/server/eqemu_config.xml
echo ' <port>7778</port> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </chatserver> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <mailserver> ' >> /home/eqemu/server/eqemu_config.xml
echo " <host>10.135.242.200</host> " >> /home/eqemu/server/eqemu_config.xml
echo ' <port>7779</port> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </mailserver> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <zones> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <defaultstatus>20</defaultstatus> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <ports low="7000" high="7100"/> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </zones> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <database> ' >> /home/eqemu/server/eqemu_config.xml
echo " <host>10.135.242.200</host> " >> /home/eqemu/server/eqemu_config.xml
echo ' <port>3306</port> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <username>eqemu</username> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <password>eqemupw</password> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <db>peqdb</db> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </database> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- Launcher Configuration --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <launcher> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- <logprefix>logs/zone-</logprefix> --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- <logsuffix>.log</logsuffix> --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- <exe>zone.exe or ./zone</exe> --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- <timers restart="10000" reterminate="10000"> --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </launcher> ' >> /home/eqemu/server/eqemu_config.xml
echo ' ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- File locations. Defaults shown --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <files> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <spells>spells_us.txt</spells> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <opcodes>opcodes.conf</opcodes> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <logsettings>log.ini</logsettings> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </files> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <!-- Directory locations. Defaults shown --> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <directories> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <maps>/home/eqemu/server/Maps</maps> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <quests>/home/eqemu/server/quests</quests> ' >> /home/eqemu/server/eqemu_config.xml
echo ' <plugins>/home/eqemu/server/plugins</plugins> ' >> /home/eqemu/server/eqemu_config.xml
echo ' </directories> ' >> /home/eqemu/server/eqemu_config.xml
echo '</server> ' >> /home/eqemu/server/eqemu_config.xml
chmod -R ugo+rw /home/eqemu
echo "killall eqlaunch world zone EQEmuLoginServer " > /home/eqemu/server/killeq.sh
chmod -R ugo+x /home/eqemu/server/killeq.sh
echo ' '
echo '+--------------------------------------------------------------+ '
echo '! Done with the installation !'
echo '! !'
echo '!  Please copy spells_us.txt to the !'
echo '! /home/eqemu/server directory now. !'
echo '! !'
echo '!--------------------------------------------------------------!'
echo '! Then you can reboot your machine and run !'
echo '! /home/eqemu/server/startup.sh !'
echo '! !'
echo '+--------------------------------------------------------------+ '
echo ' '