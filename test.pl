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
ok(test_selection());	## _Selection accessors
ok(test_row_misc());	## Miscellaneous row operations 
ok(test_row_move());	## Row moving
ok(test_row());			## Row retrieval, setting, deleting.
ok(test_indexes());		## Indexes & Index hashes
ok(test_clean());		## Cleanups
ok(test_col());			## Getting entire columns.
ok(test_fieldlist());	## _FieldList accessors
ok(test_select());		## select()-related features
ok(test_sort());		## Sort
ok(test_format());		## Format using Data::ShowTable
ok(test_progress());	## Custom progress options.
ok(test_write());		## Testing writing / re-reading / cacheing
ok(test_calc());		## Calc method
ok(test_timedprog());	## Timed progress; set env FAST=1 to shortcut
ok(test_listeq());		## test the list equality testing utility (used by most other tests)
ok(test_subclasses());	## Testing file formats

1;




sub test_selection
{
	my $t = $People1->snapshot();

	return(0) unless listeq($t->selection(), [0, 1, 2]);
	return(0) unless listeq($t->selection_get(), [0, 1, 2]);

 	$t->selection($t->all());
	return(0) unless listeq($t->selection(), [0, 1, 2]);

 	$t->selection([2,1,0]);
	return(0) unless listeq($t->selection(), [2, 1, 0]);

 	$t->selection_set([1,2,0]);
	return(0) unless listeq($t->selection(), [1, 2, 0]);
	
 	$t->selection_set();
	return(0) unless listeq($t->selection(), [0, 1, 2]);

 	$t->selection_set([5, 1,2,3, 0, -1]);
	return(0) unless listeq($t->selection(), [5, 1, 2, 3, 0, -1]);

 	$t->selection_validate();
	return(0) unless listeq($t->selection(), [1, 2, 0]);

	return(0) unless listeq($t->selection_inverse(), []);

 	$t->selection_set([0]);
	return(0) unless listeq($t->selection_inverse(), [1, 2]);
	
 	$t->selection_set([1, 0]);
	return(0) unless listeq($t->selection_inverse(), [2]);

 	$t->selection_set([0, 2]);
	return(0) unless listeq($t->selection_inverse(), [1]);

 	$t->selection_set([0, 2]);
 	$t->select_inverse();
	return(0) unless listeq($t->selection(), [1]);

 	$t->selection_set([0, 2]);
 	$t->select_all();
	return(0) unless listeq($t->selection(), [0, 1, 2]);
	
 	$t->selection_set([0, 2]);
 	$t->selection_set(undef);
	return(0) unless listeq($t->selection(), [0, 1, 2]);
	
 	$t->selection_set([0, 2]);
 	$t->selection_delete();
	return(0) unless listeq($t->selection(), [0, 1, 2]);
	
 	$t->selection_set([0, 2]);
	return(0) unless listeq($t->all(), [0, 1, 2]);

	return(1);
}

