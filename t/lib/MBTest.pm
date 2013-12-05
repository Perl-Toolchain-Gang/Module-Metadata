package MBTest;

use strict;
use warnings;

use File::Spec;
use File::Temp ();

# Setup the code to clean out %ENV
BEGIN {
    # Environment variables which might effect our testing
    my @delete_env_keys = qw(
        HOME
        DEVEL_COVER_OPTIONS
        MODULEBUILDRC
        PERL_MB_OPT
        HARNESS_TIMER
        HARNESS_OPTIONS
        HARNESS_VERBOSE
        PREFIX
        INSTALL_BASE
        INSTALLDIRS
    );

    # Remember the ENV values because on VMS %ENV is global
    # to the user, not the process.
    my %restore_env_keys;

    sub clean_env {
        for my $key (@delete_env_keys) {
            if( exists $ENV{$key} ) {
                $restore_env_keys{$key} = delete $ENV{$key};
            }
            else {
                delete $ENV{$key};
            }
        }
    }

    END {
        while( my($key, $val) = each %restore_env_keys ) {
            $ENV{$key} = $val;
        }
    }
}


BEGIN {
  clean_env();

  # In case the test wants to use our other bundled
  # modules, make sure they can be loaded.
  my $t_lib = File::Spec->catdir('t', 'bundled');
  push @INC, $t_lib; # Let user's installed version override

  if ($ENV{PERL_CORE}) {
    # We change directories, so expand @INC and $^X to absolute paths
    # Also add .
    @INC = (map(File::Spec->rel2abs($_), @INC), ".");
    $^X = File::Spec->rel2abs($^X);
  }
}

use Cwd ();

########################################################################

# always return to the current directory
{
  my $cwd = File::Spec->rel2abs(Cwd::cwd);

  sub original_cwd { return $cwd }

  END {
    # Go back to where you came from!
    chdir $cwd or die "Couldn't chdir to $cwd";
  }
}
########################################################################

# Setup a temp directory
sub tmpdir {
  my ($self, @args) = @_;
  my $dir = $ENV{PERL_CORE} ? MBTest->original_cwd : File::Spec->tmpdir;
  return File::Temp::tempdir('MB-XXXXXXXX', CLEANUP => 1, DIR => $dir, @args);
}

BEGIN {
  $ENV{HOME} = tmpdir; # don't want .modulebuildrc or other things interfering
}

1;
# vim:ts=2:sw=2:et:sta
