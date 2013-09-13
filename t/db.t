use strict;
use warnings;
use Test::More tests => 3;
use Cygwin::SetupDatabase;

my $db = Cygwin::SetupDatabase->new;
isa_ok $db,                       'Cygwin::SetupDatabase';
isa_ok eval { $db->mirror_list }, 'Cygwin::SetupDatabase::MirrorList';
diag $@ if $@;
isa_ok eval { $db->mirror },      'Cygwin::SetupDatabase::Mirror';
diag $@ if $@;
