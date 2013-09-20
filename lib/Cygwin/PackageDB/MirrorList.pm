package Cygwin::PackageDB::MirrorList;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use Cygwin::PackageDB::Exception;

# ABSTRACT: Cygwin package mirror list
# VERSION

=head1 SYNOPSIS

 # indirectly
 use Cygwin::PackageDB;
 my $db = Cygwin::PackageDB->new;
 my $ml = $db->mirror_list;

 # directly:
 use Cygwin::PackageDB::MirrorList;
 my $ml = Cygwin::PackageDB::MirrorList->new;
 foreach my $mirror (@{ $ml->mirrors })
 {
   # $mirror isa Cygwin::PackageDB::Mirror
   say $mirror->uri;
 }
 
 # pick a random mirror
 # $ml isa Cygwin::PackageDB::Mirror
 my $mirror = $ml->random_mirror;
 
 # pick a random mirror in Australasia
 my $mirror = $ml->filter( region => 'Australasia' )->random_mirror; 

=head1 DESCRIPTION

This class represents a list of Cygwin mirrors.  You can
filter the list using the C<filter> method, or pick a
random one using the C<random_mirror> method.  Each mirror
is a L<Cygwin::PackageDB::Mirror>.

=head1 ATTRIBUTES

=head2 uri

A URI that points to the mirror list.  L<http://cygwin.com/mirrors.lst> will
be used if you don't specify anything.  You may use any of:

=over 4

=item an instance of L<URI>

=item an instance of L<Path::Class::File> for a local mirror

=item a string for either a URL or local file

=back

=cut

has uri => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require URI;
    URI->new("http://cygwin.com/mirrors.lst");
  },
  coerce  => sub {
    my $uri = shift;
    if(eval { $uri->isa('URI') })
    {
      return $uri->clone;
    }
    elsif(-f $uri)
    {
      require URI::file;
      return URI::file->new($uri);
    }
    else
    {
      require URI;
      return URI->new($uri);
    }
  },
);

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

=head2 mirrors

The mirrors in the list.  This is returned as a list reference
of L<Cygwin::PackageDB::Mirror> instances.

=cut

has mirrors => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my $self = shift;
    require HTTP::Request;
    my $req = HTTP::Request->new(GET => $self->uri);
    my $res = $self->ua->request($req);
    $DB::single = 1;
    if($res->is_success)
    {
      require Cygwin::PackageDB::Mirror;
      my @list;
      foreach my $line (split /\n/, $res->decoded_content)
      {
        next if $line =~ /^\s*$/;
        push @list, Cygwin::PackageDB::Mirror->new($line, ua => $self->ua);
      }
      return \@list;
    }
    else
    {
      Cygwin::PackageDB::NetworkException->throw(
        req => $req,
        res => $res,
      );
    }
  },
);

=head2 size

This is the number of mirrors in the list.

=cut

sub size { int @{ shift->mirrors } }

=head1 METHODS

=head2 filter

 # $filtered_list isa Cygwin::PackageDB::MirrorList.
 my $filtered_list = $ml->filter(
   scheme => 'http',
   region => 'United States',
   subregion => 'Colarado',
 );

Filter the list by these specifications and return a new
C<Cygwin::PackageDB::MirrorList> that contains just the
matching mirrors.  If you don't provide a specification
for a particular field, it will not filter by that field.

=over 4

=item scheme

The URI scheme to use for downloading from mirrors.  This will limit the list of
mirrors that you can download from.  This is usually either C<ftp> or C<http>, but
can be any valid URI scheme, if you have a private mirror list and mirror.

If you are behind a firewall that blocks FTP traffic you might want to set this
to C<http>.

=item region

The region to limit mirrors from.  This will be something like C<United States>
or C<Australasia>.

=item subregion

The subregion to limit mirrors from.  This will be something like C<Colorado>
or C<Australia> (yeah, I know).

=back

=cut

sub filter
{
  my $self = shift;
  my $args = ref($_[0]) eq 'HASH' ? $_[0] : { @_ };
  
  my @list;
  
  foreach my $mirror (@{ $self->mirrors })
  {
    next if $args->{region} && $args->{region} ne $mirror->region;
    next if $args->{subregion} && $args->{subregion} ne $mirror->subregion;
    next if $args->{scheme} && $args->{scheme} ne $mirror->uri->scheme;
    push @list, $mirror;
  }
  
  __PACKAGE__->new(
    uri     => $self->uri,
    ua      => $self->ua,
    mirrors => \@list,
  );
}

=head2 random_mirror

Pick a random mirror from the list.  Returns an instance of
L<Cygwin::PackageDB::Mirror>.

=cut

sub random_mirror
{
  my $list = shift->mirrors;
  $list->[rand @$list];
}

1;

