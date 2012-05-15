use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 10;
use Data::CTable;


my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;
ok(my $t = $People1->snapshot());
is_deeply({%$People1}, {%$t});

## Then test snapshotting after there is a selection.

is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');

$t->selection([2,0]);
$t->fieldlist([qw(State Age)]);

my $x = $t->snapshot();

is("@{$x->col('First')}", ' ');
is("@{$x->col('Last')}",  ' ');
is("@{$x->col('Age')}",   '15 43');
is("@{$x->col('State')}", 'HI CA');



