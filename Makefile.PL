use 5.018000;
use strict;
use warnings;
use utf8;
use ExtUtils::MakeMaker 7.12; # for XSMULTI option
use ExtUtils::CXX;
extutils_cxx {
WriteMakefile(
  NAME          => 'Math::SymEngine',
  VERSION_FROM  => 'lib/Math/SymEngine.pm',
  PREREQ_PM     => { 'ExtUtils::MakeMaker' => '7.12' },
  ABSTRACT_FROM => 'lib/Math/SymEngine.pm',
  AUTHOR        => 'Håkon Hægland <hakon.hagland@gmail.com>',
  OPTIMIZE      => '-g -std=c++17',
  XSMULTI       => 0,
  LICENSE       => 'perl',
  LIBS          => ['-L/opt/symengine/lib -lsymengine -lgmp'],
  DEFINE        => '', # e.g., '-DHAVE_SOMETHING'
  INC           => '-I/opt/symengine/include',
);
};
