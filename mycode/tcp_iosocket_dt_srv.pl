#!/usr/bin/perl
# tcp_iosocket_dt_srv.pl
use strict;
use IO::Socket;
use POSIX qw(WNOHANG);

$SIG = sub {
    while((my $pid = waitpid(-1, WNOHANG)) >0) {
        print "Reaped child $pid\n";
    }
};

my $port     = $ARGV[0] || '3000';
my $buf = undef;
my $sock = IO::Socket::INET->new( Listen    => 20,
    LocalPort => $port,
    Timeout   => 60*1,
    Reuse     => 1)
    or die "Can't create listening socket: $!\n";

warn "Starting server on port $port...\n";
while (1) {
    next unless my $session = $sock->accept;
    defined (my $pid = fork) or die "Can't fork: $!\n";

    if($pid == 0) {
        my $peer = gethostbyaddr($session->peeraddr,AF_INET) || $session->peerhost;
        my $port = $session->peerport;
        warn "Connection from [$peer,$port]\n";
        $session->autoflush(1);
        $buf = <$session>;
        my $bs = length($buf);
        print "Received $bs bytes, content $buf\n"; # actually get $bs bytes
        print $session (my $s = localtime), "\n";
        warn "Connection from [$peer,$port] finished\n";
        close $session;
        exit 0;
    }else {
        print "Forking child $pid\n";
    }
}
close $sock;
