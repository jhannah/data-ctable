use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 30;
use Data::CTable;

## Cache or read a limited subset.
my $t = Data::CTable->new({_FieldList=>[qw(State Age)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'State Age');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Delete the cache file.
unlink $t->prep_cache_file();

## Cache a limited subset.
my $t = Data::CTable->new({_FieldList=>[qw(State Age)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'State Age');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Get an IMPLIED full field list.
my $t = Data::CTable->new("$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'First Last Age State');
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Delete the cache file.
unlink $t->prep_cache_file();

## Will cache limited field list.
my $t = Data::CTable->new({_FieldList=>[qw(State Age)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'State Age');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Will cache different limited field list (abandon cache once).
my $t = Data::CTable->new({_FieldList=>[qw(First Last)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'First Last');
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');

## Will require full field list (abandon cache again).
my $t = Data::CTable->new({_FieldList=>[qw(First State Last Age)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'First State Last Age');
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Will be able to use cache although fields in different order.
my $t = Data::CTable->new({_FieldList=>[qw(First Last State Age)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'First Last State Age');
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('State')}", 'CA NV HI');
is("@{$t->col('Age')}",   '43 22 15');

## Will be able to use cache although subset of fields requested.
my $t = Data::CTable->new({_FieldList=>[qw(First Last)]}, "$Bin/data/people.tabs.2.txt") or die;
is("@{$t->fieldlist()}",  'First Last');
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');


