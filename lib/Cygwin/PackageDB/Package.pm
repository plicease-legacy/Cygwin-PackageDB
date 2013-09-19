package Cygwin::PackageDB::Package;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use PerlX::Maybe qw( maybe );
use Cygwin::PackageDB::Exception;

# ABSTRACT: Cygwin package mirror
# VERSION

=head1 SYNOPSIS

 use Cygwin::PackageDB;
 my $db = Cygwin::PackageDB->new;
 # $pl isa Cygwin::PackageDB::PackageList
 my $pl = $db->package_list;
 
 foreach my $package (@{ $pl->packages })
 {
   # $package isa Cygwin::PackageDB::Package
   say $package->name;
   # relative path, size and md5sum of the binary package
   my($path, $size, $md5sum) = $package->install;
 }

=head1 DESCRIPTION

This class represents a single Cygwin Package.

=cut

sub BUILDARGS
{
  my $class = shift;
  if(@_ % 2 && !ref $_[0]) {
    my $raw = shift;
    return {
      hash => $raw,
      @_,
    };
  }
  return $class->SUPER::BUILDARGS(@_);
}

=head1 ATTRIBUTES

=head2 hash

This is the internal representation of the package for this
class stored as a hash reference.  Feel free to peek into
it, but keep in mind that its contents are subject to change,
so don't count on any particular structure or organization.

=cut

has hash => (
  is       => 'ro',
  required => 1,
  coerce   => sub {
    return $_[0] if ref($_[0]) eq 'HASH';
    my @raw = split /\n/, $_[0];
    my %ret;
    do {
      my $line = shift @raw;
      if($line =~ m{^@? (\S+)})
      { $ret{name} = $1 }
      else
      { Cygwin::PackageDB::ParserException->throw(raw => $line, type => 'package_preamble') }
    };
    
    my $h = \%ret;
    
    my $last_key;
    while(@raw > 0)
    {
      my $line = shift @raw;
      next if $line =~ /^\s*$/;
      
      if($line =~ /^(\w+):(.*)$/)
      {
        my $key = $1;
        my $val = $2;
        my @val;
        
        while(length($val) > 0)
        {
          if($val =~ s/^\s*([a-zA-Z0-9_\.\/:\\\+\~\-\!]+)//)
          {
            push @val, $1;
          }
          # Question: what about "foo \" bar"
          elsif($val =~ s/^\s*"(.*?)"//s)
          {
            my $val = $1;
            $val =~ s/\\(.)/$1/sg;
            push @val, $val;
          }
          elsif($val =~ /^\s"/s)
          {
            $val .= "\n" . shift @raw;
          }
          else
          {
            Cygwin::PackageDB::ParserException->throw(raw => $line, type => 'string')
          }
        }
        
        $h->{$key} = \@val;
      }
      elsif($line =~ /^\[(curr|test|exp|prev)\]$/)
      {
        my $type = $1;
        $ret{$type} //= [];
        $h = {};
        push @{ $ret{$type} }, $h;
      }
      else
      {
        Cygwin::PackageDB::ParserException->throw(raw => $line, type => 'key_value')
      }
    }
    \%ret;
  },
);

=head2 name

The name of the package.

=head2 sdesc

Short description of the package.

=head2 ldesc

Long description of the package.

=head2 version

Version of the package.

=head2 requires

List of packages that are prerequisites of this one.  Returned as
a list reference.

=head2 category

List of categories this package belongs to.  Returned as a list
reference.

=head2 install

 my($path, $size, $md5sum) = $package->install;

Returns the relative path, size and md5 sum of the binary package.

=head2 source

 my($path, $size, $md5sum) = $package->source;

Returns the relative path, size and md5 sum of the source package.

=cut

sub name     { shift->hash->{name}               }
sub sdesc    { shift->hash->{sdesc}->[0]         }
sub ldesc    { shift->hash->{ldesc}->[0]         }
sub version  { shift->hash->{version}->[0]       }
sub requires { shift->hash->{requires}           }
sub category { shift->hash->{category}           }
sub install  { @{ shift->hash->{install} // [] } }
sub source   { @{ shift->hash->{source}  // [] } }

=head1 METHODS

=head2 prev

Returns the previous version of the package as an instance of
C<Cygwin::PackageDB::Package>, if available.  Returns undef if 
it is not available.

=cut

sub prev
{
  my($self) = shift;
  return undef unless @{ $self->hash->{prev} // [] };
  # make a copy of hash
  my %h = %{ $self->hash };
  $h{prev} = [ @{ $self->hash->{prev} } ];
  my $prev = shift @{ $h{prev} };
  while(my($k,$v) = each %$prev)
  {
    $h{$k} = $v;
  }
  __PACKAGE__->new(hash => \%h);
}

1;
