use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 17;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

is_deeply($t->selection(), [0, 1, 2]);
is_deeply($t->selection_get(), [0, 1, 2]);

$t->selection($t->all());
is_deeply($t->selection(), [0, 1, 2]);

$t->selection([2,1,0]);
is_deeply($t->selection(), [2, 1, 0]);

$t->selection_set([1,2,0]);
is_deeply($t->selection(), [1, 2, 0]);

$t->selection_set();
is_deeply($t->selection(), [0, 1, 2]);

$t->selection_set([5, 1,2,3, 0, -1]);
is_deeply($t->selection(), [5, 1, 2, 3, 0, -1]);

$t->selection_validate();
is_deeply($t->selection(), [1, 2, 0]);

is_deeply($t->selection_inverse(), []);

$t->selection_set([0]);
is_deeply($t->selection_inverse(), [1, 2]);

$t->selection_set([1, 0]);
is_deeply($t->selection_inverse(), [2]);

$t->selection_set([0, 2]);
is_deeply($t->selection_inverse(), [1]);

$t->selection_set([0, 2]);
$t->select_inverse();
is_deeply($t->selection(), [1]);

$t->selection_set([0, 2]);
$t->select_all();
is_deeply($t->selection(), [0, 1, 2]);

$t->selection_set([0, 2]);
$t->selection_set(undef);
is_deeply($t->selection(), [0, 1, 2]);

$t->selection_set([0, 2]);
$t->selection_delete();
is_deeply($t->selection(), [0, 1, 2]);

$t->selection_set([0, 2]);
is_deeply($t->all(), [0, 1, 2]);


