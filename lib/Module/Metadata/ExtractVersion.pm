use strict;
use warnings;
package Module::Metadata::ExtractVersion;
# ABSTRACT: Safe parsing of module $VERSION lines

use parent 'Exporter';
our @EXPORT_OK = qw/eval_version/;

use Carp qw/croak/;

=func eval_version

Given a (decoded) string (usually a single line) that contains a C<$VERSION>
declaration, this function will evaluate it in a L<Safe> compartment in a
separate process.  If the C<$VERSION> is a valid version string according to
L<version>, it will return it as a string, otherwise, it will return undef.

=cut

sub eval_version
{
    my (%args) = @_;

    return _evaluate_version_line(
        $args{sigil},
        $args{variable_name},
        $args{string},
        $args{filename},
    );
}

# transported directly from Module::Metadata
{
my $pn = 0;
sub _evaluate_version_line {
  my( $sigil, $variable_name, $line, $filename ) = @_;

  # Some of this code came from the ExtUtils:: hierarchy.

  # We compile into $vsub because 'use version' would cause
  # compiletime/runtime issues with local()
  my $vsub;
  $pn++; # everybody gets their own package
  my $eval = qq{BEGIN { my \$dummy = q#  Hide from _packages_inside()
    #; package Module::Metadata::_version::p$pn;
    use version;
    no strict;
    no warnings;

      \$vsub = sub {
        local $sigil$variable_name;
        \$$variable_name=undef;
        $line;
        \$$variable_name
      };
  }};

  $eval = $1 if $eval =~ m{^(.+)}s;

  local $^W;
  # Try to get the $VERSION
  eval $eval;
  # some modules say $VERSION = $Foo::Bar::VERSION, but Foo::Bar isn't
  # installed, so we need to hunt in ./lib for it
  if ( $@ =~ /Can't locate/ && -d 'lib' ) {
    local @INC = ('lib',@INC);
    eval $eval;
  }
  warn "Error evaling version line '$eval' in $filename: $@\n"
    if $@;
  (ref($vsub) eq 'CODE') or
    croak "failed to build version sub for $filename";
  my $result = eval { $vsub->() };
  croak "Could not get version from $filename by executing:\n$eval\n\nThe fatal error was: $@\n"
    if $@;

  # Upgrade it into a version object
  my $version = eval { _dwim_version($result) };

  croak "Version '$result' from $filename does not appear to be valid:\n$eval\n\nThe fatal error was: $@\n"
    unless defined $version; # "0" is OK!

  return $version;
}
}

# Try to DWIM when things fail the lax version test in obvious ways
{
  my @version_prep = (
    # Best case, it just works
    sub { return shift },

    # If we still don't have a version, try stripping any
    # trailing junk that is prohibited by lax rules
    sub {
      my $v = shift;
      $v =~ s{([0-9])[a-z-].*$}{$1}i; # 1.23-alpha or 1.23b
      return $v;
    },

    # Activestate apparently creates custom versions like '1.23_45_01', which
    # cause version.pm to think it's an invalid alpha.  So check for that
    # and strip them
    sub {
      my $v = shift;
      my $num_dots = () = $v =~ m{(\.)}g;
      my $num_unders = () = $v =~ m{(_)}g;
      my $leading_v = substr($v,0,1) eq 'v';
      if ( ! $leading_v && $num_dots < 2 && $num_unders > 1 ) {
        $v =~ s{_}{}g;
        $num_unders = () = $v =~ m{(_)}g;
      }
      return $v;
    },

    # Worst case, try numifying it like we would have before version objects
    sub {
      my $v = shift;
      no warnings 'numeric';
      return 0 + $v;
    },

  );

  sub _dwim_version {
    my ($result) = shift;

    return $result if ref($result) eq 'version';

    my ($version, $error);
    for my $f (@version_prep) {
      $result = $f->($result);
      $version = eval { version->new($result) };
      $error ||= $@ if $@; # capture first failure
      last if defined $version;
    }

    croak $error unless defined $version;

    return $version;
  }
}

1;
