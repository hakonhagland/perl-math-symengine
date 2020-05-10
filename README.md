# Math::SymEngine

Perl bindings to
the [symengine](https://github.com/symengine/symengine) C++ library.

## Intallation

### Install symengine C++ library

(Tested on Ubuntu 20.04). Install `libsymengine.so` into directory `/opt/symengine`:
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

### Install Math::SymEngine Perl module

(Tested on Ubuntu 20.04 with `perlbrew` and `perl` version 5.30)

```
git clone https://github.com/hakonhagland/perl-math-symengine.git
cd perl-math-symengine
cpanm .
```

## Run the test script

The following example Perl script `test.pl` computes the product of two 2x2 matrices:
```
#! /usr/bin/env perl
use feature qw(say);
use strict;
use warnings;
use Math::SymEngine;
use Package::Alias 'Sym' => 'Math::SymEngine';

my $x = Sym::sym("x");
my $A = Sym::DenseMatrix->new(2,2);
$A->set(0,0, Sym::cos($x));
$A->set(0,1, Sym::mul(Sym::integer(-1), Sym::sin($x)));
$A->set(1,0, Sym::sin($x));
$A->set(1,1, Sym::cos($x));
my $y = Sym::sym("y");
my $B = Sym::DenseMatrix->new(2,2);
$B->set(0,0, Sym::cos($y));
$B->set(0,1, Sym::mul(Sym::integer(-1), Sym::sin($y)));
$B->set(1,0, Sym::sin($y));
$B->set(1,1, Sym::cos($y));
my $C = Sym::mul_dense_dense($A, $B);
say $C->to_string();
```

To run it, type:

```
$ perl test.pl
[-sin(y)*sin(x) + cos(y)*cos(x), -sin(x)*cos(y) - sin(y)*cos(x)]
[sin(x)*cos(y) + sin(y)*cos(x), -sin(y)*sin(x) + cos(y)*cos(x)]
```
