# perl-math-symengine

## Install symengine C++ library

On Linux you can do:
```
git clone git@github.com:symengine/symengine.git
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
