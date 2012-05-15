use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 2;
use Data::CTable;

my $People2 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;
my $People2 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;

## Then read uncached...
my $People3 = Data::CTable->new({_CacheOnRead => 0},
                        "$Bin/data/people.tabs.txt") or die;

## And compare everything except the _CacheOnRead setting...

is_deeply(
   {%$People2, _CacheOnRead=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore'}
);

## Same test again but with a restrictive field list....

## First read cached...
my $People2 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;
my $People2 = Data::CTable->new({_FieldList => [qw(First Last)]},
                        "$Bin/data/people.tabs.txt") or die;

## Then read uncached...
my $People3 = Data::CTable->new({(_FieldList => [qw(First Last)],
                          _CacheOnRead => 0)},
                        "$Bin/data/people.tabs.txt") or die;

## $People2->dump($People2, $People3);

## And compare everything except the _CacheOnRead setting...

is_deeply(
   {%$People2, _CacheOnRead=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore'}
);



