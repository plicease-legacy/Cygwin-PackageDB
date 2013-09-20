use strict;
use warnings;
use Test::More tests => 16;
use Cygwin::PackageDB::Package;
use Cygwin::PackageDB::PackageList;

do {
  eval {
    Cygwin::PackageDB::Package->new("BOGUS BOGUS BOGUS");
  };
  my $error = $@;
  note "error = $error";
  
  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::ParserException';
  
  is eval { $error->type }, 'package_preamble', 'error.type = package_preamble';
  diag $@ if $@;
  
  like $error->raw, qr{BOGUS BOGUS}, 'error.raw like /BOGUS BOGUS/';
};

do {
  eval {
    Cygwin::PackageDB::Package->new("@ foobarbaz\nBOGUS BOGUS BOGUS");
  };
  my $error = $@;
  note "error = $error";

  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::ParserException';

  is eval { $error->type }, 'key_value', 'error.type = key_value';
  diag $@ if $@;

  like $error->raw, qr{BOGUS BOGUS}, 'error.raw like /BOGUS BOGUS/';
};

do {
  eval {
    Cygwin::PackageDB::Package->new("@ foobarbaz\nsource: BOGUS**BOGUS!!BOGUS");
  };
  my $error = $@;
  note "error = $error";

  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::ParserException';

  is eval { $error->type }, 'string', 'error.type = string';
  diag $@ if $@;

  like $error->raw, qr{BOGUS\*\*BOGUS}, 'error.raw like /BOGUS\*\*BOGUS/';
};

do {
  eval {
    Cygwin::PackageDB::PackageList->new("#\n#\n#\nBOGUS BOGUS BOGUS\n#\n#\n");
  };
  my $error = $@;
  note "error = $error";
  
  isa_ok $error, 'Cygwin::PackageDB::Exception';
  isa_ok $error, 'Cygwin::PackageDB::ParserException';

  is eval { $error->type }, 'preamble', 'error.type = preamble';
  diag $@ if $@;

  like $error->raw, qr{BOGUS BOGUS}, 'error.raw like /BOGUS BOGUS/';
};
