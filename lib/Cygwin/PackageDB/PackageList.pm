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

=head1 SYNOPSIS

 use Cygwin::PackageDB;
 my $db = Cygwin::PackageDB->new;
 # $pl is an instance of Cygwin::PackageDB::PackageList
 my $pl = $db->package_list;
 
 foreach my $package (@{ $pl->packages })
 {
   # $package isa Cygwin::PackageDB::Package
   say $package->name;
 }

=head1 DESCRIPTION

This class represents a list of Cygwin packages.

=cut

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

=head1 ATTRIBUTES

=head2 packages

The actual list of packages.  This is returned as a list reference of
L<Cygwin::PackageDB::Package> instances.

=cut

has packages => (
  is      => 'ro',
  default => sub { [] },
  coerce  => sub {
    [map { ref $_ ? $_ : Cygwin::PackageDB::Package->new($_) } @{ $_[0] }];
  },
);

=head2 size

The size of the list.

=cut

sub size { int @{ shift->packages } }

=head2 release

The release name.  As far as I can tell this is always C<cygwin>.

=head2 arch

The CPU architecture.  One of either (so far) C<x86> or C<x86_64>.

=head2 setup_timestamp

Timestamp for when (presumably) the C<setup.ini> file was generated.

=head2 setup_version

The corresponding C<setup.exe> version.

=cut

foreach my $key (qw( release arch setup_timestamp setup_version ))
{ has $key => ( is => 'ro' ) }

1;
