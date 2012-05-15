use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 1;
use Data::CTable;

my $People2 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;

package FooBar;

no strict 'vars'; package main;
$People2->calc(sub{$First = "\U$First\E/@{[$_t->length()]}/$_r/$_s"});

is("@{$People2->col('First')}", "CHRIS/3/0/0 MARCO/3/1/1 PEARL/3/2/2");



