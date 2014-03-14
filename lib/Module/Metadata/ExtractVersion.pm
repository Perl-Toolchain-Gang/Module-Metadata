package Module::Metadata::ExtractVersion;
# ABSTRACT: Safe parsing of module $VERSION lines

sub __clean_eval { eval $_[0] }

use strict;
use warnings;

our $VERSION = '1.000028';

use base 'Exporter';
our @EXPORT_OK = qw/eval_version/;

use Carp qw/croak/;
use version 0.87;

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

  # We compile into a local sub because 'use version' would cause
  # compiletime/runtime issues with local()
  $pn++; # everybody gets their own package
  my $eval = qq{ my \$dummy = q#  Hide from _packages_inside()
    #; package Module::Metadata::_version::p${pn};
    use version;
    sub {
      local $sigil$variable_name;
      $line;
      \$$variable_name
    };
  };

  $eval = $1 if $eval =~ m{^(.+)}s;

  local $^W;
  # Try to get the $VERSION
  my $vsub = __clean_eval($eval);
  # some modules say $VERSION <equal sign> $Foo::Bar::VERSION, but Foo::Bar isn't
  # installed, so we need to hunt in ./lib for it
  if ( $@ =~ /Can't locate/ && -d 'lib' ) {
    local @INC = ('lib',@INC);
    $vsub = __clean_eval($eval);
  }
  warn "Error evaling version line '$eval' in $filename: $@\n"
    if $@;

  (ref($vsub) eq 'CODE') or
    croak "failed to build version sub for $filename";

  my $result = eval { $vsub->() };
  # FIXME: $eval is not the right thing to print here
  croak "Could not get version from $filename by executing:\n$eval\n\nThe fatal error was: $@\n"
    if $@;

  return $result;
}
}

1;
