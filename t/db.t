use strict;
use warnings;
use Test::More tests => 4;
use Cygwin::PackageDB;
use URI::file;
use Path::Class qw( file dir );
use File::Temp qw( tempdir );

my $mirror_list_file = dir( tempdir( CLEANUP => 1 ) )->file("mirrors.lst");

my $db = Cygwin::PackageDB->new(
  uri => do {
    my $file = dir( tempdir( CLEANUP => 1 ) )->file("mirrors.lst");
    $file->spew(
      join("\n", 
        join(';', URI::file->new(file(__FILE__)->parent->subdir("mirror")->absolute), 'localhost', 'local','host'),
        join(';', URI::file->new(file(__FILE__)->parent->subdir("mirror")->absolute), 'localhost', 'other','place'),
      ),
    );
    $file;
  },
);
  
isa_ok $db,                       'Cygwin::PackageDB';
isa_ok eval { $db->mirror_list }, 'Cygwin::PackageDB::MirrorList';
diag $@ if $@;
isa_ok eval { $db->mirror },      'Cygwin::PackageDB::Mirror';
diag $@ if $@;

note $db->mirror;

my $pl = eval { $db->package_list };
diag $@ if $@;
isa_ok $pl, 'Cygwin::PackageDB::PackageList';
