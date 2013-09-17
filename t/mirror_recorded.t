use strict;
use warnings;
use Test::More tests => 7;
use Cygwin::SetupDatabase::MirrorList;
use Path::Class qw( file dir );
use lib file(__FILE__)->parent->parent->subdir('inc')->absolute->stringify;
use Test::LWP::Recorder;

#note $INC{'Test/LWP/Recorder.pm'};

my $ua = Test::LWP::Recorder->new({
  record    => 0,
  cache_dir => file(__FILE__)->parent->subdir('cache'),
});

my $ml = Cygwin::SetupDatabase::MirrorList->new(ua => $ua);

isa_ok $ml, 'Cygwin::SetupDatabase::MirrorList';

my $mirror = $ml->random_mirror;

isa_ok $mirror, 'Cygwin::SetupDatabase::Mirror';

note $mirror->as_string;

isa_ok $mirror->uri, 'URI';

like $mirror->uri->scheme, qr{^(ftp|http)$}, "scheme = " . $mirror->uri->scheme;
is $mirror->uri->host, $mirror->host, 'mirror.uri.host = mirror.host = ' . $mirror->host;

isnt $mirror->region, '', "mirror.region = " . $mirror->region;
isnt $mirror->subregion, '', "mirror.subregion = " . $mirror->subregion;
