package Cygwin::PackageDB::Mirror;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use PerlX::Maybe qw( maybe );
use overload '""' => sub { shift->as_string };
use Cygwin::PackageDB::Exception;

# ABSTRACT: Cygwin package mirror
# VERSION

=head1 SYNOPSIS

 use Cygwin::PackageDB;
 my $db = Cygwin::PackageB->new;
 # $mirror is a randomly selected Cygwin::PackageDB::Mirror
 my $mirror = $db->mirror;
 
 # $setup_ini is the string content
 # of the setup.ini file.
 my $setup_ini = $mirror->fetch;
 
 # $uri isa URI
 my $uri = $mirror->uri_for('x86/release/perl/perl-5.14.2-3.tar.bz2');
 
 # $res isa HTTP::Response
 my $res = $mirror->get('x86/release/perl/perl-5.14.2-3.tar.bz2');

=head1 DESCRIPTION

This class represents a Cygwin mirror and may be used for downloading
the C<setup.ini> file, computing the URLs for files on the mirror,
or downloading files from the mirror (using L<LWP::UserAgent>).

Normally you select a mirror using L<Cygwin::PackageDB> or
L<Cygwin::PackageDB::MirrorList>, so see those classes for the interface
for selecting a mirror.

=cut

sub BUILDARGS
{
  my $class = shift;
  if(@_ % 2) {
    my($uri,$host,$reg,$subreg) = split /;/, shift;
    my %args = @_;
    return {
            uri       => $uri,
            host      => $host,
            region    => $reg,
            subregion => $subreg,
      maybe ua        => $args{ua},
    };
  }
  return $class->SUPER::BUILDARGS(@_);
}

=head1 ATTRIBUTES

=head2 uri

The base URL of the cygwin mirror.  This will be an instance of L<URI>.

=head2 host

The hostname of the cygwin mirror.

=head2 region

The region to limit mirrors from.  This will be something like C<United States>
or C<Australasia>.

=head2 subregion

The subregion to limit mirrors from.  This will be something like C<Colorado>
or C<Australia> (yeah, I know).

=cut

has uri => (
  is       => 'ro',
  required => 1,
  coerce   => sub { ref($_[0]) ? $_[0]->clone : do { require URI; URI->new($_[0]) } },
);

has host      => ( required => 1, is => 'ro' );
has region    => ( required => 1, is => 'ro' );
has subregion => ( required => 1, is => 'ro' );

=head2 ua

The L<LWP::UserAgent> instance used to fetch files from the Internet.
You can provide your own if you prefer, or one will be created if
you don't.

=cut

has ua => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require LWP::UserAgent;
    LWP::UserAgent->new;
  },
);

=head1 METHODS

=head2 uri_for

 # $uri isa URI
 my $uri = $mirror->uri_for('x86/release/perl/perl-5.14.2-3.tar.bz2');

Given a relative path, this method returns the absolute URL to the file
with this mirror.  It returns an instance of L<URI>.

=cut

sub uri_for
{
  my($self, $path) = @_;
  $path =~ s{^/}{};
  my $uri = $self->uri->clone;
  $uri->path(join('/', $uri->path, $path));
  $uri;
}

=head2 get

 # $res isa HTTP::Response
 my $res = $mirror->get('x86/release/perl/perl-5.14.2-3.tar.bz2');
 # save the download
 open my $fh, '>', "perl-5.14.2-3.tar.bz2";
 print $fh $res->decoded_content;
 close $fh;

Given a relative path, this method fetches the given file from the
mirror and returns it as a L<HTTP::Response> object.  It will
throw a L<Cygwin::PackageDB::Exception> on error.

=cut

sub get
{
  my($self, $path) = @_;
  
  require HTTP::Request;
  my $req = HTTP::Request->new(GET => $self->uri_for($path));
  my $res = $self->ua->request($req);
  return $res if $res->is_success;
  Cygwin::PackageDB::NetworkException->throw(
    req => $req,
    res => $res,
  );
}

=head2 fetch_setup_ini

 # $setup_ini is the string content
 # of the setup.ini file.
 my $setup_ini = $mirror->fetch(%options);

This returns the content of the C<setup.ini> file on the mirror.  You may specify
these options:

=over 4

=item arch

one of either x86 or x86_64

=item bz2

If true then download the bzip2 compressed version of setup.ini instead
of the plain text.  This requires L<Compress::Bzip2>, which isn't a
hard prerequisite of this module, so make sure you have it installed
or mark it as a prerequisite of your code if you use it.  The default
is false.

=back

=cut

sub fetch_setup_ini
{
  my($self) = shift;
  my %args = ref($_[0]) eq 'HASH' ? %{ shift() } : @_ ;
  
  $args{arch} //= 'x86';

  require Compress::Bzip2 if $args{bz2};
  
  my $res = $self->get(join('/', $args{arch}, $args{bz2} ? 'setup.bz2' : 'setup.ini'));  
  
  return $args{bz2} ? Compress::Bzip2::memBunzip($res->content) : $res->decoded_content;
}

=head2 as_string

Returns a string representation of the mirror.  This is a semicolon separated
list of the URL, hostname, region and subregion (this is the same format in
the mirror list file).

=cut

sub as_string
{
  my($self) = @_;
  join ';', $self->uri, $self->host, $self->region, $self->subregion;
}

1;