sub test_row_misc
{
	my $t = $People1->snapshot();
	return(0) unless listeq($t->row_empty(), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless listeq($t->row_empty(), $t->fieldlist_hash());

	return(0) unless !$t->row_exists(-1);
	return(0) unless  $t->row_exists(0);
	return(0) unless  $t->row_exists(1);
	return(0) unless  $t->row_exists(2);
	return(0) unless !$t->row_exists(3);

	$t->row_delete(0,2); ## Delete all rows.  None should exist.
	return(0) unless !$t->row_exists(-1);
	return(0) unless !$t->row_exists(0);
	return(0) unless !$t->row_exists(1);	

	## Use row_set to make an empty table with 11 rows.
	$t = Data::CTable->new();
	return(0) unless $t->length() == 0;
	$t->row_set(10, {First => undef, Last => undef, Age => undef});
	return(0) unless $t->length() == 11;
	return(0) unless !$t->row_exists(-1);
	return(0) unless  $t->row_exists(0);
	return(0) unless  $t->row_exists(10);
	return(0) unless !$t->row_exists(11);
	return(0) unless listeq($t->fieldlist(), [qw(Age First Last)]);

	## length_set() to truncate and extend
	$t = Data::CTable->new();
	return(0) unless $t->length() == 0;

	$t->length_set(22);	## Should be a no-op on empty table.
	return(0) unless $t->length() == 0;
	$t->row_set(10, {First => undef, Last => undef, Age => undef});

	$t->length_set(5);	## Truncate empty table to 5 entries.
	return(0) unless $t->length() == 5;
	return(0) unless  $t->row_exists(4);
	return(0) unless !$t->row_exists(5);

	## Test the extend() operator.
	$#{$t->col('First')} = 10;
	$t->extend();
	return(0) unless $t->length() == 11;
	
	## rows() operator
	my $t = $People1->snapshot();
	return(0) unless listeq($t->rows([0,1,2]), [
												{qw(First Chris Last Zack Age 43 State CA)},
												{qw(First Marco Last Bart Age 22 State NV)},
												{qw(First Pearl Last Muth Age 15 State HI)},
												]);
	
	return(0) unless listeq($t->rows([0,2,1]), [
												{qw(First Chris Last Zack Age 43 State CA)},
												{qw(First Pearl Last Muth Age 15 State HI)},
												{qw(First Marco Last Bart Age 22 State NV)},
												]);
	
	return(0) unless listeq($t->rows([0]), [
												{qw(First Chris Last Zack Age 43 State CA)},
												]);
	
	return(0) unless listeq($t->rows([2]), [
												{qw(First Pearl Last Muth Age 15 State HI)},
												]);

	## row_list()
	return(0) unless listeq($t->row_list(0), [qw(Chris Zack 43 CA)]);
	return(0) unless listeq($t->row_list(1), [qw(Marco Bart 22 NV)]);
	return(0) unless listeq($t->row_list(2), [qw(Pearl Muth 15 HI)]);
	
	return(0) unless listeq($t->row_list(0, [qw(State Age)]), [qw(CA 43)]);
	return(0) unless listeq($t->row_list(1, [qw(State Age)]), [qw(NV 22)]);
	return(0) unless listeq($t->row_list(2, [qw(State Age)]), [qw(HI 15)]);

	## row_list_set()
	
	my $t = $People1->snapshot();
	$t->row_list_set(0, undef, [qw(CHRIS Zack 43.0 CA)]);
	$t->row_list_set(1, undef, [qw(Marco BART 22.0 Nevada)]);
	$t->row_list_set(2, undef, [qw(PEARL Muth 15.0 HI)]);

	return(0) unless listeq($t->col('First'), [qw(CHRIS Marco PEARL)]);
	return(0) unless listeq($t->col('Last' ), [qw(Zack BART Muth)]);
	return(0) unless listeq($t->col('Age'  ), [qw(43.0 22.0 15.0)]);
	return(0) unless listeq($t->col('State'), [qw(CA Nevada HI)]);

	my $t = $People1->snapshot();
	$t->row_list_set(0, [qw(Last First)], [qw(Zack CHRIS 43.0 CA)]);
	$t->row_list_set(1, [qw(Last First)], [qw(BART Marco 22.0 Nevada)]);
	$t->row_list_set(2, [qw(Last First)], [qw(Muth PEARL 15.0 HI)]);

	return(0) unless listeq($t->col('First'), [qw(CHRIS Marco PEARL)]);
	return(0) unless listeq($t->col('Last' ), [qw(Zack BART Muth)]);
	return(0) unless listeq($t->col('Age'  ), [qw(43 22 15)]);
	return(0) unless listeq($t->col('State'), [qw(CA NV HI)]);

	return(1);
}

sub test_row_move
{
	## Create the starting point table.  We'll copy it before each
	## move exercise, and then set a full selection so we can test
	## that the selection is properly tracking the row moves.

	my $Before = $People1->snapshot();
	
	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(0,0);	## no-op
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->selection(), [0, 1, 2]);

	$t->row_move(0,1);	## no-op
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->selection(), [0, 1, 2]);

	$t->row_move(1,2);	## no-op
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->selection(), [0, 1, 2]);

	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(0,2);	## move first to before last
	return(0) unless listeq($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->selection(), [1, 0, 2]);

	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(0,3);	## move first to end
	return(0) unless listeq($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(2), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->selection(), [2, 0, 1]);

	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(1,0);	## move second to beginning (before first)
	return(0) unless listeq($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->selection(), [1, 0, 2]);

	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(2,0);	## move last to beginning (before first)
	return(0) unless listeq($t->row(0), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(1), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(2), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->selection(), [1, 2, 0]);

	my $t = $Before->snapshot(); 	$t->selection($t->all());
	$t->row_move(2,1);	## move last to middle (before second)
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(2), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->selection(), [0, 2, 1]);

	return(1);
}

