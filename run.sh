#!/bin/bash

# get the latest software
git clone https://github.com/qpdf/qpdf.git qpdf
git clone https://github.com/apple/cups.git cups-2.2
git clone git://git.freedesktop.org/git/poppler/poppler poppler
git clone git://git.ghostscript.com/ghostpdl.git ghostpdl
bzr branch http://bzr.linuxfoundation.org/openprinting/cups-filters cups-filters
bzr branch http://bzr.openprinting.org/foomatic/foomatic-db foomatic-db
wget http://downloads.sourceforge.net/project/gimp-print/gutenprint-5.2/5.2.11/gutenprint-5.2.11.tar.bz2 -O gutenprint

# start building

# qpdf
cd qpdf
autoconf
./configure --enable-doc-maintenance
make
sudo make install
cd ..

# poppler
cd poppler
./autogen.sh
./configure --enable-libcurl
make
sudo make install
cd ..

# cups

useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
groupadd -g 19 lpadmin
usermod -a -G lpadmin pi

cd cups-2.2
./configure
make
sudo make install
echo "ServerName /var/run/cups/cups.sock" > /etc/cups/client.conf
cd ..

# ghostscript

cd ghostpdl/gs
sudo apt-get install libxt-dev
./autogen.sh
./configure
make
sudo make install
sudo make install-so
cd ..

# cups-filters

cd cups-filters
autoconf
./configure
make
sudo make install
cd ..

# foomatic-db

cd foomatic-db
./configure
make
sudo make install
cd ..

# gutenprint

tar xvjf gutenprint-5.2.11.tar.bz2
cd gutenprint
sudo apt-get install texlive-fonts-extra doxygen
./configure
make
sudo make install
cd ..

# finished!
echo "finished!!!"

