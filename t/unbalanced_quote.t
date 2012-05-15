use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 6;
use Data::CTable;

ok(my $People = Data::CTable->new({ _IgnoreQuotes => 1 }, "$Bin/data/people.unbalanced.quote.txt") or die);
is($People->row_list(0)->[0], 'Jay',           'FirstName');
is($People->row_list(0)->[1], 'Hannah',        'LastName');
is($People->row_list(0)->[2], '12" is 1 foot', 'Quote');
is($People->row_list(0)->[3], '37',            'Age');
is($People->row_list(0)->[4], 'NE',            'State');


