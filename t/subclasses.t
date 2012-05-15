use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 1;

use Data::CTable::ProgressLogger;

my $People2 = Data::CTable::ProgressLogger->new("$Bin/data/people.tabs.txt");
cmp_ok(@{$People2->log()}, '>=', 1);



