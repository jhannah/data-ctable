use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 40;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $t = $People1->snapshot();

is_deeply(
   [sort keys %{$t->sortroutines()}],
                  [sort qw(
                         Boolean
                         _RecNum
                         Text
                         Integer
                         DateSecs
                         Number
                         String
                         )]);

$t->sortroutine("INetAddr", sub {"Foo"});

is_deeply(
   [sort keys %{$t->sortroutines()}],
                  [sort qw(
                         Boolean
                         _RecNum
                         Text
                         Integer
                         DateSecs
                         Number
                         String
                         INetAddr
                         )]);

is_deeply(
   [sort keys %{$t->sortroutines_builtin()}],
                  [sort qw(
                         Boolean
                         _RecNum
                         Text
                         Integer
                         DateSecs
                         Number
                         String
                         )]);

$t->sortroutine("INetAddr", 0);
is_deeply(
   [sort keys %{$t->sortroutines()}],
                  [sort qw(
                         Boolean
                         _RecNum
                         Text
                         Integer
                         DateSecs
                         Number
                         String
                         )]);

$t->sortroutine("INetAddr", sub {"Foo"});
$t->sortroutine_set("INetAddr");
is_deeply(
   [sort keys %{$t->sortroutines()}],
                  [sort qw(
                         Boolean
                         _RecNum
                         Text
                         Integer
                         DateSecs
                         Number
                         String
                         )]);

cmp_ok(&{$t->sortroutine('Boolean')}(\ 0, \ 1), '==', -1);
cmp_ok(&{$t->sortroutine('Boolean')}(\ 1, \ 0), '==',  1);
cmp_ok(&{$t->sortroutine('Boolean')}(\ 1, \ 1), '==',  0);
cmp_ok(&{$t->sortroutine('Boolean')}(\ 0, \ 0), '==',  0);

cmp_ok(&{$t->sortroutine('Integer')}(\ 0, \ 1), '==', -1);
cmp_ok(&{$t->sortroutine('Integer')}(\ 1, \ 0), '==',  1);
cmp_ok(&{$t->sortroutine('Integer')}(\ 1, \ 1), '==',  0);
cmp_ok(&{$t->sortroutine('Integer')}(\ 0, \ 0), '==',  0);

cmp_ok(&{$t->sortroutine('Integer')}(\ 22, \ 22.5), '==',  0);

cmp_ok(&{$t->sortroutine('_RecNum')}(\ 0, \ 1), '==', -1);
cmp_ok(&{$t->sortroutine('_RecNum')}(\ 1, \ 0), '==',  1);
cmp_ok(&{$t->sortroutine('_RecNum')}(\ 1, \ 1), '==',  0);
cmp_ok(&{$t->sortroutine('_RecNum')}(\ 0, \ 0), '==',  0);

cmp_ok(&{$t->sortroutine('DateSecs')}(\ 0, \ 1), '==', -1);
cmp_ok(&{$t->sortroutine('DateSecs')}(\ 1, \ 0), '==',  1);
cmp_ok(&{$t->sortroutine('DateSecs')}(\ 1, \ 1), '==',  0);
cmp_ok(&{$t->sortroutine('DateSecs')}(\ 0, \ 0), '==',  0);

cmp_ok(&{$t->sortroutine('Number')}(\ 0, \ 1), '==', -1);
cmp_ok(&{$t->sortroutine('Number')}(\ 1, \ 0), '==',  1);
cmp_ok(&{$t->sortroutine('Number')}(\ 1, \ 1), '==',  0);
cmp_ok(&{$t->sortroutine('Number')}(\ 0, \ 0), '==',  0);

cmp_ok(&{$t->sortroutine('Number')}(\ 10.66, \ 10.77), '==', -1);
cmp_ok(&{$t->sortroutine('Number')}(\ 20, \ 15), '==',  1);
cmp_ok(&{$t->sortroutine('Number')}(\ 10.0, \ 10), '==',  0);
cmp_ok(&{$t->sortroutine('Number')}(\ 20, \ 20.0), '==',  0);

cmp_ok(&{$t->sortroutine('String')}(\ "", \ "a"), '==', -1);
cmp_ok(&{$t->sortroutine('String')}(\ "b", \ "a"), '==',  1);
cmp_ok(&{$t->sortroutine('String')}(\ "b", \ "b"), '==',  0);
cmp_ok(&{$t->sortroutine('String')}(\ "", \ undef), '==',  0);

cmp_ok(&{$t->sortroutine('String')}(\ "b", \ "B"), '==',  1);

cmp_ok(&{$t->sortroutine('Text')}(\ "", \ "a"), '==', -1);
cmp_ok(&{$t->sortroutine('Text')}(\ "b", \ "a"), '==',  1);
cmp_ok(&{$t->sortroutine('Text')}(\ "b", \ "b"), '==',  0);
cmp_ok(&{$t->sortroutine('Text')}(\ "", \ undef), '==',  0);

cmp_ok(&{$t->sortroutine('Text')}(\ "b", \ "B"), '==',  0);



