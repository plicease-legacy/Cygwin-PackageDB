package Cygwin::SetupDatabase::Mirror;

use strict;
use warnings;
use v5.10;
use Moo;
use PerlX::Maybe qw( maybe );
use warnings NONFATAL => 'all';

# ABSTRACT: Cygwin package mirror
# VERSION

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

has uri => (
  is       => 'ro',
  required => 1,
  coerce   => sub { ref($_[0]) ? $_[0]->clone : do { require URI; URI->new($_[0]) } },
);

has host      => ( required => 1, is => 'ro' );
has region    => ( required => 1, is => 'ro' );
has subregion => ( required => 1, is => 'ro' );

has ua => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require LWP::UserAgent;
    LWP::UserAgent->new;
  },
);

sub get
{
  my($self, $path) = @_;
  $path =~ s{^/}{};
  
  my $uri = $self->uri->clone;
  $uri->path(join('/', $uri->path, $path));
  my $res = $self->ua->get($uri);
  return $res if $res->is_success;
  # TODO: some sort of structured exception?
  die join(' ', $uri, $res->status_line);
}

sub fetch_setup_ini
{
  my($self) = shift;
  my %args = ref($_[0]) eq 'HASH' ? %{ shift() } : @_ ;
  
  $args{arch} //= 'x86';

  require Compress::Bzip2 if $args{bz2};
  
  my $res = $self->get(join('/', $args{arch}, $args{bz2} ? 'setup.bz2' : 'setup.ini'));  
  
  return $args{bz2} ? Compress::Bzip2::memBunzip($res->content) : $res->decoded_content;
}

sub as_string
{
  my($self) = @_;
  join ';', $self->uri, $self->host, $self->region, $self->subregion;
}

1;
