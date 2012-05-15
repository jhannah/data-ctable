use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 7;
use Data::CTable;


BEGIN
{  ## Data::CTable::ProgressLoggerInt: store prog. msgs in object

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
      my $this          = shift;
      my ($msg)         = @_;
      chomp                                     $msg;
      push @{$this->{_ProgrLog}}, localtime()." $msg";
   }
}


## Remember class progress setting to be restored later.
my $OldClassSetting = Data::CTable->progress_class();

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt") or die;
my $People2 = $People1->snapshot();

## Make a test progress method that pushes into a private array..
my $Msgs = [];
my $Prog = sub {push @$Msgs, $_[1]};

## Set it as the per-instance setting.
$People2->progress_set($Prog);
$People2->read("$Bin/data/people.tabs.txt");
my $MsgCount = @$Msgs;
cmp_ok($MsgCount, '>=', 1, 'Assume read() makes at least 1 message');

## Turn off...
$People2->progress_set(0);
$People2->read("$Bin/data/people.tabs.txt");
cmp_ok(@$Msgs, '==', $MsgCount);

## Set in class but leave off...
$People2->progress_class($Prog);
$People2->progress_set(0);
$People2->read("$Bin/data/people.tabs.txt");
cmp_ok(@$Msgs, '==', $MsgCount);

## Set in class and set to fall through...
$People2->progress_class($Prog);
$People2->progress_set(undef);
$People2->read("$Bin/data/people.tabs.txt");
cmp_ok(@$Msgs, '==', $MsgCount * 2);

## Turn off in class but fall through...
$People2->progress_class(0);
$People2->progress_set(undef);
$People2->read("$Bin/data/people.tabs.txt");
cmp_ok(@$Msgs, '==', $MsgCount * 2);

## Subclass that logs progress to our lexical var!  (Tricky!)
{
   package TestProg; no strict 'refs';
   use vars qw(@ISA); @ISA=qw(Data::CTable);

   *TestProg::initialize      = sub {$_[0]->{_Progress} = 1 unless exists($_[0]->{_Progress});
                               $_[0]->SUPER::initialize()};
   *TestProg::progress_default   = sub {push @$Msgs, $_[1]};
}

my $People2 = TestProg->new("$Bin/data/people.tabs.txt");
cmp_ok(@$Msgs, '==', $MsgCount * 3);

## A subclass that logs progress internally in the object.
my $People2 = Data::CTable::ProgressLoggerInt->new("$Bin/data/people.tabs.txt");
cmp_ok(@{$People2->{_ProgrLog}}, '==', $MsgCount);

## Restore class  progress setting in case not the same after testing.
Data::CTable->progress_class($OldClassSetting);


