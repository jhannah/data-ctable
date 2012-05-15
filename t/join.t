use FindBin qw/$Bin/;
use lib "$Bin/lib";
use Common;

use Test::More tests => 12;
use Data::CTable;

ok(my $People   = Data::CTable->new("$Bin/data/people.merge.mac.txt"),    'new() People');
ok(my $Stats    = Data::CTable->new("$Bin/data/stats.tabs.unix.txt"),     'new() Stats');

## Calculate a key field that can be used to match records bi-directionally.

ok($People->col('Key'),                                        'creating a new column, Key');
ok($People->calc(
   sub {$main::Key = "$main::LastName,$main::FirstName";}
),                                                             'calc()');

## Do the joins in EACH direction.  In this test, there should be
## no mismatched records.

## "Left join" records where Stats:PersonID eq People:Key
ok($Stats->join($People, PersonID => 'Key'),                   'join() People');

## "Left join" records where People:Key eq Stats:PersonID
ok($People->join($Stats, Key => 'PersonID'),                   'join() Stats');

## The two tables should now look like this...

## $Stats->out();

##  +------------+---------------+---------+------------+-----------+----------+-----+-------+
##  |  PersonID  |  Department   | DeptNum | UsageIndex | FirstName | LastName | Age | State |
##  +------------+---------------+---------+------------+-----------+----------+-----+-------+
##  | Muth,Pearl | Channel Sales | 1115    | 18.55      | Pearl     | Muth     | 15  | HI    |
##  | Zack,Chris | Retail Sales  | 2203    | 21.0       | Chris     | Zack     | 43  | CA    |
##  | Bart,Marco | Resale        | 2209    | 35.6       | Marco     | Bart     | 22  | NV    |
##  +------------+---------------+---------+------------+-----------+----------+-----+-------+

## $People->out();

##  +-----------+----------+-----+-------+------------+---------------+---------+------------+
##  | FirstName | LastName | Age | State |    Key     |  Department   | DeptNum | UsageIndex |
##  +-----------+----------+-----+-------+------------+---------------+---------+------------+
##  | Chris     | Zack     | 43  | CA    | Zack,Chris | Retail Sales  | 2203    | 21.0       |
##  | Marco     | Bart     | 22  | NV    | Bart,Marco | Resale        | 2209    | 35.6       |
##  | Pearl     | Muth     | 15  | HI    | Muth,Pearl | Channel Sales | 1115    | 18.55      |
##  +-----------+----------+-----+-------+------------+---------------+---------+------------+

is_deeply(
   $Stats->row_list(0),
   [ "Muth,Pearl", "Channel Sales", "1115", "18.55", "Pearl", "Muth", "15", "HI" ],
   "row_list(0)"
);

is_deeply(
   $People->row_list(2),
   [ "Pearl", "Muth", "15", "HI", "Muth,Pearl", "Channel Sales", "1115", "18.55"],
   "row_list(2)"
);

## Now do another test where the join will NOT be complete (some records will mismatch).

my $People   = Data::CTable->new("$Bin/data/people.merge.mac.txt") or die;
my $Abbrevs  = Data::CTable->new("$Bin/data/stateabbrevs.tabs.txt");
$Abbrevs->col_rename(State=>'FullState');

## "Left join" records where People:State eq Abbrevs:Abb
$People->join($Abbrevs, State => 'Abb');

## "Left join" records where Abbrevs:Abb eq People:State
$Abbrevs->join($People, Abb => 'State');

## Resulting joins should result in one unmatched row in each table:

## $People->out();

##  +-----------+----------+-----+-------+------------+
##  | FirstName | LastName | Age | State | FullState  |
##  +-----------+----------+-----+-------+------------+
##  | Chris     | Zack     | 43  | CA    | California |
##  | Marco     | Bart     | 22  | NV    | Nevada     |
##  | Pearl     | Muth     | 15  | HI    |            |
##  +-----------+----------+-----+-------+------------+

## $Abbrevs->out();

##  +-----+------------+-----------+----------+-----+
##  | Abb | FullState  | FirstName | LastName | Age |
##  +-----+------------+-----------+----------+-----+
##  | CA  | California | Chris     | Zack     | 43  |
##  | NV  | Nevada     | Marco     | Bart     | 22  |
##  | OH  |            |           |          |     |
##  +-----+------------+-----------+----------+-----+

is_deeply(
   $People->row_list(0),
   [ qw( Chris Zack 43 CA California ) ],
   "row_list(0)"
);
is_deeply(
   $People->row_list(2),
   [ 'Pearl', 'Muth', 15, 'HI', undef ],
   "row_list(2)"
);

is_deeply(
   $Abbrevs->row_list(0),
   [ qw( CA California Chris Zack 43 ) ],
   "row_list(0)"
);
is_deeply(
   $Abbrevs->row_list(2),
   [ 'OH', undef, undef, undef, undef ],
   "row_list(2)"
);


