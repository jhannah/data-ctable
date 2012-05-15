use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 25;
use Data::CTable;

my $t = Data::CTable->new("$Bin/data/people.unclean.tabs.txt");
$t->clean_ws();

is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');

is($t->col('Statement')->[0], "This\n is a multi-line field.");
is($t->col('Statement')->[1], "I was born\nin Cleveland.");
is($t->col('Statement')->[2], "Aloha!");
  
my $CleanMultiLine = sub {s/^\s+//gm; s/\s+$//gm};

$t->clean($CleanMultiLine);
  
is("@{$t->col('First')}", 'Chris Marco Pearl');
is("@{$t->col('Last')}",  'Zack Bart Muth');
is("@{$t->col('Age')}",   '43 22 15');
is("@{$t->col('State')}", 'CA NV HI');

is($t->col('Statement')->[0], "This\nis a multi-line field.");
is($t->col('Statement')->[1], "I was born\nin Cleveland.");
is($t->col('Statement')->[2], "Aloha!");

## Read table with Mac UA mapping OFF.
my $t1 = Data::CTable->new({_CacheOnRead=>0, _MacRomanMap=>0    },
                     "$Bin/data/people.mac.ua.tabs.txt") or die;
  
## Read another table with Mac UA mapping set to AUTO (in this case: ON).
my $t2 = Data::CTable->new({_CacheOnRead=>0, _MacRomanMap=>undef},
                     "$Bin/data/people.mac.ua.tabs.txt") or die;
$t1->clean_ws();
$t2->clean_ws();

## Check that the unmapped ones are unmapped.
is($t1->col('Statement')->[0], "a fait dix ans.");
is($t1->col('Statement')->[1], "Cre par Seor berpfeffer.");
is($t1->col('Statement')->[2], "Crme glae en crote.");

## Check that the mapped ones are mapped.
is($t2->col('Statement')->[0], "Ça fait dix ans.");
is($t2->col('Statement')->[1], "Créée par Señor Überpfeffer.");
is($t2->col('Statement')->[2], "Crème glaçée en croûte.");

## Manually map a single value to check the UA mapping utility routines
my $Val = $t1->col('Statement')->[2];
use Data::CTable qw(MacRomanToISORoman8859_1);
&MacRomanToISORoman8859_1(\$Val);
is($Val, 'Crème glaçée en croûte.');

## Manually map the unmapped table and re-check.
$t1->clean_mac_to_iso8859();
is($t1->col('Statement')->[0], "Ça fait dix ans.");
is($t1->col('Statement')->[1], "Créée par Señor Überpfeffer.");
is($t1->col('Statement')->[2], "Crème glaçée en croûte.");

## Test a conversion utility that reads a mac file and writes it as windows.

my $WinVersion = &mac_data_file_to_win("$Bin/data/people.mac.ua.tabs.txt");
my $t3 = Data::CTable->new($WinVersion) or die;
$t3->clean_ws();
is_deeply($t2->cols(), $t3->cols());


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




