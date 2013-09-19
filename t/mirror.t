use strict;
use warnings;
use Cygwin::PackageDB::Mirror;
use Test::More tests => 24;
use URI;

do {
  my $mirror = Cygwin::PackageDB::Mirror->new(
    uri       => "http://example.com/cygwin",
    host      => "example.com",
    region    => "Australasia",
    subregion => "Australia",
  );
  
  isa_ok $mirror, 'Cygwin::PackageDB::Mirror';
  isa_ok $mirror->uri, 'URI';
  is $mirror->uri->as_string, 'http://example.com/cygwin';
  is $mirror->host, 'example.com';
  is $mirror->region, 'Australasia';
  is $mirror->subregion, 'Australia';
  is $mirror->uri_for("/foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
  is $mirror->uri_for("foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
};

do {
  my $mirror = Cygwin::PackageDB::Mirror->new(
    uri       => URI->new("http://example.com/cygwin"),
    host      => "example.com",
    region    => "Australasia",
    subregion => "Australia",
  );
  
  isa_ok $mirror, 'Cygwin::PackageDB::Mirror';
  isa_ok $mirror->uri, 'URI';
  is $mirror->uri->as_string, 'http://example.com/cygwin';
  is $mirror->host, 'example.com';
  is $mirror->region, 'Australasia';
  is $mirror->subregion, 'Australia';
  is $mirror->uri_for("/foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
  is $mirror->uri_for("foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
};

do {
  my $mirror = Cygwin::PackageDB::Mirror->new(
    join(';', "http://example.com/cygwin", "example.com", "Australasia", "Australia"),
  );
  
  isa_ok $mirror, 'Cygwin::PackageDB::Mirror';
  isa_ok $mirror->uri, 'URI';
  is $mirror->uri->as_string, 'http://example.com/cygwin';
  is $mirror->host, 'example.com';
  is $mirror->region, 'Australasia';
  is $mirror->subregion, 'Australia';
  is $mirror->uri_for("/foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
  is $mirror->uri_for("foo/bar/baz")->as_string, 'http://example.com/cygwin/foo/bar/baz';
};
