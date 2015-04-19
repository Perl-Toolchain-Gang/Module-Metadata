use strict;
use warnings;
# vim:ts=8:sw=2:et:sta:sts=2

use Test::More 0.82;
use Data::Dumper;
use Module::Metadata;

use lib 't/lib';
use GeneratePackage;

my $undef;

# parse various module $VERSION lines
# format: {
#   name => test name
#   code => code snippet (string)
#   vers => expected version object (in stringified form),
# }
my @modules = (
{
  vers => $undef,
  name => 'no $VERSION line',
  code => <<'---',
package Simple;
---
},
{
  vers => $undef,
  name => 'undefined $VERSION',
  code => <<'---',
package Simple;
our $VERSION;
---
},
{
  vers => '1.23',
  name => 'declared & defined on same line with "our"',
  code => <<'---',
package Simple;
our $VERSION = '1.23';
---
},
{
  vers => '1.23',
  name => 'declared & defined on separate lines with "our"',
  code => <<'---',
package Simple;
our $VERSION;
$VERSION = '1.23';
---
},
{
  name => 'commented & defined on same line',
  code => <<'---',
package Simple;
our $VERSION = '1.23'; # our $VERSION = '4.56';
---
  vers => '1.23',
},
{
  name => 'commented & defined on separate lines',
  code => <<'---',
package Simple;
# our $VERSION = '4.56';
our $VERSION = '1.23';
---
  vers =>'1.23',
},
{
  name => 'use vars',
  code => <<'---',
package Simple;
use vars qw( $VERSION );
$VERSION = '1.23';
---
  vers => '1.23',
},
{
  name => 'choose the right default package based on package/file name',
  code => <<'---',
package Simple::_private;
$VERSION = '0';
package Simple;
$VERSION = '1.23'; # this should be chosen for version
---
  vers => '1.23',
},
{
  name => 'just read the first $VERSION line',
  code => <<'---',
package Simple;
$VERSION = '1.23'; # we should see this line
$VERSION = eval $VERSION; # and ignore this one
---
  vers => '1.23',
},
{
  name => 'just read the first $VERSION line in reopened package (1)',
  code => <<'---',
package Simple;
$VERSION = '1.23';
package Error::Simple;
$VERSION = '2.34';
package Simple;
---
  vers => '1.23',
},
{
  name => 'just read the first $VERSION line in reopened package (2)',
  code => <<'---',
package Simple;
package Error::Simple;
$VERSION = '2.34';
package Simple;
$VERSION = '1.23';
---
  vers => '1.23',
},
{
  name => 'mentions another module\'s $VERSION',
  code => <<'---',
package Simple;
$VERSION = '1.23';
if ( $Other::VERSION ) {
    # whatever
}
---
  vers => '1.23',
},
{
  name => 'mentions another module\'s $VERSION in a different package',
  code => <<'---',
package Simple;
$VERSION = '1.23';
package Simple2;
if ( $Simple::VERSION ) {
    # whatever
}
---
  vers => '1.23',
},
{
  name => '$VERSION checked only in assignments, not regexp ops',
  code => <<'---',
package Simple;
$VERSION = '1.23';
if ( $VERSION =~ /1\.23/ ) {
    # whatever
}
---
  vers => '1.23',
},
{
  name => '$VERSION checked only in assignments, not relational ops',
  code => <<'---',
package Simple;
$VERSION = '1.23';
if ( $VERSION == 3.45 ) {
    # whatever
}
---
  vers => '1.23',
},
{
  name => '$VERSION checked only in assignments, not relational ops',
  code => <<'---',
package Simple;
$VERSION = '1.23';
package Simple2;
if ( $Simple::VERSION == 3.45 ) {
    # whatever
}
---
  vers => '1.23',
},
{
  name => 'Fully qualified $VERSION declared in package',
  code => <<'---',
package Simple;
$Simple::VERSION = 1.23;
---
  vers => '1.23',
},
{
  name => 'Differentiate fully qualified $VERSION in a package',
  code => <<'---',
package Simple;
$Simple2::VERSION = '999';
$Simple::VERSION = 1.23;
---
  vers => '1.23',
},
{
  name => 'Differentiate fully qualified $VERSION and unqualified',
  code => <<'---',
package Simple;
$Simple2::VERSION = '999';
$VERSION = 1.23;
---
  vers => '1.23',
},
{
  name => 'Differentiate fully qualified $VERSION and unqualified, other order',
  code => <<'---',
package Simple;
$VERSION = 1.23;
$Simple2::VERSION = '999';
---
  vers => '1.23',
},
{
  name => '$VERSION declared as package variable from within "main" package',
  code => <<'---',
$Simple::VERSION = '1.23';
{
  package Simple;
  $x = $y, $cats = $dogs;
}
---
  vers => '1.23',
},
{
  name => '$VERSION wrapped in parens - space inside',
  code => <<'---',
package Simple;
( $VERSION ) = '1.23';
---
  '1.23' => <<'---', # $VERSION wrapped in parens - no space inside
package Simple;
($VERSION) = '1.23';
---
  vers => '1.23',
},
{
  name => '$VERSION follows a spurious "package" in a quoted construct',
  code => <<'---',
package Simple;
__PACKAGE__->mk_accessors(qw(
    program socket proc
    package filename line codeline subroutine finished));

our $VERSION = "1.23";
---
  vers => '1.23',
},
{
  name => '$VERSION using version.pm',
  code => <<'---',
  package Simple;
  use version; our $VERSION = version->new('1.23');
---
  vers => '1.23',
},
{
  name => '$VERSION using version.pm and qv()',
  code => <<'---',
  package Simple;
  use version; our $VERSION = qv('1.230');
---
  vers => 'v1.230',
},
{
  name => 'underscore version with an eval',
  code => <<'---',
  package Simple;
  $VERSION = '1.23_01';
  $VERSION = eval $VERSION;
---
  vers => '1.23_01',
},
{
  name => 'Two version assignments, should ignore second one',
  code => <<'---',
  $Simple::VERSION = '1.230';
  $Simple::VERSION = eval $Simple::VERSION;
---
  vers => '1.230',
},
{
  name => 'declared & defined on same line with "our"',
  code => <<'---',
package Simple;
our $VERSION = '1.23_00_00';
---
  vers => '1.230000',
},
{
  name => 'package NAME VERSION',
  code => <<'---',
  package Simple 1.23;
---
  vers => '1.23',
},
{
  name => 'package NAME VERSION',
  code => <<'---',
  package Simple 1.23_01;
---
  vers => '1.23_01',
},
{
  name => 'package NAME VERSION',
  code => <<'---',
  package Simple v1.2.3;
---
  vers => 'v1.2.3',
},
{
  name => 'package NAME VERSION',
  code => <<'---',
  package Simple v1.2_3;
---
  vers => 'v1.2_3',
},
{
  name => 'trailing crud',
  code => <<'---',
  package Simple;
  our $VERSION;
  $VERSION = '1.23-alpha';
---
  vers => '1.23',
},
{
  name => 'trailing crud',
  code => <<'---',
  package Simple;
  our $VERSION;
  $VERSION = '1.23b';
---
  vers => '1.23',
},
{
  name => 'multi_underscore',
  code => <<'---',
  package Simple;
  our $VERSION;
  $VERSION = '1.2_3_4';
---
  vers => '1.234',
},
{
  name => 'non-numeric',
  code => <<'---',
  package Simple;
  our $VERSION;
  $VERSION = 'onetwothree';
---
  vers => '0',
},
{
  name => 'package NAME BLOCK, undef $VERSION',
  code => <<'---',
package Simple {
  our $VERSION;
}
---
  vers => $undef,
},
{
  name => 'package NAME BLOCK, with $VERSION',
  code => <<'---',
package Simple {
  our $VERSION = '1.23';
}
---
  vers => '1.23',
},
{
  name => 'package NAME VERSION BLOCK',
  code => <<'---',
package Simple 1.23 {
  1;
}
---
  vers => '1.23',
},
{
  name => 'package NAME VERSION BLOCK',
  code => <<'---',
package Simple v1.2.3_4 {
  1;
}
---
  vers => 'v1.2.3_4',
},
{
  name => 'set from separately-initialised variable, two lines',
  code => <<'---',
package Simple;
  our $CVSVERSION   = '$Revision: 1.7 $';
  our ($VERSION)    = ($CVSVERSION =~ /(\d+\.\d+)/);
}
---
  vers => '0',
},
{
  name => 'our + bare v-string',
  code => <<'---',
package Simple;
our $VERSION     = v2.2.102.2;
---
  vers => 'v2.2.102.2',
},
{
  name => 'our + dev release',
  code => <<'---',
package Simple;
our $VERSION = "0.0.9_1";
---
  vers => '0.0.9_1',
},
{
  name => 'our + crazy string and substitution code',
  code => <<'---',
package Simple;
our $VERSION     = '1.12.B55J2qn'; our $WTF = $VERSION; $WTF =~ s/^\d+\.\d+\.//; # attempts to rationalize $WTF go here.
---
  vers => '1.12',
},
{
  name => 'our in braces, as in Dist::Zilla::Plugin::PkgVersion with use_our = 1',
  code => <<'---',
package Simple;
{ our $VERSION = '1.12'; }
---
  vers => '1.12',
},
{
  name => 'calculated version - from Acme-Pi-3.14',
  code => <<'---',
package Simple;
my $version = atan2(1,1) * 4; $Simple::VERSION = "$version";
1;
---
  vers => sub { defined $_[0] and $_[0] =~ /^3\.14159/ },
},
{
  name => 'set from separately-initialised variable, one line',
  code => <<'---',
package Simple;
  my $CVSVERSION   = '$Revision: 1.7 $'; our ($VERSION) = ($CVSVERSION =~ /(\d+\.\d+)/);
}
---
  vers => '1.7',
},
{
  name => 'from Lingua-StopWords-0.09/devel/gen_modules.plx',
  code => <<'---',
package Foo;
our $VERSION = $Bar::VERSION;
---
  vers => $undef,
},
{
  name => 'from XML-XSH2-2.1.17/lib/XML/XSH2/Parser.pm',
  code => <<'---',
our $VERSION = # Hide from PAUSE
     '1.967009';
$VERSION = eval $VERSION;
---
  vers => $undef,
},
{
  name => 'from MBARBON/Module-Info-0.30.tar.gz',
  code => <<'---',
package Simple;
$VERSION = eval 'use version; 1' ? 'version'->new('0.30') : '0.30';
---
  vers => '0.30',
},
);

