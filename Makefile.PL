use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;
use 5.006;

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

WriteMakefile(
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm',
  ABSTRACT_FROM => 'lib/Module/Metadata.pm',
  LICENSE => 'perl',
  MIN_PERL_VERSION => '5.006',
  PREREQ_PM => {
    'Carp'        => 0,
    'File::Find'  => 0,
    'File::Spec'  => 0,
    'IO::File'    => 0,
    'strict'      => 0,
    'warnings'    => 0,
    'vars'        => 0,
    'version'     => 0.87,
    'warnings'    => 0,
    $] < 5.008
      ? ( 'IO::Scalar' => 0 )
      : ()
    ,
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    dynamic_config => 0,
    resources => {
      # r/w: p5sagit@git.shadowcat.co.uk:Module-Metadata.git
      repository => {
        url => 'git://git.shadowcat.co.uk/p5sagit/Module-Metadata.git',
        web => 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=p5sagit/Module-Metadata.git',
        type => 'git',
      },
      bugtracker => {
          mailto => 'bug-Module-Metadata@rt.cpan.org',
          web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Module-Metadata',
      },
    },
  },
);
