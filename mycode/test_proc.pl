#!/usr/bin/perl

# test_proc.pl
# test multi process
# create by weed :2013-10-17

use strict;
use warnings;

sub test {
    warn "hello";
}

## == fork a new process ==
my $static = "cn";
my $pid = fork();
if ( $pid == 0 ) {

    print "parent  pid: $$\n  static: $static\n";
    exit 0;
}
elsif ( $pid > 0 ) {

    ## == child proc ==
    print "Child: My pid = $$\n; static: $static\n";
    &test();
    sleep(5);
}
else {
    print "error \n";
}

exit 0;
