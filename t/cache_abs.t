use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Data::CTable;

# -------
# Yoinked from 
#    git://git.shadowcat.co.uk/catagits/Catalyst-Runtime.git
#    catalyst-runtime/t/aggregate/unit_core_path_to.t 
my %non_unix = (
    MacOS   => 1,
    MSWin32 => 1,
    os2     => 1,
    VMS     => 1,
    epoc    => 1,
    NetWare => 1,
    dos     => 1,
    cygwin  => 1,
);
my $os = $non_unix{$^O} ? $^O : 'Unix';
if ( $os ne 'Unix' ) {
    plan skip_all => 'tests require Unix';
}
# -------

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");
my $People2 = Data::CTable->new({_CacheSubDir=>"/tmp"}, "$Bin/data/people.tabs.txt") or die;

is_deeply(
   {%$People1, _CacheSubDir=>'ignore'},
   {%$People2, _CacheSubDir=>'ignore'},
);


done_testing;

