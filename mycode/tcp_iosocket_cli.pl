#!/usr/bin/perl -w
# tcp_iosocket_cli.pl
use strict;
use JSON;
use IO::Socket;

my $addr = $ARGV[0] || '127.0.0.1';
my $port = $ARGV[1] || '5000';
my $buf = undef;

my $sock = IO::Socket::INET->new(
    PeerAddr => $addr,
    PeerPort => $port,
    Proto    => 'tcp',
    Timeout  => 300)
    or die "Can't connect: $!\n";

$sock->autoflush(1);  
print $sock "calc_check,31,CBHB_NET_B2C_BHPX1010  ,100000,2013-01-05,2013-01-05,I*", "\n";

$buf = <$sock>;
my $bs = length($buf);
print "Received $bs bytes, content $buf \n"; # actually get $bs bytes
close $sock;
