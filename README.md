# perl-math-symengine

To install the module:

## Install symengine C++ library

On Linux (tested on Ubuntu 20.04) you can do (installs
`libsymengine.so` in directory `/opt/symengine`) :
```
sudo apt-get install -y cmake g++ git libgmp-dev
git clone https://github.com/symengine/symengine.git
cd symengine
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/opt/symengine -DBUILD_SHARED_LIBS:BOOL=ON ..
make
sudo make install
```

## Install this Perl module

Install this module (tested with `perlbrew`):

perl Makefile.PL
make
make install
