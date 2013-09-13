package Cygwin::SetupDatabase::Mirror;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';

sub BUILDARGS
{
  my $class = shift;
  if(@_ == 1) {
    my($uri,$host,$reg,$subreg) = split /;/, shift;
    return { uri => $uri, host => $host, region => $reg, subregion => $subreg };
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

sub as_string
{
  my($self) = @_;
  join ';', $self->uri, $self->host, $self->region, $self->subregion;
}

1;
