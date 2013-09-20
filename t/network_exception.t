use strict;
use warnings;
use Test::More tests => 12;
use Cygwin::PackageDB::Mirror;
use Cygwin::PackageDB::MirrorList;
use Path::Class qw( file dir );
use URI::file;

do {
  my $ml = Cygwin::PackageDB::MirrorList->new(
    uri => URI::file->new(
      file(__FILE__)->parent->subdir('bogus')->absolute,
    )
  );
    
  eval { $ml->mirrors };
  my $error = $@;
  note "error = $error";
  note "error.message = " . $error->message;
  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::NetworkException';  
  
  isa_ok $error->res, 'HTTP::Response';
  isa_ok $error->req, 'HTTP::Request';
  
  like $error->message, qr{bogus}, "error.message like /bogus/";
  like $error->message, qr{404}, "error.message like /404/";
  
};

do {
  my $mirror = Cygwin::PackageDB::Mirror->new(
    uri       => URI::file->new(
      file(__FILE__)->parent->subdir('mirror')->absolute,
    ),
    host      => 'localhost',
    region    => 'local',
    subregion => 'host',
  );
  
  eval { $mirror->get('/bogus/stuff') };
  my $error = $@;
  note "error = $error";
  note "error.message = " . $error->message;

  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::NetworkException';  
  
  isa_ok $error->res, 'HTTP::Response';
  isa_ok $error->req, 'HTTP::Request';
  
  like $error->message, qr{bogus}, "error.message like /bogus/";
  like $error->message, qr{404}, "error.message like /404/";
};
