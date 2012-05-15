use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 4;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;
$People1->progress("TEST_WRITE PASS 1");

## Read (not from cache);
my $People2 = Data::CTable->new({_CacheOnRead=>0}, "$Bin/data/people.tabs.txt") or die;

## Write to ".out" file.
my $OutFile = $People2->write() or die;

## Re-read (not from cache)
my $People3 = Data::CTable->new({_CacheOnRead=>0}, $OutFile) or die;

is_deeply(
   {%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},
);

$People1->progress("TEST_WRITE PASS 2");

## Read (from cache)
my $People2 = Data::CTable->new({_CacheOnRead=>1}, "$Bin/data/people.tabs.txt") or die;

## Write to ".out" file.
my $OutFile = $People2->write() or die;

## Re-read (not from cache)
my $People3 = Data::CTable->new({_CacheOnRead=>0}, $OutFile) or die;

is_deeply(
   {%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},
);

$People1->progress("TEST_WRITE PASS 3");

## Read (from cache)
my $People2 = Data::CTable->new({_CacheOnRead=>1}, "$Bin/data/people.tabs.txt") or die;

## Write to ".out" file.
my $OutFile = $People2->write() or die;

## Re-read (from cache)
my $People3 = Data::CTable->new({_CacheOnRead=>1}, $OutFile) or die;

is_deeply(
   {%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},
);

$People1->progress("TEST_WRITE PASS 4");

## Read (not from cache)
my $People2 = Data::CTable->new({_CacheOnRead=>0}, "$Bin/data/people.tabs.txt") or die;

## Write to ".out" file.
my $OutFile = $People2->write() or die;

## Re-read (from cache)
my $People3 = Data::CTable->new({_CacheOnRead=>1}, $OutFile) or die;

is_deeply(
   {%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'},
   {%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},
);



