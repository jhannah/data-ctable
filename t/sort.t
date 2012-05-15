use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 32;
use Data::CTable;

my $People2 = Data::CTable->new("$Bin/data/people.tabs.txt");

## Sorting by single text fields with all defaults...
$People2->sort([qw(Last)]);

is("@{$People2->sel('Last')}", 'Bart Muth Zack');
is("@{$People2->sel('First')}", 'Marco Pearl Chris');

$People2->sort([qw(First)]);
is("@{$People2->sel('First')}", 'Chris Marco Pearl');

## Sorting with a non-default sort spec.
$People2->sortspec(Age=>{SortType=>'Integer', SortDirection=>-1});
$People2->sort([qw(Age)]);
is("@{$People2->sel('Age')}",   '43 22 15');
is("@{$People2->sel('First')}", 'Chris Marco Pearl');

## Override a sortspec in the object...
$People2->sort(_SortOrder=>[qw(Age)],_SortSpecs=>{Age=>{SortDirection=>1}});
is("@{$People2->sel('Age')}",   '15 22 43');
is("@{$People2->sel('First')}", 'Pearl Marco Chris');

## Do some sub-sorting...
my $People3 = Data::CTable->new("$Bin/data/people.multivals.txt") or die;

$People3->sort([qw(State Age)]);
is("@{$People3->sel('State')}", 'CA HI KY NV OH OH');
is("@{$People3->sel('Age')}",   '43 15 43 22 41 55');
is("@{$People3->sel('Last')}",  'Edge Muth Bart Bart Mark Zack');

$People3->sortorder([qw(Age State)]);
is_deeply($People3->sortorder(), [qw(Age State)]);

$People3->sort();
is("@{$People3->sel('Age')}",   '15 22 41 43 43 55');
is("@{$People3->sel('State')}", 'HI NV OH CA KY OH');
is("@{$People3->sel('Last')}",  'Muth Bart Mark Edge Bart Zack');

$People3->sort([qw(Last First)]);
is("@{$People3->sel('Last')}",  'Bart Bart Edge Mark Muth Zack');
is("@{$People3->sel('First')}", 'James Marco Chris Sandy Pearl Chris');
is("@{$People3->sel('Age')}",   '43 22 43 41 15 55');

$People3->sort([qw(First Last)]);
is("@{$People3->sel('First')}", 'Chris Chris James Marco Pearl Sandy');
is("@{$People3->sel('Last')}",  'Edge Zack Bart Bart Muth Mark');

is_deeply($People3->sortorder_default(), []);

$People3->sortorder([qw(BOKSDJ Age State Foobxr)]);
$People3->sortorder_check();
is_deeply($People3->sortorder(), [qw(Age State)]);

$People3->sortorder([]);
is_deeply($People3->sortorder(), []);

$People3->sortorder(undef);
is_deeply($People3->sortorder(), []);

$People2->sortspec(Age=>{SortType=>'Integer', SortDirection=>-1});
is_deeply($People2->sortspec('Age'), {SortType=>'Integer', SortDirection=>-1});
is_deeply($People2->sortspecs(), {Age=>{SortType=>'Integer', SortDirection=>-1}});
$People2->sortspec(Beauty=>{SortType=>'String', SortDirection=>1});
is_deeply(
   $People2->sortspecs(), {Age=>{SortType=>'Integer', SortDirection=>-1},
                                    Beauty=>{SortType=>'String', SortDirection=>1},
                                 });

$People2->sortspecs({Frost=>{SortType=>'Integer', SortDirection=>-1},
                Snow=>{SortType=>'String', SortDirection=>1},
             });

is_deeply(
   $People2->sortspecs(), {Frost=>{SortType=>'Integer', SortDirection=>-1},
                                    Snow=>{SortType=>'String', SortDirection=>1},
                                 });

is_deeply($People2->sortspecs_default(), {});
is_deeply(
   $People2->sortspec_default('First'), {SortType=>$People2->sorttype_default(),
                                               SortDirection=>$People2->sortdirection_default(),
                                            });

$People2->sorttype_default('Number');
$People2->sortdirection_default(-1);

is($People2->sorttype_default(), 'Number');
cmp_ok($People2->sortdirection_default(), '==', -1);

is_deeply(
   $People2->sortspec_default('First'), {SortType=>$People2->sorttype_default(),
                                               SortDirection=>$People2->sortdirection_default(),
                                            });



