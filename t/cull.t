use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 8;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

$t->select_all();
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');

$t->selection([2,1]);
$t->fieldlist([qw(Last State Age)]);

is_deeply(
   $t->cols_hash(),
                  {
                     Last=>[qw(Zack Bart Muth)],
                     State=>[qw(CA NV HI)],
                     Age=>[qw(43 22 15)],
                  });

is_deeply(
   $t->sels_hash(),
                  {
                     Last=>[qw(Muth Bart)],
                     State=>[qw(HI NV)],
                     Age=>[qw(15 22)],
                  });

## cull() makes fieldlist and selection permanent.  So after
## calling it, cols_hash() should return what sels_hash() did
## before.

$t->cull();

is_deeply(
   $t->cols_hash(),
                  {
                     Last=>[qw(Muth Bart)],
                     State=>[qw(HI NV)],
                     Age=>[qw(15 22)],
                  });
  
## .. and so should sels_hash().
is_deeply(
   $t->sels_hash(),
                  {
                     Last=>[qw(Muth Bart)],
                     State=>[qw(HI NV)],
                     Age=>[qw(15 22)],
                  });



