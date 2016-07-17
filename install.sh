#!/bin/bash

GUTENPRINT='gutenprint-5.2.11.tar.bz2'
QPDFBUILD=0
POPPLERBUILD=0
CUPSBUILD=0
CUPSFILTERSBUILD=0
GSBUILD=0
FOOMATICBUILD=0
GSBUILD=0
GO1_4BUILD=0
GOBUILD=0

# create build directory
mkdir build
cd build

# create prerequisites
sudo apt-get install \
    autoconf \
    bzr \
    build-essential \
    git \
    libxext-dev \
    wget
    

# get the latest software
git clone https://github.com/qpdf/qpdf.git qpdf
git clone https://github.com/apple/cups.git cups-2.2
git clone git://git.freedesktop.org/git/poppler/poppler poppler
git clone git://git.ghostscript.com/ghostpdl.git ghostpdl
bzr branch http://bzr.linuxfoundation.org/openprinting/cups-filters cups-filters
bzr branch http://bzr.openprinting.org/foomatic/foomatic-db foomatic-db
if [ -z $GUTENPRINT ]; then 
    wget http://downloads.sourceforge.net/project/gimp-print/gutenprint-5.2/5.2.11/gutenprint-5.2.11.tar.bz2 -O $GUTENPRINT
fi
if [ -z "go1.4" ]; then
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
if [ $? -eq 0 ]
then
  $QPDFBUILD=1
fi
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
if [ $? -eq 0 ]
then
  $POPPLERBUILD=1
fi

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
if [ $? -eq 0 ]
then
  $CUPSBUILD=1
fi
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
if [ $? -eq 0 ]
then
  $GHOSTPRINTBUILD=1
fi
sudo make install
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
if [ $? -eq 0 ]
then
  $CUPSFILTERSBUILD=1
fi

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
if [ $? -eq 0 ]
then
  $FOOTMATICBUILD=1
fi

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
if [ $? -eq 0 ]
then
  $GSBUILD=1
fi

sudo make install
cd ..
echo "gutenprint build complete!"
echo "====================================================="

# go 1.4 install
echo "====================================================="
echo "building go 1.4..."
cd go1.4
./make.bash
if [ $? -eq 0 ]
then
  $GO1_4BUILD=1
fi

cd ..
echo "go 1.4 build complete!"
echo "====================================================="

# real go install
echo "====================================================="
echo "building latest go..."
cd go
./all.bash
if [ $? -eq 0 ]
then
  $GOBUILD=1
fi
cd ..
echo "latest go build complete!"
echo "====================================================="

# set go variables
mkdir ~/.go
export GOROOT="/home/go"
export GOPATH="/home/.go"

# finished!
echo "finished!!!"

# summary
echo "====================================================="
echo "Build Summary\n\n"
echo "qpdf: $QPDFBUILD"
echo "poppler: $POPPLERBUILD"
echo "cups: $CUPSBUILD"
echo "ghostcript: $GHOSTSCRIPTBUILD"
echo "cups-filters: $CUPSFILTERSBUILD"
echo "foomatic-db: $FOOMATICDBBUILD"
echo "gutenprint: $GSBUILD"
echo "go 1.4: $GO1_4BUILD"
echo "go latest: $GOLATESTBUILD"
echo "====================================================="
