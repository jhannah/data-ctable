use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 32;
use Data::CTable;

ok(my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt"),    'new() People1');

my $t = $People1->snapshot();
$t->append($t);
$t->combine_files(["$Bin/data/people.otherdata.tabs.txt"], {_FieldList=>[qw(City Home)]});
is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15 43 22 15');
is("@{$t->col('State')}", 'CA NV HI CA NV HI');
is("@{$t->col('City')}",  'SMC SFO RWC   ');
is("@{$t->col('Home')}",  'Rent Own Share   ');
is("@{$t->fieldlist()}",  'First Last Age State City Home');

my $t = $People1->snapshot();
$t->append($t);
$t->combine_file("$Bin/data/people.otherdata.tabs.txt", {_FieldList=>[qw(City Home)]});
is("@{$t->col('First')}", 'Chris Marco Pearl Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15 43 22 15');
is("@{$t->col('State')}", 'CA NV HI CA NV HI');
is("@{$t->col('City')}",  'SMC SFO RWC   ');
is("@{$t->col('Home')}",  'Rent Own Share   ');
is("@{$t->fieldlist()}",  'First Last Age State City Home');

my $t = $People1->snapshot();
my $o = Data::CTable->new("$Bin/data/people.otherdata.tabs.txt") or die;

$t->combine($o);

is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('City')}",  'SMC SFO RWC');
is("@{$t->col('Home')}",  'Rent Own Share');

my $t = $People1->snapshot();
$t->combine_file("$Bin/data/people.otherdata.tabs.txt", {_FieldList=>[qw(Home)]});

is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');
ok(!$t->col_exists('City'));
is("@{$t->col('Home')}",  'Rent Own Share');

$t->combine_file("$Bin/data/people.otherdata.tabs.txt", {_FieldList=>[qw(City)]});
is("@{$t->col('City')}", 'SMC SFO RWC');
is("@{$t->fieldlist()}", 'First Last Age State Home City');

my $t = $People1->snapshot();
$t->combine_file("$Bin/data/people.otherdata.tabs.txt", {_FieldList=>[qw(Home City)]});
is("@{$t->col('City')}", 'SMC SFO RWC');
is("@{$t->col('Home')}", 'Rent Own Share');
is("@{$t->fieldlist()}", 'First Last Age State Home City');



