use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 12;
use Data::CTable;

my $t = Data::CTable->new("$Bin/data/people.tabs.txt");
is_deeply($t->fieldlist(),         [qw(First Last Age State)]);
is_deeply($t->fieldlist_default(), [qw(Age First Last State)]);

$t->fieldlist([qw(First)]);
is_deeply($t->fieldlist(), [qw(First)]);

$t->fieldlist_set(undef);
is_deeply($t->fieldlist(),         [qw(Age First Last State)]);

$t->fieldlist_force([qw(First)]);
is_deeply($t->fieldlist(), [qw(First)]);

$t->fieldlist_set(undef);
is_deeply($t->fieldlist(), [qw(First)]);

$t->fieldlist_force([qw(Last First)]);
$t->fieldlist_set(undef);
is_deeply($t->fieldlist_all(), [qw(First Last)]);

$t->fieldlist_add('Foo');
$t->fieldlist_add('Bar');
is_deeply($t->fieldlist_all(), [qw(First Last)]);

$t->fieldlist_force([qw(Last First)]);
$t->fieldlist_add('Foo');
$t->fieldlist_add('Bar');
is_deeply($t->fieldlist(), [qw(Last First Foo Bar)]);
is_deeply($t->fieldlist_all(), [qw(First Last)]);

$t->fieldlist_delete('Foo');
$t->fieldlist_delete('Bar');
is_deeply($t->fieldlist(), [qw(Last First)]);
is_deeply($t->fieldlist_all(), [qw(First Last)]);



