use strict;
use warnings;
use Test::More tests => 12;
use Cygwin::SetupDatabase::MirrorList;
use Path::Class qw( file dir );
use File::Temp qw( tempdir );
use URI;
use URI::file;

my $mirror_list_file = file( tempdir( CLEANUP => 1), "mirror.lst" );
my $mirror_list_uri  = URI::file->new($mirror_list_file);
$mirror_list_file->spew(do { local $/; <DATA> });


do {
  my $ml = Cygwin::SetupDatabase::MirrorList->new;
  isa_ok $ml->uri, 'URI';
  is $ml->uri->as_string, 'http://cygwin.com/mirrors.lst', 'uri = http://cygwin.com/mirrors.lst';
};

do {
  my $ml = Cygwin::SetupDatabase::MirrorList->new( uri => "http://example.com/stuffandthing" );
  isa_ok $ml->uri, 'URI';
  is $ml->uri->as_string, "http://example.com/stuffandthing", 'uri = http://example.com/stuffandthing';
};

do {
  my $ml = Cygwin::SetupDatabase::MirrorList->new( uri => URI->new("http://example.com/stuffandthing") );
  isa_ok $ml->uri, 'URI';
  is $ml->uri->as_string, "http://example.com/stuffandthing", 'uri = http://example.com/stuffandthing';
};

do {
  my $ml = Cygwin::SetupDatabase::MirrorList->new( uri => $mirror_list_file );
  isa_ok $ml->uri, 'URI';
  is $ml->uri->scheme, 'file', "is a file uri";
  my $file = file($ml->uri->path);
  is $file->slurp, $mirror_list_file->slurp, "content matches";
};

do {
  my $ml = Cygwin::SetupDatabase::MirrorList->new( uri => URI::file->new($mirror_list_file) );
  isa_ok $ml->uri, 'URI';
  is $ml->uri->scheme, 'file', "is a file uri";
  my $file = file($ml->uri->path);
  is $file->slurp, $mirror_list_file->slurp, "content matches";
};

__DATA__
ftp://ftp.is.co.za/mirrors/cygwin/;ftp.is.co.za;Africa;South Africa
ftp://mirrors.neusoft.edu.cn/mirror/cygwin/;mirrors.neusoft.edu.cn;Asia;China
http://mirrors.163.com/cygwin/;mirrors.163.com;Asia;China