sub test_row
{
	return(0) unless my $t = $People1->snapshot();

	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	
	$t->omit(Last => sub {/bart/i});

	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	
	$t->fieldlist([qw(First Last Age)]);

	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15)});
	
	$t->row_set(0, {qw(First CHRIS Last ZACK Age 143 State XX)});

	return(0) unless listeq($t->row(0), {qw(First CHRIS Last ZACK Age 143)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15)});

	$t->fieldlist(0);
	
	return(0) unless listeq($t->row(0), {qw(First CHRIS Last ZACK Age 143 State XX)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});

	$t = $People1->snapshot();
	$t->row_delete(0);
	return(0) unless listeq($t->row(0), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(2), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 2;

	$t = $People1->snapshot();
	$t->row_delete(1,1);
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(2), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 2;

	$t = $People1->snapshot();
	$t->row_delete(2,2);
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 2;

	$t = $People1->snapshot();
	$t->row_delete(1,0);
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless $t->length() == 3;

	$t = $People1->snapshot();
	$t->row_delete();
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {qw(First Marco Last Bart Age 22 State NV)});
	return(0) unless listeq($t->row(2), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless $t->length() == 3;

	$t = $People1->snapshot();
	$t->row_delete(0,1);
	return(0) unless listeq($t->row(0), {qw(First Pearl Last Muth Age 15 State HI)});
	return(0) unless listeq($t->row(1), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 1;

	$t = $People1->snapshot();
	$t->row_delete(1,2);
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 1;

	$t = $People1->snapshot();
	$t->row_delete(1,3);
	return(0) unless listeq($t->row(0), {qw(First Chris Last Zack Age 43 State CA)});
	return(0) unless listeq($t->row(1), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 1;

	$t = $People1->snapshot();
	$t->row_delete(0,2);
	return(0) unless listeq($t->row(0), {First => '', Last=> '', Age => '', State => ''});
	return(0) unless $t->length() == 0;

	return(1);
}

sub test_indexes
{
	return(0) unless my $t = $People1->snapshot();
	$t->sort([qw(Last)]);

	return(0) unless listeq($t->index_all('Last'), {qw(Zack 0 Bart 1 Muth 2)});
	return(0) unless listeq($t->index_sel('Last'), {qw(Zack 0 Bart 1 Muth 2)});

	return(0) unless listeq($t->hash_all('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});
	return(0) unless listeq($t->hash_sel('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});

	$t->omit(Last => sub {/bart/i});

	return(0) unless listeq($t->index_all('Last'), {qw(Zack 0 Bart 1 Muth 2)});
	return(0) unless listeq($t->index_sel('Last'), {qw(Zack 0        Muth 2)});

	return(0) unless listeq($t->hash_all('Last', 'First'), {qw(Zack Chris Bart Marco Muth Pearl)});
	return(0) unless listeq($t->hash_sel('Last', 'First'), {qw(Zack Chris            Muth Pearl)});

	return(1);
}

sub test_clean
{
	my $t = Data::CTable->new("${TestDir}people.unclean.tabs.txt") or die;
	$t->clean_ws();

	return(0) unless ("@{$t->col('First')}" eq 'Chris Marco Pearl');
	return(0) unless ("@{$t->col('Last')}"  eq 'Zack Bart Muth');
	return(0) unless ("@{$t->col('Age')}"   eq '43 22 15');
	return(0) unless ("@{$t->col('State')}" eq 'CA NV HI');

	return(0) unless ($t->col('Statement')->[0] eq "This\n is a multi-line field.");
	return(0) unless ($t->col('Statement')->[1] eq "I was born\nin Cleveland.");
	return(0) unless ($t->col('Statement')->[2] eq "Aloha!");
	
	my $CleanMultiLine = sub {s/^\s+//gm; s/\s+$//gm};

	$t->clean($CleanMultiLine);
	
	return(0) unless ("@{$t->col('First')}" eq 'Chris Marco Pearl');
	return(0) unless ("@{$t->col('Last')}"  eq 'Zack Bart Muth');
	return(0) unless ("@{$t->col('Age')}"   eq '43 22 15');
	return(0) unless ("@{$t->col('State')}" eq 'CA NV HI');

	return(0) unless ($t->col('Statement')->[0] eq "This\nis a multi-line field.");
	return(0) unless ($t->col('Statement')->[1] eq "I was born\nin Cleveland.");
	return(0) unless ($t->col('Statement')->[2] eq "Aloha!");

	## Read table with Mac UA mapping OFF.
	my $t1 = Data::CTable->new({_CacheOnRead=>0, _MacRomanMap=>0    }, 
							   "${TestDir}people.mac.ua.tabs.txt") or die;
	
	## Read another table with Mac UA mapping set to AUTO (in this case: ON).
	my $t2 = Data::CTable->new({_CacheOnRead=>0, _MacRomanMap=>undef}, 
							   "${TestDir}people.mac.ua.tabs.txt") or die;
	$t1->clean_ws();
	$t2->clean_ws();

	## Check that the unmapped ones are unmapped.
	return(0) unless ($t1->col('Statement')->[0] eq "‚a fait dix ans.");
	return(0) unless ($t1->col('Statement')->[1] eq "CrŽŽe par Se–or †berpfeffer.");
	return(0) unless ($t1->col('Statement')->[2] eq "Crme glaŽe en crožte.");

	## Check that the mapped ones are mapped.
	return(0) unless ($t2->col('Statement')->[0] eq "Ça fait dix ans.");
	return(0) unless ($t2->col('Statement')->[1] eq "Créée par Señor Überpfeffer.");
	return(0) unless ($t2->col('Statement')->[2] eq "Crème glaçée en croûte.");

	## Manually map a single value to check the UA mapping utility routines
	my $Val = $t1->col('Statement')->[2];
	use Data::CTable qw(MacRomanToISORoman8859_1);
	&MacRomanToISORoman8859_1(\$Val);
	return(0) unless ($Val eq 'Crème glaçée en croûte.');

	## Manually map the unmapped table and re-check.
	$t1->clean_mac_to_iso8859();
	return(0) unless ($t1->col('Statement')->[0] eq "Ça fait dix ans.");
	return(0) unless ($t1->col('Statement')->[1] eq "Créée par Señor Überpfeffer.");
	return(0) unless ($t1->col('Statement')->[2] eq "Crème glaçée en croûte.");

	## Test a conversion utility that reads a mac file and writes it as windows.

	my $WinVersion = &mac_data_file_to_win("${TestDir}people.mac.ua.tabs.txt");
	my $t3 = Data::CTable->new($WinVersion) or die;
	$t3->clean_ws();
	return(0) unless listeq($t2->cols(), $t3->cols());

	return(1);
}

sub mac_data_file_to_win
{
	my ($FileName) = @_;
	use Data::CTable;
	my $t = Data::CTable->new($FileName);

	## If file name contains "mac", change it to "win"

	## Change line endings to DOS.  This also disables default
	## _MacRomanMap behavior.

	$t->{_FileName} =~ s/mac/win/i;	

	my $Written = $t->write(_LineEnding=>"\x0D\x0A");
	
	return($Written);
}

sub test_col
{
	return(0) unless ("@{$People1->col('First')}" eq 'Chris Marco Pearl');
	return(0) unless ("@{$People1->col('Last')}"  eq 'Zack Bart Muth');
	return(0) unless ("@{$People1->col('Age')}"   eq '43 22 15');
	return(0) unless ("@{$People1->col('State')}" eq 'CA NV HI');

	return(0) unless my $t = $People1->snapshot();
	return(0) unless ("@{$t->col_get('First')}" eq 'Chris Marco Pearl');

	$t->col_set(First=>[qw(Basil Horty Ringo)]);
	return(0) unless ("@{$t->col_get('First')}" eq 'Basil Horty Ringo');

	$t->col(First=>[qw(Horty Basil Ringo)]);
	return(0) unless ("@{$t->col_get('First')}" eq 'Horty Basil Ringo');

	$t->col_delete('First');
	return(0) unless !$t->col_exists('First');
	return(0) unless (listeq($t->fieldlist(), [qw(Last Age State)]));
	return(0) unless (listeq($t->col('First'), [undef, undef, undef]));
	return(0) unless  $t->col_exists('First');

	return(0) unless (listeq($t->col_default(), [undef, undef, undef]));
	return(0) unless (listeq($t->col_empty(),   [undef, undef, undef]));
	return(0) unless (listeq($t->col_empty(0),  []));
	return(0) unless (listeq($t->col_empty($t->col('Last')), [undef, undef, undef]));

	return(0) unless my $t = $People1->snapshot();
	
	return(0) unless  $t->col_exists('First');
	return(0) unless  $t->col_exists('Last');
	return(0) unless  $t->col_exists('Age');
	return(0) unless  $t->col_exists('State');
	return(0) unless !$t->col_exists('Firstx');

	$t->fieldlist([qw(Last First)]);

	return(0) unless  $t->col_exists('First');
	return(0) unless  $t->col_exists('Last');
	return(0) unless  $t->col_exists('Age');
	return(0) unless  $t->col_exists('State');

	return(0) unless  $t->col_active('First');
	return(0) unless  $t->col_active('Last');
	return(0) unless !$t->col_active('Age');
	return(0) unless !$t->col_active('State');

	$t->fieldlist(0);

	return(0) unless  $t->col_exists('First');
	return(0) unless  $t->col_exists('Last');
	return(0) unless  $t->col_exists('Age');
	return(0) unless  $t->col_exists('State');

	return(0) unless  $t->col_active('First');
	return(0) unless  $t->col_active('Last');
	return(0) unless  $t->col_active('Age');
	return(0) unless  $t->col_active('State');

	return(0) unless listeq($t->cols([qw(State Age)]),
							[[qw(CA NV HI)], [qw(43 22 15)]]);
	return(0) unless listeq($t->cols([qw(Last First)]),
							[[qw(Zack Bart Muth)], [qw(Chris Marco Pearl)]]);
	return(0) unless listeq($t->cols([]),
							[]);

	return(0) unless my $t = $People1->snapshot();
	return(0) unless listeq($t->cols(), 
							[
							 [qw(Chris Marco Pearl)],
							 [qw(Zack Bart Muth)], 
							 [qw(43 22 15)],
							 [qw(CA NV HI)],
							 ]);
	return(0) unless listeq($t->cols_hash([qw(State Age)]),
							{State=>[qw(CA NV HI)], Age=>[qw(43 22 15)]});
	return(0) unless listeq($t->cols_hash([qw(Last First)]),
							{Last=>[qw(Zack Bart Muth)], First=>[qw(Chris Marco Pearl)]});
	return(0) unless listeq($t->cols_hash([]),
							{});
	return(0) unless listeq($t->cols_hash([qw(Last First)]),
							{Last=>[qw(Zack Bart Muth)], 
							 First=>[qw(Chris Marco Pearl)]});

	$t->fieldlist([qw(Last Age First)]);
	return(0) unless listeq($t->cols(), 
							[
							 [qw(Zack Bart Muth)], 
							 [qw(43 22 15)],
							 [qw(Chris Marco Pearl)],
							 ]);

	return(0) unless my $t = $People1->snapshot();

	## Column renaming
	$t->col_rename(First=>'FirstName');
	$t->col_rename(Last=>'LastName');
	$t->fieldlist([qw(LastName FirstName)]);

	return(0) unless listeq($t->cols(), 
							[
							 [qw(Zack Bart Muth)], 
							 [qw(Chris Marco Pearl)],
							 ]);
	$t->fieldlist(0);
	return(0) unless listeq($t->cols_hash(),
							{LastName=>[qw(Zack Bart Muth)], 
							 FirstName=>[qw(Chris Marco Pearl)],
							 Age=>[qw(43 22 15)],
							 State=>[qw(CA NV HI)]});
	
	return(0) unless listeq($t->fieldlist_all(), [qw(Age FirstName LastName State)]);

	return(1);
}

sub test_fieldlist
{
	my $t = Data::CTable->new("${TestDir}people.tabs.txt") or die;

	return(0) unless listeq($t->fieldlist(),         [qw(First Last Age State)]);
	return(0) unless listeq($t->fieldlist_default(), [qw(Age First Last State)]);

	$t->fieldlist([qw(First)]);
	return(0) unless listeq($t->fieldlist(), [qw(First)]);

	$t->fieldlist_set(undef);
	return(0) unless listeq($t->fieldlist(),         [qw(Age First Last State)]);

	$t->fieldlist_force([qw(First)]);
	return(0) unless listeq($t->fieldlist(), [qw(First)]);

	$t->fieldlist_set(undef);
	return(0) unless listeq($t->fieldlist(), [qw(First)]);

	$t->fieldlist_force([qw(Last First)]);
	$t->fieldlist_set(undef);
	return(0) unless listeq($t->fieldlist_all(), [qw(First Last)]);

	$t->fieldlist_add('Foo');
	$t->fieldlist_add('Bar');
	return(0) unless listeq($t->fieldlist_all(), [qw(First Last)]);

	$t->fieldlist_force([qw(Last First)]);
	$t->fieldlist_add('Foo');
	$t->fieldlist_add('Bar');
	return(0) unless listeq($t->fieldlist(), [qw(Last First Foo Bar)]);
	return(0) unless listeq($t->fieldlist_all(), [qw(First Last)]);

	$t->fieldlist_delete('Foo');
	$t->fieldlist_delete('Bar');
	return(0) unless listeq($t->fieldlist(), [qw(Last First)]);
	return(0) unless listeq($t->fieldlist_all(), [qw(First Last)]);

	return(1);
}

sub test_select
{
	my $t  = Data::CTable->new("${TestDir}stats.tabs.unix.txt");

	$t->select_all();
	return(0) unless $t->sel_len() == 3 and "@{$t->sel('DeptNum')}" eq '1115 2203 2209';

	$t->select_none();
	return(0) unless $t->sel_len() == 0 and "@{$t->sel('DeptNum')}" eq '';

	$t->select_all();
	$t->select(PersonID => sub {/chris/i});
	return(0) unless $t->sel_len() == 1 and "@{$t->sel('DeptNum')}" eq '2203';

	$t->select_none();
	$t->add(PersonID => sub {/chris/i});
	return(0) unless $t->sel_len() == 1 and "@{$t->sel('DeptNum')}" eq '2203';

	$t->select_none();
	$t->add(PersonID => sub {/chris/i});
	$t->add(PersonID => sub {/bart/i});
	return(0) unless $t->sel_len() == 2 and "@{$t->sel('DeptNum')}" eq '2203 2209';

	$t->sort([qw(PersonID)]);
	return(0) unless $t->sel_len() == 2 and "@{$t->sel('DeptNum')}" eq '2209 2203';

	$t->select_none();
	$t->but(PersonID => sub {/chris/i});
	return(0) unless $t->sel_len() == 2 and "@{$t->sel('DeptNum')}" eq '1115 2209';

	$t->select_all();
	$t->omit(PersonID => sub {/chris/i});
	return(0) unless $t->sel_len() == 2 and "@{$t->sel('DeptNum')}" eq '1115 2209';

	$t->select_all();
	$t->select(DeptNum    => sub {$_ > 2000});
	$t->omit  (Department => sub {/resale/i});
	return(0) unless $t->sel_len() == 1 and "@{$t->sel('DeptNum')}" eq '2203';

	return(1);
}

sub test_sort
{
	my $People2 = Data::CTable->new("${TestDir}people.tabs.txt") or die;

	## Sorting by single text fields with all defaults...
	$People2->sort([qw(Last)]);

	return(0) unless ("@{$People2->sel('Last')}" eq 'Bart Muth Zack');
	return(0) unless ("@{$People2->sel('First')}" eq 'Marco Pearl Chris');

	$People2->sort([qw(First)]);
	return(0) unless ("@{$People2->sel('First')}" eq 'Chris Marco Pearl');

	## Sorting with a non-default sort spec.
	$People2->sortspec(Age=>{SortType=>'Integer', SortDirection=>-1});
	$People2->sort([qw(Age)]);
	return(0) unless ("@{$People2->sel('Age')}"   eq '43 22 15');
	return(0) unless ("@{$People2->sel('First')}" eq 'Chris Marco Pearl');

	## Override a sortspec in the object...
	$People2->sort(_SortOrder=>[qw(Age)],_SortSpecs=>{Age=>{SortDirection=>1}});
	return(0) unless ("@{$People2->sel('Age')}"   eq '15 22 43');
	return(0) unless ("@{$People2->sel('First')}" eq 'Pearl Marco Chris');

	## Do some sub-sorting...
	my $People3 = Data::CTable->new("${TestDir}people.multivals.txt") or die;

	$People3->sort([qw(State Age)]);
	return(0) unless ("@{$People3->sel('State')}"  eq 'CA HI KY NV OH OH');
	return(0) unless ("@{$People3->sel('Age')}"  eq '43 15 43 22 41 55');
	return(0) unless ("@{$People3->sel('Last')}"  eq 'Edge Muth Bart Bart Mark Zack');

	$People3->sortorder([qw(Age State)]);
	return(0) unless listeq($People3->sortorder(), [qw(Age State)]);

	$People3->sort();
	return(0) unless ("@{$People3->sel('Age')}"  eq '15 22 41 43 43 55');
	return(0) unless ("@{$People3->sel('State')}"  eq 'HI NV OH CA KY OH');
	return(0) unless ("@{$People3->sel('Last')}"  eq 'Muth Bart Mark Edge Bart Zack');

	$People3->sort([qw(Last First)]);
	return(0) unless ("@{$People3->sel('Last')}"  eq 'Bart Bart Edge Mark Muth Zack');
	return(0) unless ("@{$People3->sel('First')}"  eq 'James Marco Chris Sandy Pearl Chris');
	return(0) unless ("@{$People3->sel('Age')}"  eq '43 22 43 41 15 55');

	$People3->sort([qw(First Last)]);
	return(0) unless ("@{$People3->sel('First')}"  eq 'Chris Chris James Marco Pearl Sandy');
	return(0) unless ("@{$People3->sel('Last')}"  eq 'Edge Zack Bart Bart Muth Mark');

	return(0) unless listeq($People3->sortorder_default(), []);

	$People3->sortorder([qw(BOKSDJ Age State Foobxr)]);
	$People3->sortorder_check();
	return(0) unless listeq($People3->sortorder(), [qw(Age State)]);

	$People3->sortorder([]);
	return(0) unless listeq($People3->sortorder(), []);

	$People3->sortorder(undef);
	return(0) unless listeq($People3->sortorder(), []);
	
	$People2->sortspec(Age=>{SortType=>'Integer', SortDirection=>-1});
	return(0) unless listeq($People2->sortspec('Age'), {SortType=>'Integer', SortDirection=>-1});
	return(0) unless listeq($People2->sortspecs(), {Age=>{SortType=>'Integer', SortDirection=>-1}});
	$People2->sortspec(Beauty=>{SortType=>'String', SortDirection=>1});
	return(0) unless listeq($People2->sortspecs(), {Age=>{SortType=>'Integer', SortDirection=>-1},
													Beauty=>{SortType=>'String', SortDirection=>1},
												});
	
	$People2->sortspecs({Frost=>{SortType=>'Integer', SortDirection=>-1},
						 Snow=>{SortType=>'String', SortDirection=>1},
					 });
	
	return(0) unless listeq($People2->sortspecs(), {Frost=>{SortType=>'Integer', SortDirection=>-1},
													Snow=>{SortType=>'String', SortDirection=>1},
												});
	
	return(0) unless listeq($People2->sortspecs_default(), {});
	return(0) unless listeq($People2->sortspec_default('First'), {SortType=>$People2->sorttype_default(),
																  SortDirection=>$People2->sortdirection_default(),
															  });

	$People2->sorttype_default('Number');
	$People2->sortdirection_default(-1);

	return(0) unless $People2->sorttype_default() eq 'Number';
	return(0) unless $People2->sortdirection_default() == -1;

	return(0) unless listeq($People2->sortspec_default('First'), {SortType=>$People2->sorttype_default(),
																  SortDirection=>$People2->sortdirection_default(),
															  });
	
	return(1);
}

sub test_format
{
	my $Goal = <<"END";
 +-------+------+-----+-------+
 | First | Last | Age | State |
 +-------+------+-----+-------+
 | Chris | Zack | 43  | CA    |
 | Marco | Bart | 22  | NV    |
 | Pearl | Muth | 15  | HI    |
 +-------+------+-----+-------+
END

	## First test basic formatting.

	my $Formatted = $People1->format();

	if (!length($$Formatted)) 
	{
		warn("Skipping test of format() and out() methods because Data::ShowTable is not installed on this platform.");
		return(1);
	}

	return(0) unless ($$Formatted eq $Goal);

	## Now test the out() method for sending formatted output to
	## STDOUT (default), to a named file, or to any object with a
	## print() method (such as an IO::File);

	## Output to a file object...
	{
		return(0) unless my $tmp = IO::File->new_tmpfile();
		return(0) unless $People1->out($tmp);

		local $/ = undef;
		$tmp->seek(0, 0);
		my $Output = $tmp->getline();
		return(0) unless $Output eq $Goal;
	}

	## Output to a file (path)
	{
		my $OutPath	= "${TestDir}outtest.formatted.txt";
		return(0) unless $People1->out($OutPath);
		my $Output	= do {local $/ = undef; use IO::File; (IO::File->new("<$OutPath") or die)->getline()};
		return(0) unless $Output eq $Goal;
		unlink $OutPath;
	}

	## We'll leave output to stdout untested.

	return(1);
}

sub test_timedprog
{
	return(1) if exists($ENV{FAST});	## A way to skip this test during development.

	my $Msgs	  = [];

	## A helpful little subclass that grabs the output of progress_timer into a local list.
	BEGIN {package Data::CTable::SnagTimers; use vars qw(@ISA); 
	       @ISA=qw(Data::CTable); 
		   sub progress_timed_default{my $this=shift; my ($Msg) = @_; push @$Msgs, $Msg; 
									  $this->SUPER::progress_timed_default($Msg)}}

	my $People2 = Data::CTable::SnagTimers->new("${TestDir}people.tabs.txt") or die;

	## Run a test in non- $Wait mode (first message appears immediately)
	my $Start	  = time();
	my $Goal	  = 4; ## Seconds.
	my $Passed	  = 0;

	while ($Passed < $Goal)
	{
		$Passed = Data::CTable::min($Goal, (time() - $Start));
		$People2->progress_timed("Testing timed progress", $Passed, $Passed, $Goal, 0);
	}
	
	return(0) unless @$Msgs >= 2; ## Really expect at least 3 here...
	return(0) unless $Msgs->[0] =~ / 0 \( 0%\)/;		## First message must appear...
	return(0) unless $Msgs->[-1] =~ /$Goal \(100%\)/;	## Last message must appear...

	## Run the test again to test the $Wait mode...

	$Msgs		  = [];
	my $Start	  = time();
	my $Goal	  = 4; ## Seconds.
	my $Passed	  = 0;

	while ($Passed < $Goal)
	{
		$Passed = Data::CTable::min($Goal, (time() - $Start));
		$People2->progress_timed("Testing delayed timed progress", $Passed, $Passed, $Goal, 1);
	}

	return(0) unless @$Msgs >= 1; ## Really expect at least 2 here...
	return(0)     if $Msgs->[0] =~ / 0 \( 0%\)/;		## First message must NOT appear...
	return(0) unless $Msgs->[-1] =~ /$Goal \(100%\)/;	## Last message must appear...

	return(1);
}

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


