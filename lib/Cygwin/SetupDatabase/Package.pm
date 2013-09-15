package Cygwin::SetupDatabase::Package;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';
use PerlX::Maybe qw( maybe );

# ABSTRACT: Cygwin package mirror
# VERSION

sub BUILDARGS
{
  my $class = shift;
  if(@_ % 2) { # FIXME: single hash arg
    my $raw = shift;
    return {
      hash => $raw,
      @_,
    };
  }
  return $class->SUPER::BUILDARGS(@_);
}

has hash => (
  is       => 'ro',
  required => 1,
  coerce   => sub {
    return $_[0] if ref($_[0]) eq 'HASH';
    my @raw = split /\n/, $_[0];
    my %ret;
    if((shift @raw) =~ m{^@? (\S+)})
    { $ret{name} = $1 }
    
    my $h = \%ret;
    
    my $last_key;
    while(@raw > 0)
    {
      my $line = shift @raw;
      next if $line =~ /^\s*$/;
      
      if($line =~ /^(\w+): (.*)$/)
      {
        my $key = $1;
        my $val = $2;
        my $escape = 0;
        if($val =~ s/^"(.*)"$/$1/)
        {
          $escape = 1;
        }
        elsif($val =~ s/^"(.*)$/$1/)
        {
          $escape = 1;
          while(@raw > 0)
          {
            $val .= "\n";
            my $line = shift @raw;
            if($line =~ s/"$//)
            {
              $val .= $line;
              last;
            }
            $val .= $line;
          }
        }
        $val =~ s/\\(.)/$1/g if $escape;
        $h->{$key} = $val;
      }
      elsif($line eq '[prev]')
      {
        $ret{prev} //= [];
        $h = {};
        push @{ $ret{prev} }, $h;
      }
      else
      {
        # TODO: structured exception?
        die "parse error: $line";
      }
    }
    \%ret;
  },
);

sub name     { shift->hash->{name} }
sub sdesc    { shift->hash->{sdesc} }
sub ldesc    { shift->hash->{ldesc} }
sub version  { shift->hash->{version} }
sub requires { [split /\s+/, shift->hash->{requires}] }
sub category { [split /\s+/, shift->hash->{category}] }
sub install  {  split /\s+/, shift->hash->{install}   }
sub source   {  split /\s+/, shift->hash->{source}   }

sub prev
{
  my($self) = shift;
  return undef unless @{ $self->hash->{prev} };
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
