use strict;
use warnings;
use Test::More tests => 1;
use Cygwin::SetupDatabase::Package;

my $package = eval { Cygwin::SetupDatabase::Package->new(do { local $/; <DATA> }) };
diag $@ if $@;
isa_ok $package, 'Cygwin::SetupDatabase::Package';

__DATA__
@ avahi
sdesc: "MDNS/DNS_SD/Zeroconf implementation (daemon)"
ldesc: "Avahi is a system which facilitates service discovery on a local
network via the mDNS/DNS-SD protocol suite. This enables you to plug your
laptop or computer into a network and instantly be able to view other people
who you can chat with, find printers to print to or find files being shared."
category: Net
requires: bash libavahi-common3 libavahi-core7 libdaemon0 libdbus1_3 libexpat1 libssp0 csih dbus cygwin
version: 0.6.31-2
install: x86/release/avahi/avahi-0.6.31-2.tar.bz2 164198 0fc325ffc9706af98508280b8ff28a91
source: x86/release/avahi/avahi-0.6.31-2-src.tar.bz2 1301974 4d543cea80b6cd709284f4988e2dc8db
[prev]
version: 0.6.31-1
install: x86/release/avahi/avahi-0.6.31-1.tar.bz2 163783 054bf2c9cc320237fd5787d98bf23e06
source: x86/release/avahi/avahi-0.6.31-1-src.tar.bz2 1302938 ff874cb4ffc2d28716256c2da56141db
message: avahi "Due to Cygwin limitations, this port of Avahi has been patched
to rely on a native Windows version of Bonjour's mDNSResponder service.
If you do not already have the 'Bonjour Service' installed (it comes with
iTunes and Safari, among others), then you can download it at
http://support.apple.com/kb/DL999"
