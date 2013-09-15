use strict;
use warnings;
use Test::More tests => 4;
use Cygwin::SetupDatabase;

my $db = Cygwin::SetupDatabase->new( region => 'United States' );
isa_ok $db,                       'Cygwin::SetupDatabase';
isa_ok eval { $db->mirror_list }, 'Cygwin::SetupDatabase::MirrorList';
diag $@ if $@;
isa_ok eval { $db->mirror },      'Cygwin::SetupDatabase::Mirror';
diag $@ if $@;

note $db->mirror;

my $pl = eval { $db->package_list };
diag $@ if $@;
isa_ok $pl, 'Cygwin::SetupDatabase::PackageList';
