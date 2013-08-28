#!/usr/bin/perl
use strict;
use warnings;
use ZT::DBM;
use Getopt::Long;
use constant {
    DEBUG =>  $ENV{ZTOOLS_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

my $type;
my $rtn = GetOptions(
    "type|t=s"    => \$type,
) or &usage;

unless ($type) {
    &usage;
}


my $dbm = ZT::DBM->new();
my $ret;

if ($type =~ /add_mqt/) {
    $ret = $dbm->add_mqt();
}
elsif ($type =~ /del_mqt/) {
    $ret = $dbm->del_mqt();
}

if ($ret) {
    exit 0;
}
else {
    exit 1;
}


# help & prompt
sub usage {
    print <<EOF;
    DBM.pl -t add_mqt
    DBM.pl -t del_mqt
EOF
    exit 1;
}
