use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'Author.PL' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm'
);