my $test_num = 0;

my $tmpdir = GeneratePackage::tmpdir();

# iterate through @modules
foreach my $test_case (@modules) {
  my $code = $test_case->{code};
  my $expected_version = $test_case->{vers};
  SKIP: {
    skip( "No our() support until perl 5.6", (defined $expected_version ? 3 : 2) )
        if $] < 5.006 && $code =~ /\bour\b/;
    skip( "No package NAME VERSION support until perl 5.11.1", (defined $expected_version ? 3 : 2) )
        if $] < 5.011001 && $code =~ /package\s+[\w\:\']+\s+v?[0-9._]+/;

    my $warnings = '';
    local $SIG{__WARN__} = sub { $warnings .= $_ for @_ };

    my $pm_info = Module::Metadata->new_from_file(generate_file(File::Spec->catdir($tmpdir, "Simple${test_num}"), 'Simple.pm', $code));

    # whenever we drop support for 5.6, we can do this:
    # open my $fh, '<', \(encode('UTF-8', $code, Encode::FB_CROAK))
    #     or die "cannot open handle to code string: $!";
    # my $pm_info = Module::Metadata->new_from_handle($fh, 'lib/Simple.pm');

    my $errs;
    my $got = $pm_info->version;

    # note that in Test::More 0.94 and earlier, is() stringifies first before comparing;
    # from 0.95_01 and later, it just lets the objects figure out how to handle 'eq'
    # We want to ensure we preserve the original, as long as it's legal, so we
    # explicitly check the stringified form.
    isa_ok($got, 'version') if defined $expected_version;

    if (ref($expected_version) eq 'CODE') {
      ok(
        $expected_version->($got),
        "case '$test_case->{name}': module version passes match sub"
      )
      or $errs++;
    }
    else {
      is(
        (defined $got ? "$got" : $got),
        $expected_version,
        "case '$test_case->{name}': correct module version ("
          . (defined $expected_version? "'$expected_version'" : 'undef')
          . ')'
      )
      or $errs++;
    }

    is( $warnings, '', "case '$test_case->{name}': no warnings from parsing" ) or $errs++;
    diag Dumper({ got => $pm_info->version, module_contents => $code }) if $errs;
  }
}
continue {
  ++$test_num;
}

done_testing;
