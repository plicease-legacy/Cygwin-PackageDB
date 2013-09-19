package Cygwin::PackageDB::Package;

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
  if(@_ % 2 && !ref $_[0]) {
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
            die "parse error: $line";
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
        # TODO: structured exception?
        die "parse error: $line";
      }
    }
    \%ret;
  },
);

sub name     { shift->hash->{name}            }
sub sdesc    { shift->hash->{sdesc}->[0]      }
sub ldesc    { shift->hash->{ldesc}->[0]      }
sub version  { shift->hash->{version}->[0]    }
sub requires { shift->hash->{requires}        }
sub category { shift->hash->{category}        }
sub install  { @{ shift->hash->{install} }    }
sub source   { @{ shift->hash->{source}  }    }

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
