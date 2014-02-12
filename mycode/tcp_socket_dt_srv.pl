#!/usr/bin/perl -w
# tcp_socket_dt_srv.pl
use strict;
use Socket;
use IO::Handle;
use POSIX qw(WNOHANG);

my $port = $ARGV[0] || '3000';
my $proto = getprotobyname('tcp');
my $buf = undef;

$SIG{'CHLD'} = sub {
    while ( ( my $pid = waitpid( -1, WNOHANG ) ) > 0 ) {
        print "Reaped child $pid\n";
    }
};

socket( SOCK, AF_INET, SOCK_STREAM, getprotobyname('tcp') )
  or die "socket() failed: $!";
setsockopt( SOCK, SOL_SOCKET, SO_REUSEADDR, 1 )
  or die "Can't set SO_REUSADDR: $!";

my $my_addr = sockaddr_in( $port, INADDR_ANY );
bind( SOCK, $my_addr ) or die "bind() failed: $!";
listen( SOCK, SOMAXCONN ) or die "listen() failed: $!";

warn "Starting server on port $port...\n";

while (1) {
    next unless my $remote_addr = accept( SESSION, SOCK );
    defined( my $pid = fork ) or die "Can't fork: $!\n";

    if ( $pid == 0 ) {
        my ( $port, $hisaddr ) = sockaddr_in($remote_addr);
        warn "Connection from [", inet_ntoa($hisaddr), ",$port]\n";
        SESSION->autoflush(1);
        my $bs = sysread(SOCK, $buf, 2048); # try to read 2048
        print "Received $bs bytes, content $buf\n"; # actually get $bs bytes
        print SESSION ( my $s = localtime );
        warn "Connection from [", inet_ntoa($hisaddr), ",$port] finished\n";
        close SESSION;
        exit 0;
    }
    else {
        print "Forking child $pid\n";
    }
}

close SOCK;
