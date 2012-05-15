use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 26;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

## sel() is tested in test_sort();

$t->select_all();
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->sel('First')}", 'Chris Marco Pearl');

$t->sel_set(First=>[qw(C M P)]);
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->sel('First')}", 'C M P');
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->col('First')}", 'C M P');

$t->selection([2,0,1]);
$t->sel_set(First=>[qw(C M P)]);
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->sel('First')}", 'C M P');
cmp_ok($t->sel_len(), '==', 3);
is("@{$t->col('First')}", 'M P C');

$t->selection([2]);
$t->sel_set(First=>[qw(CXXX MXXX PXXX)]);
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->sel('First')}", 'CXXX');
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->col('First')}", 'M P CXXX');
  
$t->selection([1]);
$t->sel_clear('First');
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->sel('First')}", '');
cmp_ok($t->sel_len(), '==', 1);
is("@{$t->col('First')}", 'M  CXXX');
  
$t->selection([2, 1]);
$t->sel_clear('First');
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->sel('First')}", ' ');
cmp_ok($t->sel_len(), '==', 2);
is("@{$t->col('First')}", 'M  ');

## Clean fresh copy of table to test sels() and sels_hash()
my $t = $People1->snapshot();
$t->selection([2, 0]);

is_deeply(
   $t->sels(),
                  [
                   [qw(Pearl Chris)],
                   [qw(Muth Zack)],
                   [qw(15 43)],
                   [qw(HI CA)],
                   ]);

is_deeply(
   $t->sels([qw(Last First)]),
                  [
                   [qw(Muth Zack)],
                   [qw(Pearl Chris)],
                   ]);

is_deeply(
   $t->sels_hash(),
                  {
                     First=>[qw(Pearl Chris)],
                     Last=>[qw(Muth Zack)],
                     Age=>[qw(15 43)],
                     State=>[qw(HI CA)],
                  });

is_deeply(
   $t->sels_hash([qw(Last First)]),
                  {
                     Last=>[qw(Muth Zack)],
                     First=>[qw(Pearl Chris)],
                   });


