use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;
use 5.006;

# TODO: convert to dzil and use [OnlyCorePrereqs], and possibly [DualLife]

(do 'maint/Makefile.PL.include' or die $@) unless -f 'META.yml';

my %WriteMakefileArgs = (
  NAME => 'Module::Metadata',
  VERSION_FROM => 'lib/Module/Metadata.pm',
  ABSTRACT_FROM => 'lib/Module/Metadata.pm',
  LICENSE => 'perl',
  MIN_PERL_VERSION => '5.006',
  # PREREQ_PM => # see below
  # TEST_REQUIRES => # see below
  realclean => { FILES => [ 'Distar/', 'MANIFEST*' ] },

  META_MERGE => {
    'meta-spec' => { version => 2 },
    dynamic_config => 1,
    resources => {
      homepage => 'https://metacpan.org/pod/Module::Metadata',
      repository => {
        url => 'git@github.com:Perl-Toolchain-Gang/Module-Metadata.git',
        web => 'https://github.com/Perl-Toolchain-Gang/Module-Metadata',
        type => 'git',
      },
      bugtracker => {
          mailto => 'bug-Module-Metadata@rt.cpan.org',
          web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Module-Metadata',
      },
      'x_IRC' => 'irc://irc.perl.org/#toolchain',
    },
  },
);

my %META = (
  META_ADD => {
    prereqs => {
      configure => {
        requires => {
          'ExtUtils::MakeMaker' => '0',
        },
      },
      runtime => {
        requires => {
          'perl' => '5.006',
          'strict' => 0,
          'warnings' => 0,
          'Carp' => 0,
          'File::Find' => 0,
          'File::Spec' => 0,
          'version' => 0.87,
        },
      },
      test => {
        requires => {
          'Test::More' => 0.82,
          'Cwd' => 0,
          'File::Basename' => 0,
          'File::Path' => 0,
          'File::Temp' => 0,
          'IO::File' => 0,
          'vars' => 0,
        },
      },
    },
  },
);

$WriteMakefileArgs{PREREQ_PM} = {
    %{ $META{META_ADD}{prereqs}{runtime}{requires} },
    $] < 5.008
      ? ( 'IO::Scalar' => 0 )
      : (),
};

# however, this isn't actually respected... this is overwritten by META_ADD.
$WriteMakefileArgs{TEST_REQUIRES} = {
    %{ $META{META_ADD}{prereqs}{test}{requires} },
    -f 'META.yml'
      ? ()
      : ( 'Test::Builder' => '0.90' ),
};

WriteMakefile(
    %WriteMakefileArgs,
    -f 'META.yml'
      ? ()
      : %META
);
