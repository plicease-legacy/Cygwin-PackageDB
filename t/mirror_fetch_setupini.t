use strict;
use warnings;
use Test::More tests => 5;
use URI::file;
use Cygwin::PackageDB::Mirror;
use Path::Class qw( file dir );
use URI::file;

my $uri = URI::file->new(file(__FILE__)->parent->subdir('mirror')->absolute);
$uri->host('localhost');

note $uri->as_string;

my $mirror = Cygwin::PackageDB::Mirror->new(
  uri       => $uri,
  host      => $uri->host,
  region    => 'ThisServer',
  subregion => 'ThisFile',
);

isa_ok $mirror, 'Cygwin::PackageDB::Mirror';

note $mirror->as_string;

do {
  my $x86 = eval { $mirror->fetch_setup_ini };
  diag $@ if $@;
  like $x86, qr{^arch: x86$}m, "setup.ini =~ arch: x86";
};

do {
  my $x86_64 = eval { $mirror->fetch_setup_ini( arch => 'x86_64' ) };
  diag $@ if $@;
  like $x86_64, qr{^arch: x86_64$}m, "setup.ini =~ arch: x86_64";
};

do {
  my $x86_64 = eval { $mirror->fetch_setup_ini({ arch => 'x86_64' }) };
  diag $@ if $@;
  like $x86_64, qr{^arch: x86_64$}m, "setup.ini =~ arch: x86_64";
};

SKIP: {
  skip 'test requires Compress::Bzip2', 1 unless eval q{ use Compress::Bzip2; 1 };
  my $x86 = eval { $mirror->fetch_setup_ini( bz2 => 1 ) };
  diag $@ if $@;
  like $x86, qr{^arch: x86$}m, "setup.ini =~ arch: x86";
};
