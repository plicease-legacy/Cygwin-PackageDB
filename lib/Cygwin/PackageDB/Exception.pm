package Cygwin::PackageDB::Exception;

use strict;
use warnings;
use v5.10;
use Moo;
use warnings NONFATAL => 'all';

# ABSTRACT: Exceptions thrown by Cygwin::PackageDB
# VERSION

=head1 DESCRIPTION

L<Cygwin::PackageDB> uses excpetions that subclass
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

has '+message' => (
  default => sub {
    my $self = shift;
    join join(' ', $self->req->uri, $self->status_line);
  },
);

package Cygwin::PackageDB::ParserException;

use Moo;
use warnings NONFATAL => 'all';

extends 'Cygwin::PackageDB::Exception';

=head2 Cygwin::PackageDB::ParserException

This exception is thrown when L<Cygwin::PackageDB> enconters an
error when it trys to parser the Cygwin C<setup.ini> file.

=head3 raw

If available, this attribute will contain a fragment of the C<setup.ini>
file that contains an error.

=cut

has raw => (
  is => 'ro',
);

1;
