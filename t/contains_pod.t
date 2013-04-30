use strict;
use warnings;
use Test::More tests => 3;
use Module::Metadata;

{
    my $src = <<'...';
package Foo;
1;
...

    open my $fh, '<', \$src;
    my $module = Module::Metadata->new_from_handle($fh, 'Foo.pm');
    ok(!$module->contains_pod(), 'This module does not contains POD');
}

{
    my $src = <<'...';
package Foo;
1;

=head1 NAME

Foo - bar
...

    open my $fh, '<', \$src;
    my $module = Module::Metadata->new_from_handle($fh, 'Foo.pm');
    ok($module->contains_pod(), 'This module contains POD');
}

{
    my $src = <<'...';
package Foo;
1;

=head1 NAME

Foo - bar

=head1 AUTHORS

Tokuhiro Matsuno
...

    open my $fh, '<', \$src;
    my $module = Module::Metadata->new_from_handle($fh, 'Foo.pm');
    ok($module->contains_pod(), 'This module contains POD');
}
