package inc::Todo;

use strict;
use warnings;
use v5.10;
use Moose;

with 'Dist::Zilla::Role::FileMunger';

sub munge_files
{
  my($self) = @_;
 
  my @files = grep { $_->name =~ /lib\/.*\.pm$/ } @{ $self->zilla->files };
  my @classes = map { s/^lib\///; s/\.pm$//; s/\//::/g; $_ } map { $_->name } @files;
  
  $self->munge_file($_, \@classes) for @files;
}

sub munge_file
{
  my($self, $file, $classes) = @_;
  $self->log(" adding SEE ALSO to " . $file->name);

  my $class = $file->name;
  $class =~ s/^lib\///;
  $class =~ s/\.pm$//;
  $class =~ s/\//::/g;
  
  my $content = $file->content;
  
  my $see_also = "=head1 SEE ALSO\n\n=over 4\n\n"
               . join("\n\n", map { "=item L<$_>" } grep { $_ ne $class }@$classes)
               . "\n\n=back\n\n";
  $content =~ s{^(=head1 AUTHOR)}{$see_also$1}m;
  
  $file->content($content);
}

1;

