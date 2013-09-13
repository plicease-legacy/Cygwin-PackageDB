use strict;
use warnings;
use Test::More;
use Cygwin::SetupDatabase::MirrorList;

plan skip_all => 'set CYGWIN_SETUPDATABASE_LIVE to run this test' unless $ENV{CYGWIN_SETUPDATABASE_LIVE};
plan tests => 7;

my $ml = Cygwin::SetupDatabase::MirrorList->new;

isa_ok $ml, 'Cygwin::SetupDatabase::MirrorList';

my $mirror = $ml->random_mirror;

isa_ok $mirror, 'Cygwin::SetupDatabase::Mirror';

note $mirror->as_string;

isa_ok $mirror->uri, 'URI';

like $mirror->uri->scheme, qr{^(ftp|http)$}, "scheme = " . $mirror->uri->scheme;
is $mirror->uri->host, $mirror->host, 'mirror.uri.host = mirror.host = ' . $mirror->host;

isnt $mirror->region, '', "mirror.region = " . $mirror->region;
isnt $mirror->subregion, '', "mirror.subregion = " . $mirror->subregion;
