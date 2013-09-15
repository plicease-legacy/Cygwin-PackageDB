package Cygwin::SetupDatabase;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';

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

foreach my $attr ( qw( scheme region subregion ) )
{
  has $attr => ( is => 'ro' );
}

has mirror_list => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my $self = shift;
    require Cygwin::SetupDatabase::MirrorList;
    my $list = Cygwin::SetupDatabase::MirrorList->new( ua => $self->ua );
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
  require Cygwin::SetupDatabase::PackageList;
  Cygwin::SetupDatabase::PackageList->new($self->mirror->fetch_setup_ini);
}

1;
