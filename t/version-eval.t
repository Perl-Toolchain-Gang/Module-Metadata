#use 5.008001;
use strict;
use warnings;
use Test::More 0.96;
#use Test::FailWarnings;

use version;
use Module::Metadata::ExtractVersion qw/eval_version/;

my @cases = (
    # decimals
    {
        label  => "bare decimal",
        string => q[$VERSION = "1.23";],
        expect => "1.23",
    },
    {
        label  => "our decimal",
        string => q[our $VERSION = "1.23";],
        expect => "1.23",
    },
    {
        label  => "qualified decimal",
        string => q[$Foo::VERSION = "1.23";],
        expect => "1.23",
    },
    {
        label  => "alpha decimal",
        string => q[our $VERSION = "1.23_01";],
        expect => "1.23_01",
    },
    # v-strings
    {
        label  => "bare v-string",
        string => q[$VERSION = v1.2.3;],
        expect => "v1.2.3",
    },
    {
        label  => "our v-string",
        string => q[our $VERSION = v1.2.3;],
        expect => "v1.2.3",
    },
    {
        label  => "qualified v-string",
        string => q[$Foo::VERSION = v1.2.3;],
        expect => "v1.2.3",
    },
    {
        label  => "alpha v-string",
        string => q[our $VERSION = v1.2.3_4;],
        expect => "v1.2.3_4",
    },
    # dotted-decimals
    {
        label  => "bare dotted-decimal string",
        string => q[$VERSION = "v1.2.3";],
        expect => "v1.2.3",
    },
    {
        label  => "our dotted-decimal string",
        string => q[our $VERSION = "v1.2.3";],
        expect => "v1.2.3",
    },
    {
        label  => "qualified dotted-decimal string",
        string => q[$Foo::VERSION = "v1.2.3";],
        expect => "v1.2.3",
    },
    {
        label  => "alpha dotted-decimal string",
        string => q[our $VERSION = "v1.2.3_4";],
        expect => "v1.2.3_4",
    },
    # version.pm
    {
        label  => "use version.pm + qv",
        string => q[use version; our $VERSION = qv("1.2.3");],
        expect => "v1.2.3",
    },
    {
        label  => "require version.pm + version::qv",
        string => q[require version; our $VERSION = version::qv("1.2.3");],
        expect => "v1.2.3",
    },
    {
        label  => "use version.pm + new",
        string => q[use version; our $VERSION = version->new("1.2.3");],
        expect => "v1.2.3",
    },
    {
        label  => "use version.pm + new + numify",
        string => q[use version; our $VERSION = version->new("1.2.3")->numify;],
        expect => "v1.2.3",
    },
    {
        label  => "use version.pm + new + normal",
        string => q[use version; our $VERSION = version->new("1.2.3")->normal;],
        expect => "v1.2.3",
    },
    {
        label  => "use version.pm + declare",
        string => q[use version; our $VERSION = version->declare("1.2.3");],
        expect => "v1.2.3",
    },
    {
        label  => "version.pm in eval",
        string => q[$VERSION = eval 'use version; 1' ? 'version'->new('1.23') : '1.23';],
        expect => "1.23",
    },
    # syntax
    {
        label  => "no trailing semicolon",
        string => q[$VERSION = "1.23"],
        expect => "1.23",
    },
    # errors
    {
        label  => "syntax error",
        string => q[$VERSION do { my $n; $n++ while 1; return $_ };],
        expect => undef,
    },
    {
        label  => "exit",
        string => q[$VERSION = 1.23; exit;],
        expect => undef,
    },
    {
        label  => "die",
        string => q[$VERSION = 1.23; die;],
        expect => undef,
    },
    {
        label  => "require something not already loaded",
        string => q[require Digest; $VERSION = 1.23;],
        expect => undef,
    },
    # malicious
    {
        label  => "infinite loop",
        string => q[$VERSION = do { my $n; $n++ while 1; return $_ };],
        expect => undef,
    },
);

for my $c (@cases) {
    my $got = eval_version( $c->{string} );
    my $expect = defined $c->{expect} ? version->parse( $c->{expect} ) : undef;
    is( $got, $expect, $c->{label} );
}

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
