use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 48;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
is("@{$People1->col('First')}", 'Chris Marco Pearl');
is("@{$People1->col('Last')}",  'Zack Bart Muth');
is("@{$People1->col('Age')}",   '43 22 15');
is("@{$People1->col('State')}", 'CA NV HI');

my $t = $People1->snapshot();
is("@{$t->col_get('First')}", 'Chris Marco Pearl');

$t->col_set(First=>[qw(Basil Horty Ringo)]);
is("@{$t->col_get('First')}", 'Basil Horty Ringo');

$t->col(First=>[qw(Horty Basil Ringo)]);
is("@{$t->col_get('First')}", 'Horty Basil Ringo');

$t->col_delete('First');
ok(!$t->col_exists('First'));
is_deeply($t->fieldlist(), [qw(Last Age State)]);
is_deeply($t->col('First'), [undef, undef, undef]);
ok( $t->col_exists('First'));

is_deeply($t->col_default(), [undef, undef, undef]);
is_deeply($t->col_empty(),   [undef, undef, undef]);
is_deeply($t->col_empty(0),  []);
is_deeply($t->col_empty($t->col('Last')), [undef, undef, undef]);

my $t = $People1->snapshot();
  
ok( $t->col_exists('First'));
ok( $t->col_exists('Last'));
ok( $t->col_exists('Age'));
ok( $t->col_exists('State'));
ok(!$t->col_exists('Firstx'));

$t->fieldlist([qw(Last First)]);

ok( $t->col_exists('First'));
ok( $t->col_exists('Last'));
ok( $t->col_exists('Age'));
ok( $t->col_exists('State'));

ok( $t->col_active('First'));
ok( $t->col_active('Last'));
ok(!$t->col_active('Age'));
ok(!$t->col_active('State'));

$t->fieldlist(0);

ok($t->col_exists('First'));
ok($t->col_exists('Last'));
ok($t->col_exists('Age'));
ok($t->col_exists('State'));

ok($t->col_active('First'));
ok($t->col_active('Last'));
ok($t->col_active('Age'));
ok($t->col_active('State'));

is_deeply(
   $t->cols([qw(State Age)]),
                  [[qw(CA NV HI)], [qw(43 22 15)]]);
is_deeply(
   $t->cols([qw(Last First)]),
                  [[qw(Zack Bart Muth)], [qw(Chris Marco Pearl)]]);
is_deeply(
   $t->cols([]),
                  []);

return(0) unless my $t = $People1->snapshot();
is_deeply(
   $t->cols(),
                  [
                   [qw(Chris Marco Pearl)],
                   [qw(Zack Bart Muth)],
                   [qw(43 22 15)],
                   [qw(CA NV HI)],
                   ]);

is_deeply(
   $t->cols_hash([qw(State Age)]),
                  {State=>[qw(CA NV HI)], Age=>[qw(43 22 15)]});
is_deeply(
   $t->cols_hash([qw(Last First)]),
                  {Last=>[qw(Zack Bart Muth)], First=>[qw(Chris Marco Pearl)]});
is_deeply(
   $t->cols_hash([]),
                  {});
is_deeply(
   $t->cols_hash([qw(Last First)]),
                  {Last=>[qw(Zack Bart Muth)],
                   First=>[qw(Chris Marco Pearl)]});

$t->fieldlist([qw(Last Age First)]);
is_deeply(
   $t->cols(),
                  [
                   [qw(Zack Bart Muth)],
                   [qw(43 22 15)],
                   [qw(Chris Marco Pearl)],
                   ]);

my $t = $People1->snapshot();

## Column renaming
$t->col_rename(First=>'FirstName');
$t->col_rename(Last=>'LastName');
$t->fieldlist([qw(LastName FirstName)]);

is_deeply(
   $t->cols(),
                  [
                   [qw(Zack Bart Muth)],
                   [qw(Chris Marco Pearl)],
                   ]);
$t->fieldlist(0);
is_deeply(
   $t->cols_hash(),
                  {LastName=>[qw(Zack Bart Muth)],
                   FirstName=>[qw(Chris Marco Pearl)],
                   Age=>[qw(43 22 15)],
                   State=>[qw(CA NV HI)]});

is_deeply(
   $t->fieldlist_all(), [qw(Age FirstName LastName State)]);



