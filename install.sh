#!/bin/bash

$GUTENPRINT='gutenprint-5.2.11.tar.bz2'

# get the latest software
git clone https://github.com/qpdf/qpdf.git qpdf
git clone https://github.com/apple/cups.git cups-2.2
git clone git://git.freedesktop.org/git/poppler/poppler poppler
git clone git://git.ghostscript.com/ghostpdl.git ghostpdl
bzr branch http://bzr.linuxfoundation.org/openprinting/cups-filters cups-filters
bzr branch http://bzr.openprinting.org/foomatic/foomatic-db foomatic-db
if [ -z $GUTENPRINT ] 
    wget http://downloads.sourceforge.net/project/gimp-print/gutenprint-5.2/5.2.11/gutenprint-5.2.11.tar.bz2 -O $GUTENPRINT
fi
if [ -z "go1.4" ]
    curl -sSL https://storage.googleapis.com/golang/go1.4.3.src.tar.gz | tar -xz -C go1.4
fi
git clone https://go.googlesource.com/go

# start building

# qpdf
echo "====================================================="
echo "building qpdf..."
cd qpdf
autoconf
./configure --enable-doc-maintenance
make
sudo make install
cd ..
echo "qpdf build complete!"
echo "====================================================="

# poppler
echo "====================================================="
echo "building poppler..."
cd poppler
./autogen.sh
./configure --enable-libcurl
make
sudo make install
cd ..
echo "poppler build complete!"
echo "====================================================="

# cups
echo "====================================================="
echo "building cups..."
useradd -c "Print Service User" -d /var/spool/cups -g lp -s /bin/false -u 9 lp
groupadd -g 19 lpadmin
usermod -a -G lpadmin pi

cd cups-2.2
./configure
make
sudo make install
echo "ServerName /var/run/cups/cups.sock" > /etc/cups/client.conf
cd ..
echo "cups build complete!"
echo "====================================================="

# ghostscript
echo "====================================================="
echo "build ghostscript..."
cd ghostpdl/gs
sudo apt-get install libxt-dev
./autogen.sh
./configure
make
sudo make install
sudo make install-so
cd ..
echo "ghostscript build complete!"
echo "====================================================="

# cups-filters
echo "====================================================="
echo "building cups-filters..."
cd cups-filters
autoconf
./configure
make
sudo make install
cd ..
echo "cups-filters build complete!"
echo "====================================================="

# foomatic-db
echo "====================================================="
echo "building foomatic-db..."
cd foomatic-db
./configure
make
sudo make install
cd ..
echo "foomatic-db build complete!"
echo "====================================================="

# gutenprint
echo "====================================================="
echo "building gutenprint..."
tar xvjf $GUTENPRINT
cd gutenprint
sudo apt-get install texlive-fonts-extra doxygen
./configure
make
sudo make install
cd ..
echo "gutenprint build complete!"
echo "====================================================="

# go 1.4 install
echo "====================================================="
echo "building go 1.4..."
cd go1.4
./make.bash
cd ..
echo "go 1.4 build complete!"
echo "====================================================="

# real go install
echo "====================================================="
echo "building latest go..."
cd go
./all.bash
cd ..
echo "latest go build complete!"
echo "====================================================="

# set go variables
mkdir ~/.go
export $GOROOT="/home/go"
export $GOPATH="/home/.go"

# finished!
echo "finished!!!"

