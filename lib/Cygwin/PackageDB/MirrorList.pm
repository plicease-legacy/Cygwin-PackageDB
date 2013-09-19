package Cygwin::PackageDB::MirrorList;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';

# ABSTRACT: Cygwin package mirror list
# VERSION

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

has ua => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    require LWP::UserAgent;
    LWP::UserAgent->new;
  },
);

has mirrors => (
  is      => 'ro',
  lazy    => 1,
  default => sub {
    my $self = shift;
    my $res = $self->ua->get($self->uri);
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
      # TODO: structured exception
      die join(' ', $self->uri, $res->status_line);
    }
  },
);

sub size { int @{ shift->mirrors } }

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

sub random_mirror
{
  my $list = shift->mirrors;
  $list->[rand @$list];
}

1;
