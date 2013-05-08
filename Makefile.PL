use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm',
  ABSTRACT_FROM => 'lib/Module/Metadata.pm',
  LICENSE => 'perl',
  PREREQ_PM => {
    'Carp'        => 0,
    'File::Find'  => 0,
    'File::Spec'  => 0,
    'IO::File'    => 0,
    'strict'      => 0,
    'vars'        => 0,
    'version'     => 0.87,
    'warnings'    => 0,
    $] < 5.008
      ? ( 'IO::Scalar' => 0 )
      : ()
    ,
  },
  META_MERGE => {
    dynamic_config => 0,
    resources => {
      # r/w: p5sagit@git.shadowcat.co.uk:Module-Metadata.git
      repository => 'git://git.shadowcat.co.uk/p5sagit/Module-Metadata.git',
      homepage => 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Module-Metadata.git',
    },
  },
);
