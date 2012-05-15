use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 35;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

is_deeply($t->row_empty(), {First => '', Last=> '', Age => '', State => ''});
is_deeply($t->row_empty(), $t->fieldlist_hash());

ok(!$t->row_exists(-1));
ok( $t->row_exists(0));
ok( $t->row_exists(1));
ok( $t->row_exists(2));
ok(!$t->row_exists(3));

$t->row_delete(0,2); ## Delete all rows.  None should exist.
ok(!$t->row_exists(-1));
ok(!$t->row_exists(0));
ok(!$t->row_exists(1));

## Use row_set to make an empty table with 11 rows.
$t = Data::CTable->new();
cmp_ok($t->length(), '==', 0);
$t->row_set(10, {First => undef, Last => undef, Age => undef});
cmp_ok($t->length(), '==', 11);
ok(!$t->row_exists(-1));
ok( $t->row_exists(0));
ok( $t->row_exists(10));
ok(!$t->row_exists(11));
is_deeply($t->fieldlist(), [qw(Age First Last)]);

## length_set() to truncate and extend
$t = Data::CTable->new();
return(0) unless $t->length() == 0;

$t->length_set(22);  ## Should be a no-op on empty table.
return(0) unless $t->length() == 0;
$t->row_set(10, {First => undef, Last => undef, Age => undef});

$t->length_set(5);   ## Truncate empty table to 5 entries.
return(0) unless $t->length() == 5;
return(0) unless  $t->row_exists(4);
return(0) unless !$t->row_exists(5);

## Test the extend() operator.
$#{$t->col('First')} = 10;
$t->extend();
return(0) unless $t->length() == 11;

## rows() operator
my $t = $People1->snapshot();
is_deeply(
   $t->rows([0,1,2]), [
                                 {qw(First Chris Last Zack Age 43 State CA)},
                                 {qw(First Marco Last Bart Age 22 State NV)},
                                 {qw(First Pearl Last Muth Age 15 State HI)},
                                 ]);

is_deeply(
   $t->rows([0,2,1]), [
                                 {qw(First Chris Last Zack Age 43 State CA)},
                                 {qw(First Pearl Last Muth Age 15 State HI)},
                                 {qw(First Marco Last Bart Age 22 State NV)},
                                 ]);

is_deeply(
   $t->rows([0]), [
                                 {qw(First Chris Last Zack Age 43 State CA)},
                                 ]);

is_deeply(
   $t->rows([2]), [
                                 {qw(First Pearl Last Muth Age 15 State HI)},
                                 ]);

## row_list()
is_deeply($t->row_list(0), [qw(Chris Zack 43 CA)]);
is_deeply($t->row_list(1), [qw(Marco Bart 22 NV)]);
is_deeply($t->row_list(2), [qw(Pearl Muth 15 HI)]);

is_deeply($t->row_list(0, [qw(State Age)]), [qw(CA 43)]);
is_deeply($t->row_list(1, [qw(State Age)]), [qw(NV 22)]);
is_deeply($t->row_list(2, [qw(State Age)]), [qw(HI 15)]);


## row_list_set()

my $t = $People1->snapshot();
$t->row_list_set(0, undef, [qw(CHRIS Zack 43.0 CA)]);
$t->row_list_set(1, undef, [qw(Marco BART 22.0 Nevada)]);
$t->row_list_set(2, undef, [qw(PEARL Muth 15.0 HI)]);

is_deeply($t->col('First'), [qw(CHRIS Marco PEARL)]);
is_deeply($t->col('Last' ), [qw(Zack BART Muth)]);
is_deeply($t->col('Age'  ), [qw(43.0 22.0 15.0)]);
is_deeply($t->col('State'), [qw(CA Nevada HI)]);

my $t = $People1->snapshot();
$t->row_list_set(0, [qw(Last First)], [qw(Zack CHRIS 43.0 CA)]);
$t->row_list_set(1, [qw(Last First)], [qw(BART Marco 22.0 Nevada)]);
$t->row_list_set(2, [qw(Last First)], [qw(Muth PEARL 15.0 HI)]);

is_deeply($t->col('First'), [qw(CHRIS Marco PEARL)]);
is_deeply($t->col('Last' ), [qw(Zack BART Muth)]);
is_deeply($t->col('Age'  ), [qw(43 22 15)]);
is_deeply($t->col('State'), [qw(CA NV HI)]);


