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
