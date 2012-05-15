use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 46;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
  
$t->omit(Last => sub {/bart/i});

is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
  
$t->fieldlist([qw(First Last Age)]);

is_deeply($t->row(0), {qw(First Chris Last Zack Age 43)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15)});
  
$t->row_set(0, {qw(First CHRIS Last ZACK Age 143 State XX)});

is_deeply($t->row(0), {qw(First CHRIS Last ZACK Age 143)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15)});

$t->fieldlist(0);
  
is_deeply($t->row(0), {qw(First CHRIS Last ZACK Age 143 State XX)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});

$t = $People1->snapshot();
$t->row_delete(0);
is_deeply($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(2), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 2);

$t = $People1->snapshot();
$t->row_delete(1,1);
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(2), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 2);

$t = $People1->snapshot();
$t->row_delete(2,2);
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 2);

$t = $People1->snapshot();
$t->row_delete(1,0);
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
cmp_ok($t->length(), '==', 3);

$t = $People1->snapshot();
$t->row_delete();
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
is_deeply($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
cmp_ok($t->length(), '==', 3);

$t = $People1->snapshot();
$t->row_delete(0,1);
is_deeply($t->row(0), {qw(First Pearl Last Muth Age 15 State HI)});
is_deeply($t->row(1), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 1);

$t = $People1->snapshot();
$t->row_delete(1,2);
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 1);

$t = $People1->snapshot();
$t->row_delete(1,3);
is_deeply($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
is_deeply($t->row(1), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 1);

$t = $People1->snapshot();
$t->row_delete(0,2);
is_deeply($t->row(0), {First => '', Last=> '', Age => '', State => ''});
cmp_ok($t->length(), '==', 0);



