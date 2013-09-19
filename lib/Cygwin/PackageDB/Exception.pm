package Cygwin::PackageDB::Exception;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';

# ABSTRACT: Exceptions thrown by Cygwin::PackageDB
# VERSION

=head1 DESCRIPTION

L<Cygwin::PackageDB> uses exceptions that subclass
L<Throwable::Error>.  They are listed here for your reference.

=head1 EXCEPTIONS

=cut

extends 'Throwable::Error';

package Cygwin::PackageDB::NetworkException;

use Moo;
use warnings NONFATAL => 'all';

extends 'Cygwin::PackageDB::Exception';

=head2 Cygwin::PackageDB::NetworkException

This exception is thrown when L<Cygwin::PackageDB> encounters
a network error.

=head3 req

The L<HTTP::Request> object created for the network request.

=head3 res

The L<HTTP::Response> object returned by L<LWP::UserAgent>.

=cut

has req => (
  is       => 'ro',
  required => 1,
);

has res => (
  is       => 'ro',
  required => 1,
);

around BUILDARGS => sub {
  my $orig = shift;
  my $self = shift;
  my $r = $self->$orig(@_);
  $r->{message} = join(' ', $r->{req}->uri, $r->{res}->status_line);
  $r;
};

package Cygwin::PackageDB::ParserException;

use Moo;
use warnings NONFATAL => 'all';

extends 'Cygwin::PackageDB::Exception';

=head2 Cygwin::PackageDB::ParserException

This exception is thrown when L<Cygwin::PackageDB> encounters an
error when it tries to parser the Cygwin C<setup.ini> file.

=head3 raw

If available, this attribute will contain a fragment of the C<setup.ini>
file that contains an error.  This is intended to aid in debugging, but
the actual content may change as the implementation evolves, so don't depend
to closely on its contents.

=head3 type

A string identifying the type of error, will be one of C<preamble>,
C<package_preamble>, C<key_value> or C<string>.

=cut

has raw => ( is => 'ro' );
has type => ( is => 'ro', required => 1 );

around BUILDARGS => sub {
  my $orig = shift;
  my $self = shift;
  my $r = $self->$orig(@_);
  $r->{message} = sprintf "parser error (%s): %s", $r->{type}, $r->{raw} // '**no context**';
  $r;
};

# TODO: line numbers would be nice.

1;
