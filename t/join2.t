use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 7;
use Data::CTable;

ok(my $People   = Data::CTable->new("$Bin/data/people.merge.mac.txt"),    'new() People');
ok(my $Stats    = Data::CTable->new("$Bin/data/stats.tabs.unix.txt"),     'new() Stats');

## Clean any messy extra whitespace in field values
ok($People->clean_ws(),  'clean_ws() People');
ok($Stats ->clean_ws(),  'clean_ws() Stats');

## Retrieve columns
ok(my $First = $People->col('FirstName'),    'col() FirstName');
ok(my $Last  = $People->col('LastName' ),    'col() LastName');

## Calculate a new column based on two others
my $Full  = [map {"$First->[$_] $Last->[$_]"} @{$People->all()}];

## Add new column to the table
$People->col(FullName => $Full);

## Another way to calculate a new column
$People->col('Key');
$People->calc(sub {$main::Key = "$main::LastName,$main::FirstName";});

## "Left join" records where Stats:PersonID eq People:Key
$Stats->join($People, PersonID => 'Key');

## Find certain records
$Stats->select_all();

$Stats->select(Department => sub {/Sale/i  });  ## Sales dept.

$Stats->omit  (Department => sub {/Resale/i});  ## not Resales

$Stats->select(UsageIndex => sub {$_ > 20.0});  ## high usage

my $Data = [$Stats->fieldlist(), $Stats->row_list(1)];

is_deeply(
   $Data, 
   [
      [ qw(PersonID Department DeptNum UsageIndex FirstName LastName Age State FullName) ],
      [ "Zack,Chris","Retail Sales","2203","21.0","Chris","Zack","43","CA","Chris Zack"  ],
   ],
   "is_deeply()"
);



