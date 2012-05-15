use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Data::CTable;

my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt");

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
   plan skip_all => 'Skipping test of format() and out() methods because Data::ShowTable is not installed on this platform.';
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
   my $OutPath = "$Bin/data/outtest.formatted.txt";
   return(0) unless $People1->out($OutPath);
   my $Output  = do {local $/ = undef; use IO::File; (IO::File->new("<$OutPath") or die)->getline()};
   return(0) unless $Output eq $Goal;
   unlink $OutPath;
}

## We'll leave output to stdout untested.


done_testing;


