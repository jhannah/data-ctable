use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 8;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

$t->sort([qw(Last)]);

is_deeply($t->index_all('Last'), {qw(Zack 0 Bart 1 Muth 2)});
is_deeply($t->index_sel('Last'), {qw(Zack 0 Bart 1 Muth 2)});

is_deeply($t->hash_all('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});
is_deeply($t->hash_sel('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});

$t->omit(Last => sub {/bart/i});

is_deeply($t->index_all('Last'), {qw(Zack 0 Bart 1 Muth 2)});
is_deeply($t->index_sel('Last'), {qw(Zack 0        Muth 2)});

is_deeply($t->hash_all('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});
is_deeply($t->hash_sel('Last', 'First'), {qw(Zack Chris            Muth Pearl)});


