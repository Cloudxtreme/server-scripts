clear
echo "deb http://mirrors.kernel.org/debian/ squeeze main non-free" | sudo tee -a /etc/apt/sources.list && echo "deb-src http://mirrors.kernel.org/debian/ squeeze main non-free" | sudo tee -a /etc/apt/sources.list && echo "deb http://opensource.wandisco.com/debian squeeze svn17" | sudo tee -a /etc/apt/sources.list
wget http://opensource.wandisco.com/wandisco-debian.gpg && apt-key add wandisco-debian.gpg && rm wandisco-debian.gpg
apt-get update && apt-get -q -y install gcc g++ make gdb automake libreadline5-dev subversion libneon27 libsvn-java libaprutil1 libaprutil1-dev libtool sun-java6-jre sun-java6-jdk libsvn-java
update-java-alternatives -s java-6-sun
echo 'JAVA_HOME="/usr/lib/jvm/java-6-sun"' | tee -a /etc/environment
wget http://www.ocdsoft.com/files/debian/subversion-1.7.5.tar.gz && tar -xvf subversion-1.7.5.tar.gz && cd subversion-1.7.5 && ./autogen.sh && ./configure && make && make install && cd .. && rm subversion-1.7.5.tar.gz && rm -R subversion-1.7.5
wget http://www.lua.org/ftp/lua-5.1.4.tar.gz && tar -xvf lua-5.1.4.tar.gz && wget http://www.ocdsoft.com/files/debian/lua/lua514-emu-lnum.patch && cd lua-5.1.4/src && patch < ../../lua514-emu-lnum.patch && cd .. && make linux install && cd .. && rm -R lua-5.1.4 && rm lua-5.1.4.tar.gz && rm lua514-emu-lnum.patch
wget http://www.ocdsoft.com/files/debian/db-5.0.26.NC.tar.gz && tar -xvf db-5.0.26.NC.tar.gz && cd db-5.0.26.NC/build_unix && ../dist/configure --enable-cxx && make && make install && cd .. && cd .. && rm -R db-5.0.26.NC && rm db-5.0.26.NC.tar.gz
echo "/usr/local/BerkeleyDB.5.0/lib" | sudo tee -a /etc/ld.so.conf && ldconfig
apt-get install -q -y mysql-server mysql-server-5.1
apt-get -q -y install mysql-admin mysql-client libmysqlclient-dev
mysqladmin -u root password 12345678
apt-get -q -y upgrade
echo "create database swgemu; CREATE USER 'swgemu'@'localhost' IDENTIFIED BY '123456'; GRANT ALL ON *.* TO 'swgemu'@'localhost';" | mysql -u root -p12345678
wget http://www.ocdsoft.com/files/debian/eclipse-cpp.tar.gz && tar -xvf eclipse-cpp.tar.gz && mv eclipse-cpp /usr/local/eclipse-cpp && ln -s /usr/local/eclipse-cpp/eclipse eclipse && rm eclipse-cpp.tar.gz
echo '-Djava.library.path=/usr/lib/jni' >> /usr/local/eclipse-cpp/eclipse.ini