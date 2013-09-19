package Cygwin::PackageDB;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use PerlX::Maybe qw( maybe );

# ABSTRACT: Fetch and query the Cygwin Setup Package Database
# VERSION

has ua => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require LWP::UserAgent;
    LWP::UserAgent->new;
  },
);

has uri => ( is => 'ro' );

foreach my $attr ( qw( scheme region subregion ) )
{
  has $attr => ( is => 'ro' );
}

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

has mirror => (
  is      => 'rw',
  lazy    => 1,
  default => sub {
    shift->mirror_list->random_mirror;
  },
);

sub package_list
{
  my $self = shift;
  require Cygwin::PackageDB::PackageList;
  Cygwin::PackageDB::PackageList->new($self->mirror->fetch_setup_ini);
}

1;
