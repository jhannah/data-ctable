use strict;
use 5.10.0;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More tests => 22;
use Data::CTable;

ok(my $People1 = Data::CTable->new("$Bin/data/people.tabs.txt"),    'new() People1');
my $FileName = $People1->{_FileName};
my $File1 = $People1->write(_FDelimiter=>",", _LineEnding=>"\x0A",     _WriteExtension=>".comma.unix.out");
my $File2 = $People1->write(_FDelimiter=>",", _LineEnding=>"\x0D\x0A", _WriteExtension=>".comma.dos.out" );
my $File3 = $People1->write(_FDelimiter=>",", _LineEnding=>"\x0D",     _WriteExtension=>".comma.mac.out" );

## Read those back in (not from cache) and make sure they read "true".
  
my $Read1 = Data::CTable->new({_CacheOnRead=>0}, $File1) or die;
my $Read2 = Data::CTable->new({_CacheOnRead=>0}, $File2) or die;
my $Read3 = Data::CTable->new({_CacheOnRead=>0}, $File3) or die;

## All params and data should be the same except 'ignore'-ed items below.
is_deeply(
   {%$People1, _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   {%$Read1  , _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   "is_deeply()"
);
is_deeply(
   {%$People1, _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   {%$Read2  , _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   "is_deeply()"
);
is_deeply(
   {%$People1, _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   {%$Read3  , _CacheOnRead=>'ignore', _FileName=>'ignore', _LineEnding=>'ignore', _FDelimiter=>'ignore'},
   "is_deeply()"
);


## Check that the line endings and field delimiters are what we expect.
is (${$Read1->lineending_symbols()}{$Read1->{_LineEnding}}, "unix",     "lineending_symbols() unix");
is (${$Read2->lineending_symbols()}{$Read2->{_LineEnding}}, "dos",      "lineending_symbols() dos");
is (${$Read3->lineending_symbols()}{$Read3->{_LineEnding}}, "mac",      "lineending_symbols() mac");

is (${$Read1->lineending_strings()}{$Read1->{_LineEnding}}, "\x0A",     'lineending_strings() \x0A');
is (${$Read2->lineending_strings()}{$Read2->{_LineEnding}}, "\x0D\x0A", 'lineending_strings() \x0D\x0A');
is (${$Read3->lineending_strings()}{$Read3->{_LineEnding}}, "\x0D",     'lineending_strings() \x0D');

is ($Read1->lineending(), "unix",                                       'lineending() unix');
is ($Read2->lineending(), "dos",                                        'lineending() dos');
is ($Read3->lineending(), "mac",                                        'lineending() mac');

is ($Read1->lineending_symbol(), "unix",                                'lineending_symbol() unix');
is ($Read2->lineending_symbol(), "dos",                                 'lineending_symbol() dos');
is ($Read3->lineending_symbol(), "mac",                                 'lineending_symbol() mac');

is ($Read1->lineending_string(), "\x0A",                                'lineending_string() \x0A');
is ($Read2->lineending_string(), "\x0D\x0A",                            'lineending_string() \x0A');
is ($Read3->lineending_string(), "\x0D",                                'lineending_string() \x0A');

is ($Read1->{_FDelimiter}, ",",                                         '_FDelimiter is ,');
is ($Read2->{_FDelimiter}, ",",                                         '_FDelimiter is ,');
is ($Read3->{_FDelimiter}, ",",                                         '_FDelimiter is ,');



