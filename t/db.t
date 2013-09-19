use strict;
use warnings;
use Test::More tests => 4;
use Cygwin::PackageDB;

my $db = Cygwin::PackageDB->new( region => 'United States', scheme => 'http' );
isa_ok $db,                       'Cygwin::PackageDB';
isa_ok eval { $db->mirror_list }, 'Cygwin::PackageDB::MirrorList';
diag $@ if $@;
isa_ok eval { $db->mirror },      'Cygwin::PackageDB::Mirror';
diag $@ if $@;

note $db->mirror;

my $pl = eval { $db->package_list };
diag $@ if $@;
isa_ok $pl, 'Cygwin::PackageDB::PackageList';
