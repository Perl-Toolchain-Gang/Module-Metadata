use strict;
use warnings;
use Test::More;
use Module::Metadata;
use lib "t/lib/0_2";

plan tests => 6;

require Foo;
is($Foo::VERSION, 0.2, 'affirmed version of loaded module');

my $meta = Module::Metadata->new_from_module("Foo", inc => [ "t/lib/0_1" ] );
is($meta->version, 0.1, 'extracted proper version from scanned module');

is($Foo::VERSION, 0.2, 'loaded module still retains its version');

ok(eval "use Foo 0.2; 1", 'successfully loaded module again')
    or diag 'got exception: ', $@;

my $bar_meta = Module::Metadata->new_from_module("Bar", inc => [ "t/lib/0_1" ] );
is scalar @{$bar_meta->{packages}}, 2, 'found 2 packages in Bar';
is $bar_meta->{versions}{'Bar::History'}, $bar_meta->{versions}{'Bar'}, 'Bars version gets passed to Bar::History';
