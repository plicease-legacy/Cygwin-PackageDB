# Cygwin::PackageDB

Fetch and query the Cygwin Setup Package Database

# SYNOPSIS

    use Cygwin::PackageDB;
    
    # only use mirrors in United States
    my $db = Cygwin::PackageDB->new(
      region => 'United States',
    );
    
    # $pl isa Cygwin::PackageDB::PackageList
    my $pl = $db->package_list;
    
    foreach my $package (@{ $pl->packages })
    {
      # $package isa Cygwin::PackageDB::Package
      say $package->name;
    }

# DESCRIPTION

`Cygwin::PackageDB` provides an interface for downloading and querying
Cygwin's `setup.ini` package database.  It fetches the same mirror list
as `setup.exe` does, and allows you to narrow down the list of mirrors
by location (or scheme `http`/`ftp`), and will choose one at random,
or you can pick your own mirror.

Although this distribution is designed for downloading and querying Cygwin
packages, it doesn't include any Cygwin specific code, so it should happily
work on any Perl supported platform with the appropriate prerequisites.

# ATTRIBUTES

## ua

The [LWP::UserAgent](http://search.cpan.org/perldoc?LWP::UserAgent) instance used to fetch files from the Internet.
You can provide your own if you prefer, or one will be created if
you don't.

## uri

A URI that points to the mirror list.  [http://cygwin.com/mirrors.lst](http://cygwin.com/mirrors.lst) will
be used if you don't specify anything.  You may use any of:

- an instance of [URI](http://search.cpan.org/perldoc?URI)
- an instance of [Path::Class::File](http://search.cpan.org/perldoc?Path::Class::File) for a local mirror
- a string for either a URL or local file

## scheme

The URI scheme to use for downloading from mirrors.  This will limit the list of
mirrors that you can download from.  This is usually either `ftp` or `http`, but
can be any valid URI scheme, if you have a private mirror list and mirror.

If you are behind a firewall that blocks FTP traffic you might want to set this
to `http`.

## region

The region to limit mirrors from.  This will be something like `United States`
or `Australasia`.

## subregion

The subregion to limit mirrors from.  This will be something like `Colorado`
or `Australia` (yeah, I know).

## mirror\_list

List of mirrors, already pruned of any unwanted mirrors (specified via
`scheme`, `region` or `subregion`).  This is an instance of
[Cygwin::PackageDB::MirrorList](http://search.cpan.org/perldoc?Cygwin::PackageDB::MirrorList).

## mirror

Mirror to use.  This will be selected randomly, from `mirror_list`, or
you can set it to one that you prefer as it is a read/write attribute.
This is an instance of [Cygwin::PackageDB::Mirror](http://search.cpan.org/perldoc?Cygwin::PackageDB::Mirror).

# METHODS

## package\_list

    # $pl isa L<Cygwin::PackageDB::PackageList>
    my $pl = $db->package_list(%args);

Fetch a full package list from the selected mirror.  An instance of
[Cygwin::PackageDB::PackageList](http://search.cpan.org/perldoc?Cygwin::PackageDB::PackageList) will be returned.  You may specify 
additional options for this method:

- arch

    one of either x86 or x86\_64

- bz2

    If true then download the bzip2 compressed version of setup.ini instead
    of the plain text.  This requires [Compress::Bzip2](http://search.cpan.org/perldoc?Compress::Bzip2), which isn't a
    hard prerequisite of this module, so make sure you have it installed
    or mark it as a prerequisite of your code if you use it.  The default
    is false.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# SEE ALSO

- [Cygwin::PackageDB::Package](http://search.cpan.org/perldoc?Cygwin::PackageDB::Package)
- [Cygwin::PackageDB::Exception](http://search.cpan.org/perldoc?Cygwin::PackageDB::Exception)
- [Cygwin::PackageDB::MirrorList](http://search.cpan.org/perldoc?Cygwin::PackageDB::MirrorList)
- [Cygwin::PackageDB::PackageList](http://search.cpan.org/perldoc?Cygwin::PackageDB::PackageList)
- [Cygwin::PackageDB::Mirror](http://search.cpan.org/perldoc?Cygwin::PackageDB::Mirror)
