#!/usr/bin/perl

## Unit testing script for the Data::CTable module

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

use strict;

use Test;
BEGIN { plan tests => 37, todo => [] }

use Data::CTable;
use Data::CTable::Script;
use Data::CTable::Listing;
use Data::CTable::ProgressLogger;

## Suppress automatic built-in progress during testing in order to
## acheive nice unobscured testing output when all goes well. 

## (Will still test the progress() features directly with specific
## subclasses that gather the messages into memory instead of printing
## them out.)

Data::CTable->progress_class(0);

## Note whether we're on Unix...
my $OnUnix = ((-d "/") && (-d "/tmp"));

## Figure out some platform-specific path details...
my ($Sep, $Up, $Cur) = @{Data::CTable->path_info()}{qw(sep up cur)};

my $TestDir = "test$Sep"; ## "test/"


## First test is to read a file that we'll make use of in many of the
## other tests.

my $People1 = Data::CTable->new("${TestDir}people.tabs.txt") and ok(1) or die;


## Now for tests 2..onward, run unit-tests of specific feature
## groups...

ok(test_snapshot());	## snapshot feature.
ok(test_progress());	## Custom progress options.
ok(test_write());		## Testing writing / re-reading / cacheing
ok(test_calc());		## Calc method
ok(test_listeq());		## test the list equality testing utility (used by most other tests)
ok(test_subclasses());	## Testing file formats

1;



sub test_calc
{
	my $People2 = Data::CTable->new("${TestDir}people.tabs.txt") or die;
	
	package FooBar;

	no strict 'vars'; package main;
	$People2->calc(sub{$First = "\U$First\E/@{[$_t->length()]}/$_r/$_s"});
	
 	return(0) unless ("@{$People2->col('First')}" eq 
					  "CHRIS/3/0/0 MARCO/3/1/1 PEARL/3/2/2");
	
	return(1);
}


