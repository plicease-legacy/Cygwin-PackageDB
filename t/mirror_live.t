use strict;
use warnings;
use Test::More;
use Cygwin::PackageDB::MirrorList;

plan skip_all => 'set CYGWIN_PACKAGEDB_LIVE to run this test' unless $ENV{CYGWIN_PACKAGEDB_LIVE};
plan tests => 7;

my $ml = Cygwin::PackageDB::MirrorList->new( scheme => 'http' );

isa_ok $ml, 'Cygwin::PackageDB::MirrorList';

my $mirror = $ml->random_mirror;

isa_ok $mirror, 'Cygwin::PackageDB::Mirror';

note $mirror->as_string;

isa_ok $mirror->uri, 'URI';

like $mirror->uri->scheme, qr{^(ftp|http)$}, "scheme = " . $mirror->uri->scheme;
is $mirror->uri->host, $mirror->host, 'mirror.uri.host = mirror.host = ' . $mirror->host;

isnt $mirror->region, '', "mirror.region = " . $mirror->region;
isnt $mirror->subregion, '', "mirror.subregion = " . $mirror->subregion;
