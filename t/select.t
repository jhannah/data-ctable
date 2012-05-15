use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 18;
use Data::CTable;

my $t = Data::CTable->new("$Bin/data/stats.tabs.unix.txt");
$t->select_all();
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->sel('DeptNum')}", '1115 2203 2209');

$t->select_none();
cmp_ok($t->sel_len(), '==', 0);
is("@{$t->sel('DeptNum')}", '');

$t->select_all();
$t->select(PersonID => sub {/chris/i});
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->sel('DeptNum')}", '2203');

$t->select_none();
$t->add(PersonID => sub {/chris/i});
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->sel('DeptNum')}", '2203');

$t->select_none();
$t->add(PersonID => sub {/chris/i});
$t->add(PersonID => sub {/bart/i});
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->sel('DeptNum')}", '2203 2209');

$t->sort([qw(PersonID)]);
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->sel('DeptNum')}", '2209 2203');

$t->select_none();
$t->but(PersonID => sub {/chris/i});
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->sel('DeptNum')}", '1115 2209');

$t->select_all();
$t->omit(PersonID => sub {/chris/i});
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->sel('DeptNum')}", '1115 2209');

$t->select_all();
$t->select(DeptNum    => sub {$_ > 2000});
$t->omit  (Department => sub {/resale/i});
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->sel('DeptNum')}", '2203');



