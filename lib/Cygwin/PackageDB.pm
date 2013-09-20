package Cygwin::PackageDB;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use PerlX::Maybe qw( maybe );

# ABSTRACT: Fetch and query the Cygwin Setup Package Database
# VERSION

=head1 SYNOPSIS

 use Cygwin::PackageDB;
 
 # only use mirrors in United States
 my $db = Cygwin::PackageDB->new(
   region => 'United States',
 );
 
 # $pl isa Cygwin::PackageDB::PackageList
 my $pl = $db->package_list;
 
 foreach my $package (@{ $pl->packages })
 {
   # $package isa Cygwin::PackageDB::Package
   say $package->name;
 }

=head1 DESCRIPTION

C<Cygwin::PackageDB> provides an interface for downloading and querying
Cygwin's C<setup.ini> package database.  It fetches the same mirror list
as C<setup.exe> does, and allows you to narrow down the list of mirrors
by location (or scheme C<http>/C<ftp>), and will choose one at random,
or you can pick your own mirror.

Although this distribution is designed for downloading and querying Cygwin
packages, it doesn't include any Cygwin specific code, so it should happily
work on any Perl supported platform with the appropriate prerequisites.

=head1 ATTRIBUTES

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

=head2 uri

A URI that points to the mirror list.  L<http://cygwin.com/mirrors.lst> will
be used if you don't specify anything.  You may use any of:

=over 4

=item an instance of L<URI>

=item an instance of L<Path::Class::File> for a local mirror

=item a string for either a URL or local file

=back

=cut

has uri => ( is => 'ro' );

=head2 scheme

The URI scheme to use for downloading from mirrors.  This will limit the list of
mirrors that you can download from.  This is usually either C<ftp> or C<http>, but
can be any valid URI scheme, if you have a private mirror list and mirror.

If you are behind a firewall that blocks FTP traffic you might want to set this
to C<http>.

=head2 region

The region to limit mirrors from.  This will be something like C<United States>
or C<Australasia>.

=head2 subregion

The subregion to limit mirrors from.  This will be something like C<Colorado>
or C<Australia> (yeah, I know).

=cut

foreach my $attr ( qw( scheme region subregion ) )
{
  has $attr => ( is => 'ro' );
}

=head2 mirror_list

List of mirrors, already pruned of any unwanted mirrors (specified via
C<scheme>, C<region> or C<subregion>).  This is an instance of
L<Cygwin::PackageDB::MirrorList>.

=cut

has mirror_list => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my $self = shift;
    require Cygwin::PackageDB::MirrorList;
    my $list = Cygwin::PackageDB::MirrorList->new(
            ua => $self->ua,
      maybe uri => $self->uri,
    );
    if($self->scheme || $self->region || $self->subregion)
    {
      return $list->filter(
        scheme    => $self->scheme,
        region    => $self->region,
        subregion => $self->subregion,
      );
    }
    else
    {
      return $list;
    }
  },
);

=head2 mirror

Mirror to use.  This will be selected randomly, from C<mirror_list>, or
you can set it to one that you prefer as it is a read/write attribute.
This is an instance of L<Cygwin::PackageDB::Mirror>.

=cut

has mirror => (
  is      => 'rw',
  lazy    => 1,
  default => sub {
    shift->mirror_list->random_mirror;
  },
);

=head1 METHODS

=head2 package_list

 # $pl isa L<Cygwin::PackageDB::PackageList>
 my $pl = $db->package_list(%args);

Fetch a full package list from the selected mirror.  An instance of
L<Cygwin::PackageDB::PackageList> will be returned.  You may specify 
additional options for this method:

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

sub package_list
{
  my $self = shift;
  require Cygwin::PackageDB::PackageList;
  Cygwin::PackageDB::PackageList->new($self->mirror->fetch_setup_ini(@_));
}

1;
