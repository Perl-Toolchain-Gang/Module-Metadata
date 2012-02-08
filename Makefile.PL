use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm',
  PREREQ_PM => {
    'Carp'        => 0,
    'File::Find'  => 0,
    'File::Spec'  => 0,
    'IO::File'    => 0,
    'strict'      => 0,
    'vars'        => 0,
    'version'     => 0.87,
    'warnings'    => 0,
  },
);
