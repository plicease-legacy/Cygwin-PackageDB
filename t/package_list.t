use strict;
use warnings;
use Test::More tests => 12;
use Path::Class qw( file dir );
use Cygwin::PackageDB::PackageList;

my $raw = file(__FILE__)->parent->file(qw( mirror x86 setup.ini ))->slurp;

my $pl = Cygwin::PackageDB::PackageList->new( $raw );
isa_ok $pl, 'Cygwin::PackageDB::PackageList';

is int(@{ $pl->packages }), 4, "int(pl.packages) = 4";
is $pl->size, 4, 'pl.size = 4';

isa_ok $pl->packages->[$_], 'Cygwin::PackageDB::Package' for 0..3;

is $pl->release,         'cygwin',     'pl.release         = cygwin';
is $pl->arch,            'x86',        'pl.arch            = x86';
is $pl->setup_timestamp, '1379058227', 'pl.setup_timestamp = 1379058227';
is $pl->setup_version,   '2.819',      'pl.setup_version   = 2.819';

is_deeply [ sort qw( perl perl-Clone perl-Clone-debuginfo perl-DBD-mysql ) ], [ sort map { $_->name } @{ $pl->packages } ], "package list names";