sub test_write
{
	$People1->progress("TEST_WRITE PASS 1");

	## Read (not from cache);
	my $People2 = Data::CTable->new({_CacheOnRead=>0}, "${TestDir}people.tabs.txt") or die;
	
	## Write to ".out" file.
	my $OutFile = $People2->write() or die;
	
	## Re-read (not from cache)
	my $People3 = Data::CTable->new({_CacheOnRead=>0}, $OutFile) or die;
	
	return(0) unless listeq({%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'}, 
							{%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},);

	$People1->progress("TEST_WRITE PASS 2");

	## Read (from cache)
	my $People2 = Data::CTable->new({_CacheOnRead=>1}, "${TestDir}people.tabs.txt") or die;
	
	## Write to ".out" file.
	my $OutFile = $People2->write() or die;
	
	## Re-read (not from cache)
	my $People3 = Data::CTable->new({_CacheOnRead=>0}, $OutFile) or die;
	
	return(0) unless listeq({%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'}, 
							{%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},);

	$People1->progress("TEST_WRITE PASS 3");

	## Read (from cache)
	my $People2 = Data::CTable->new({_CacheOnRead=>1}, "${TestDir}people.tabs.txt") or die;
	
	## Write to ".out" file.
	my $OutFile = $People2->write() or die;
	
	## Re-read (from cache)
	my $People3 = Data::CTable->new({_CacheOnRead=>1}, $OutFile) or die;
	
	return(0) unless listeq({%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'}, 
							{%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},);

	$People1->progress("TEST_WRITE PASS 4");

	## Read (not from cache)
	my $People2 = Data::CTable->new({_CacheOnRead=>0}, "${TestDir}people.tabs.txt") or die;
	
	## Write to ".out" file.
	my $OutFile = $People2->write() or die;
	
	## Re-read (from cache)
	my $People3 = Data::CTable->new({_CacheOnRead=>1}, $OutFile) or die;
	
	return(0) unless listeq({%$People2, _CacheOnRead=>'ignore', _FileName=>'ignore'}, 
							{%$People3, _CacheOnRead=>'ignore', _FileName=>'ignore'},);
}



BEGIN
{	## Data::CTable::ProgressLoggerInt: store prog. msgs in object
	
	package Data::CTable::ProgressLoggerInt;
	use vars qw(@ISA); @ISA=qw(Data::CTable);
	
	sub initialize       ## Add 1 new setting; change one default
	{
		my $this           = shift;
		$this->{_Progress} = 1 unless exists($_[0]->{_Progress});
		$this->{_ProgrLog} ||= [];
		$this->SUPER::initialize();
	}

	sub progress_default ## Log message to object's ProgMsgs list
	{
		my $this 			= shift;
		my ($msg) 			= @_;
		chomp                                     $msg;
		push @{$this->{_ProgrLog}}, localtime()." $msg";
	}
}

sub test_progress
{
	## Remember class progress setting to be restored later.
	my $OldClassSetting = Data::CTable->progress_class();

	my $People2 = $People1->snapshot();

	## Make a test progress method that pushes into a private array..
	my $Msgs = [];
	my $Prog = sub {push @$Msgs, $_[1]};

	## Set it as the per-instance setting.
	$People2->progress_set($Prog);
	$People2->read("${TestDir}people.tabs.txt");
	my $MsgCount = @$Msgs;
	return(0) unless $MsgCount >= 1;		## Assume read() makes at least 1 message

	## Turn off...
	$People2->progress_set(0);
	$People2->read("${TestDir}people.tabs.txt");
	return(0) unless @$Msgs == $MsgCount;
	
	## Set in class but leave off...
	$People2->progress_class($Prog);
	$People2->progress_set(0);
	$People2->read("${TestDir}people.tabs.txt");
	return(0) unless @$Msgs == $MsgCount;
	
	## Set in class and set to fall through...
	$People2->progress_class($Prog);
	$People2->progress_set(undef);
	$People2->read("${TestDir}people.tabs.txt");
	return(0) unless @$Msgs == $MsgCount * 2;

	## Turn off in class but fall through...
	$People2->progress_class(0);
	$People2->progress_set(undef);
	$People2->read("${TestDir}people.tabs.txt");
	return(0) unless @$Msgs == $MsgCount * 2;
	
	## Subclass that logs progress to our lexical var!  (Tricky!)
	{
		package TestProg; no strict 'refs';
		use vars qw(@ISA); @ISA=qw(Data::CTable);
		
		*TestProg::initialize		= sub	{$_[0]->{_Progress} = 1 unless exists($_[0]->{_Progress});
											 $_[0]->SUPER::initialize()};
		*TestProg::progress_default	= sub	{push @$Msgs, $_[1]};
	}
	
	my $People2 = TestProg->new("${TestDir}people.tabs.txt");
	return(0) unless @$Msgs == $MsgCount * 3;

	## A subclass that logs progress internally in the object.
	my $People2 = Data::CTable::ProgressLoggerInt->new("${TestDir}people.tabs.txt");
	return(0) unless @{$People2->{_ProgrLog}} == $MsgCount;

	## Restore class  progress setting in case not the same after testing.
	Data::CTable->progress_class($OldClassSetting);

	return(1);
}

sub test_snapshot
{
	## First test basic snapshotting with no selection -- complete
	## object duplication.

	return(0) unless my $t = $People1->snapshot();
	return(0) unless listeq({%$People1}, {%$t});
	
	## Then test snapshotting after there is a selection.

 	return(0) unless ("@{$t->col('First')}" eq 'Chris Marco Pearl');
	return(0) unless ("@{$t->col('Last')}"  eq 'Zack Bart Muth');
	return(0) unless ("@{$t->col('Age')}"   eq '43 22 15');
	return(0) unless ("@{$t->col('State')}" eq 'CA NV HI');
	
	$t->selection([2,0]);
	$t->fieldlist([qw(State Age)]);

	my $x = $t->snapshot();

 	return(0) unless ("@{$x->col('First')}" eq ' ');
	return(0) unless ("@{$x->col('Last')}"  eq ' ');
	return(0) unless ("@{$x->col('Age')}"   eq '15 43');
	return(0) unless ("@{$x->col('State')}" eq 'HI CA');

	return(1);
};

sub test_subclasses
{
	use Data::CTable::ProgressLogger;

	my $People2 = Data::CTable::ProgressLogger->new("${TestDir}people.tabs.txt");
	return(0) unless @{$People2->log()} >= 1;

	return(1);
}

sub test_listeq
{
	## Test the list-comparison routines...
	## Important because our other test routines rely on these tests.

	die unless  listeq([],				 []);
	die unless  listeq([2],				 ["2"]);
	die unless !listeq([2],				  "2");
	die unless  listeq( 2,				  "2");
	die unless  listeq([a => 1, b => 2], [a => 1, b => 2]);
	die unless !listeq([a => 1, b => 2], [b => 2, a => 1]);

	die unless  listeq({},				 {});
	die unless  listeq({a => 1, b => 2}, {b => 2, a => 1});
	die unless !listeq({a => 1, b => 2}, {b => 2, a => 2});
	die unless !listeq({a => 1, b => 2}, {b => 2, a => 2, c => 3});
	
	return(1);
}


