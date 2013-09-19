package Cygwin::PackageDB::PackageList;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use Cygwin::PackageDB::Package;
use Cygwin::PackageDB::Exception;

# ABSTRACT: Cygwin package list
# VERSION

sub BUILDARGS
{
  my $class = shift;
  if(@_ % 2 && !ref $_[0]) {
    my $raw = shift;    
    my %ret = @_;
    my($preamble, @package_list) = split /@/, $raw;
    foreach my $line (split /\n/, $preamble)
    {
      my $raw = $line;
      $line =~ s/^#.*$//;
      next if $line =~ /^\s*$/;
      if($line =~ /^(.*):\s*(.*)$/)
      {
        my($key,$val) = ($1,$2);
        $key =~ s/-/_/g;
        $ret{$key} = $val;
      }
      else
      {
        Cygwin::PackageDB::ParserException->throw(raw => $raw, type => 'preamble');
      }
    }
    $ret{packages} = \@package_list;
    return \%ret;
  }
  return $class->SUPER::BUILDARGS(@_);
}

has packages => (
  is      => 'ro',
  default => sub { [] },
  coerce  => sub {
    [map { ref $_ ? $_ : Cygwin::PackageDB::Package->new($_) } @{ $_[0] }];
  },
);

sub size { int @{ shift->packages } }

foreach my $key (qw( release arch setup_timestamp setup_version ))
{ has $key => ( is => 'ro' ) }

1;
