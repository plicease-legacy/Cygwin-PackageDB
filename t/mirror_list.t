use strict;
use warnings;
use Test::More tests => 24;
use Cygwin::SetupDatabase::MirrorList;
use File::Temp qw( tempdir );
use Path::Class qw( file dir );
use URI::file;

my $mirror_list_file = file( tempdir( CLEANUP => 1), "mirror.lst" );
my $mirror_list_uri  = URI::file->new($mirror_list_file);
$mirror_list_file->spew(do { local $/; <DATA> });

my $mirror_list = Cygwin::SetupDatabase::MirrorList->new(
  uri => $mirror_list_uri,
);

isa_ok $mirror_list, 'Cygwin::SetupDatabase::MirrorList';
isa_ok eval { $mirror_list->uri }, 'URI';
diag $@ if $@;

isa_ok $mirror_list->ua, 'LWP::UserAgent';

is int(@{ $mirror_list->mirrors }), 3, "found exactly three mirrors";

is $mirror_list->mirrors->[0]->uri,       'ftp://ftp.is.co.za/mirrors/cygwin/';
is $mirror_list->mirrors->[0]->host,      'ftp.is.co.za';
is $mirror_list->mirrors->[0]->region,    'Africa';
is $mirror_list->mirrors->[0]->subregion, 'South Africa';

is $mirror_list->mirrors->[1]->uri,       'ftp://mirrors.neusoft.edu.cn/mirror/cygwin/';
is $mirror_list->mirrors->[1]->host,      'mirrors.neusoft.edu.cn';
is $mirror_list->mirrors->[1]->region,    'Asia';
is $mirror_list->mirrors->[1]->subregion, 'China';

is $mirror_list->mirrors->[2]->uri,       'http://mirrors.163.com/cygwin/';
is $mirror_list->mirrors->[2]->host,      'mirrors.163.com';
is $mirror_list->mirrors->[2]->region,    'Asia';
is $mirror_list->mirrors->[2]->subregion, 'China';

is $mirror_list->size, 3, 'mirrorlist.size = 3';

my $africa = eval { $mirror_list->filter(region => 'Africa')   };
my $china  = eval { $mirror_list->filter(subregion => 'China') };

isa_ok $africa, 'Cygwin::SetupDatabase::MirrorList';
isa_ok $china, 'Cygwin::SetupDatabase::MirrorList';

is int(@{ $africa->mirrors }), 1, 'africa = 1';
is int(@{ $china->mirrors  }), 2, 'china = 2';

is $africa->size, 1, 'africa.size = 1';
is $china->size,  2, 'china.size = 2';

my $mirror = eval { $mirror_list->random_mirror };
isa_ok $mirror, 'Cygwin::SetupDatabase::Mirror';
diag $@ if $@;

note $mirror->as_string;

__DATA__
ftp://ftp.is.co.za/mirrors/cygwin/;ftp.is.co.za;Africa;South Africa
ftp://mirrors.neusoft.edu.cn/mirror/cygwin/;mirrors.neusoft.edu.cn;Asia;China
http://mirrors.163.com/cygwin/;mirrors.163.com;Asia;China



