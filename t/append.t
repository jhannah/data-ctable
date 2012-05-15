use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 42;
use Data::CTable;

ok(my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt"),    'new() People1');

## Regular appending
my $t = $People1->snapshot();
$t->append($People1);

is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15 43 22 15');
is("@{$t->col('State')}", 'CA NV HI CA NV HI');

## Concatenation when only other table has selection
my $t = $People1->snapshot();
my $u = $People1->snapshot();
$u->selection([1]);
$t->append($u);

is("@{$t->col('First')}", 'Chris Marco Pearl Marco');
is("@{$t->col('Last')}",  'Zack Bart Muth Bart');
is("@{$t->col('Age')}",   '43 22 15 22');
is("@{$t->col('State')}", 'CA NV HI NV');
is("@{$t->selection()}",  '0 1 2 3');

my $t = $People1->snapshot();
my $u = $People1->snapshot();
$u->selection([1,0]);
$t->append($u);
  
is("@{$t->col('First')}", 'Chris Marco Pearl Marco Chris');
is("@{$t->col('Last')}",  'Zack Bart Muth Bart Zack');
is("@{$t->col('Age')}",   '43 22 15 22 43');
is("@{$t->col('State')}", 'CA NV HI NV CA');
is("@{$t->selection()}",  '0 1 2 3 4');

## Concatenation when both tables have selection
my $t = $People1->snapshot();
$t->selection([2]);

my $u = $People1->snapshot();
$u->selection([1,0]);
$t->append($u);

is("@{$t->col('First')}", 'Chris Marco Pearl Marco Chris');
is("@{$t->col('Last')}",  'Zack Bart Muth Bart Zack');
is("@{$t->col('Age')}",   '43 22 15 22 43');
is("@{$t->col('State')}", 'CA NV HI NV CA');
is("@{$t->selection()}",  '2 3 4');

is("@{$t->sel('First')}", 'Pearl Marco Chris');
is("@{$t->sel('Last')}",  'Muth Bart Zack');
is("@{$t->sel('Age')}",   '15 22 43');
is("@{$t->sel('State')}", 'HI NV CA');

## Concatenation when other table has a field list.
my $t = $People1->snapshot();
my $u = $People1->snapshot();
$u->fieldlist([qw(First Last)]);
$t->append($u);

is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15   ');
is("@{$t->col('State')}", 'CA NV HI   ');
is("@{$t->fieldlist()}",  'First Last Age State');

## Concatenation when both tables have a field list
my $t = $People1->snapshot();
my $u = $People1->snapshot();
$u->fieldlist([qw(First Last)]);
$t->fieldlist([qw(Age)]);
$t->append($u);

is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15   ');
is("@{$t->col('State')}", 'CA NV HI   ');
is("@{$t->fieldlist()}",  'Age First Last');


## Test's new() calling append_files() calling read() and append_file()
my $t = Data::CTable->new(("$Bin/data/people.tabs.txt") x 2) or die;

is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15 43 22 15');
is("@{$t->col('State')}", 'CA NV HI CA NV HI');


## Test's new() calling append_files() calling read() and append_file()
my $t = Data::CTable->new({_FieldList=>[qw(First Last)]}, ("$Bin/data/people.tabs.txt") x 2) or die;

is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
ok(!$t->col_exists('Age'));
ok(!$t->col_exists('State'));




