use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Data::CTable;

if (exists($ENV{FAST})) {
   plan skip_all => 'A way to skip this test during development.';
}

my $Msgs   = [];

## A helpful little subclass that grabs the output of progress_timer into a local list.
BEGIN {package Data::CTable::SnagTimers; use vars qw(@ISA);
       @ISA=qw(Data::CTable);
      sub progress_timed_default{my $this=shift; my ($Msg) = @_; push @$Msgs, $Msg;
                          $this->SUPER::progress_timed_default($Msg)}}

my $People2 = Data::CTable::SnagTimers->new("$Bin/data/people.tabs.txt") or die;

## Run a test in non- $Wait mode (first message appears immediately)
my $Start     = time();
my $Goal   = 4; ## Seconds.
my $Passed    = 0;

while ($Passed < $Goal)
{
   $Passed = Data::CTable::min($Goal, (time() - $Start));
   $People2->progress_timed("Testing timed progress", $Passed, $Passed, $Goal, 0);
}

cmp_ok(@$Msgs, '>=', 2,               'Really expect at least 3 here...');
like($Msgs->[0],  qr/ 0 \( 0%\)/,     'First message must appear...');
like($Msgs->[-1], qr/$Goal \(100%\)/, 'Last message must appear...');

## Run the test again to test the $Wait mode...

$Msgs      = [];
my $Start     = time();
my $Goal   = 4; ## Seconds.
my $Passed    = 0;

while ($Passed < $Goal)
{
   $Passed = Data::CTable::min($Goal, (time() - $Start));
   $People2->progress_timed("Testing delayed timed progress", $Passed, $Passed, $Goal, 1);
}

cmp_ok(@$Msgs, '>=', 1,               'Really expect at least 2 here...');
like($Msgs->[0],  qr/ 0 \( 0%\)/,     'First message must NOT appear...');
like($Msgs->[-1], qr/$Goal \(100%\)/, 'Last message must appear...');


done_testing;



