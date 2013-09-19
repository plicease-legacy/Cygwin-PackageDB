use strict;
use warnings;
use Test::More tests => 18;
use Cygwin::PackageDB::Package;
use Test::Differences;

my $pkg = Cygwin::PackageDB::Package->new(do { local $/; <DATA> });

isa_ok $pkg, 'Cygwin::PackageDB::Package';

#use YAML ();
#diag YAML::Dump($pkg->hash);

is $pkg->name, 'perl', 'pkg.name = perl';

is $pkg->sdesc, 'Larry Wall\'s Practical Extracting and Report Language', 'pkg.sdesc = Larry Wall\'s Practical Extracting and Report Language';
eq_or_diff $pkg->ldesc, 'Perl is a high-level programming language with roots in C,
sed, awk and shell scripting.  Perl is good at handling processes
and files, and is especially good at handling text.  Perl\'s
hallmarks are practicality and efficiency.  While it is used to
do a lot of different things, Perl\'s most common applications are
system administration utilities and web programming.  A large
proportion of the CGI scripts on the web are written in Perl.
You need the perl package installed on your system so that your
system can handle Perl scripts.', 'pkg.ldesc';

is $pkg->version, '5.14.2-3', 'pkg.version = 5.14.2-3';

is_deeply [sort @{ $pkg->requires } ], [sort qw( libssp0 libgcc1 libgdbm4 libdb4.5 crypt libbz2_1 perl_vendor _autorebase cygwin )], 'pkg->requires = ' . join(" ", @{ $pkg->requires });
is_deeply [sort @{ $pkg->category } ], [sort qw( Interpreters Perl ) ], 'pkg.category = ' . join(" ", @{ $pkg->category });
is_deeply [$pkg->install], [qw( x86/release/perl/perl-5.14.2-3.tar.bz2 11673542 db522160bdfabbe20c56b59244c731fa )], 'pkg.install';
is_deeply [$pkg->source], [qw( x86/release/perl/perl-5.14.2-3-src.tar.bz2 17627943 8a1d9eb3fd927b45b8c75fa8f590bcf0 )], 'pkg.source';

$pkg = $pkg->prev;
isa_ok $pkg, 'Cygwin::PackageDB::Package';

#use YAML ();
#diag YAML::Dump($pkg->hash);

is $pkg->name, 'perl', 'pkg.name = perl';

is $pkg->sdesc, 'Larry Wall\'s Practical Extracting and Report Language', 'pkg.sdesc = Larry Wall\'s Practical Extracting and Report Language';
eq_or_diff $pkg->ldesc, 'Perl is a high-level programming language with roots in C,
sed, awk and shell scripting.  Perl is good at handling processes
and files, and is especially good at handling text.  Perl\'s
hallmarks are practicality and efficiency.  While it is used to
do a lot of different things, Perl\'s most common applications are
system administration utilities and web programming.  A large
proportion of the CGI scripts on the web are written in Perl.
You need the perl package installed on your system so that your
system can handle Perl scripts.', 'pkg.ldesc';

is $pkg->version, '5.10.1-5', 'pkg.version = 5.10.1-5';

is_deeply [sort @{ $pkg->requires } ], [sort qw( libssp0 libgcc1 libgdbm4 libdb4.5 crypt libbz2_1 perl_vendor _autorebase cygwin )], 'pkg->requires = ' . join(" ", @{ $pkg->requires });
is_deeply [sort @{ $pkg->category } ], [sort qw( Interpreters Perl ) ], 'pkg.category = ' . join(" ", @{ $pkg->category });
is_deeply [$pkg->install], [qw( x86/release/perl/perl-5.10.1-5.tar.bz2 15722874 73a29d253b3d4238c6412aed0ad1ce37 )], 'pkg.install';
is_deeply [$pkg->source], [qw( x86/release/perl/perl-5.10.1-5-src.tar.bz2 19790517 486249859c9f1b7096e20c0c901839f0 )], 'pkg.source';

__DATA__
@ perl
sdesc: "Larry Wall\'s Practical Extracting and Report Language"
ldesc: "Perl is a high-level programming language with roots in C,
sed, awk and shell scripting.  Perl is good at handling processes
and files, and is especially good at handling text.  Perl\'s
hallmarks are practicality and efficiency.  While it is used to
do a lot of different things, Perl\'s most common applications are
system administration utilities and web programming.  A large
proportion of the CGI scripts on the web are written in Perl.
You need the perl package installed on your system so that your
system can handle Perl scripts."
category: Interpreters Perl
requires: libssp0 libgcc1 libgdbm4 libdb4.5 crypt libbz2_1 perl_vendor _autorebase cygwin
version: 5.14.2-3
install: x86/release/perl/perl-5.14.2-3.tar.bz2 11673542 db522160bdfabbe20c56b59244c731fa
source: x86/release/perl/perl-5.14.2-3-src.tar.bz2 17627943 8a1d9eb3fd927b45b8c75fa8f590bcf0
[prev]
version: 5.10.1-5
install: x86/release/perl/perl-5.10.1-5.tar.bz2 15722874 73a29d253b3d4238c6412aed0ad1ce37
source: x86/release/perl/perl-5.10.1-5-src.tar.bz2 19790517 486249859c9f1b7096e20c0c901839f0

