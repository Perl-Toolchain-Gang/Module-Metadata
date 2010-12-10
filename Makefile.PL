use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm',
  PREREQ_PM => {
    'version' => 0.87,
  },
);
