use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 32;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $Before = $People1->snapshot();
  
my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(0,0);   ## no-op
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->selection(), [0, 1, 2]);

$t->row_move(0,1);   ## no-op
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->selection(), [0, 1, 2]);

$t->row_move(1,2);   ## no-op
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->selection(), [0, 1, 2]);

my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(0,2);   ## move first to before last
is_deeply($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->selection(), [1, 0, 2]);

my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(0,3);   ## move first to end
is_deeply($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(2), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->selection(), [2, 0, 1]);

my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(1,0);   ## move second to beginning (before first)
is_deeply($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->selection(), [1, 0, 2]);

my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(2,0);   ## move last to beginning (before first)
is_deeply($t->row(0), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(2), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->selection(), [1, 2, 0]);

my $t = $Before->snapshot();  $t->selection($t->all());
$t->row_move(2,1);   ## move last to middle (before second)
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(2), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->selection(), [0, 2, 1]);



