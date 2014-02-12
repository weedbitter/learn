#!/usr/bin/perl
# test_proc.pl
# test multi process

use strict;
use warnings;

## == fork a new process ==
my $pid = fork();

if ( !defined($pid) ) {
    print "Error in fork: $!";
    exit 1;
}

if ( $pid == 0 ) {

    ## == child proc ==
    print "Child: My pid = $$\n";
    sleep(5);
    print "Child: end\n";
    exit 0;
}
else {

    ## == parent proc ==
    print "Parent My pid = $$, and my child's pid = $pid\n";
    sleep(5);
    print "Parent: end\n";
}

exit 0;
