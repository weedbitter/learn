#/usr/bin/perl
use strict;
use warnings;
use ZT::DBM;
use constant {
    DEBUG =>  $ENV{ZTOOLS_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}


my $dbm = ZT::DBM->new();
my $date = "20130527";
my $ret = $dbm->add_mqt_script($date);
warn "#### ret: $ret";
$ret = $dbm->del_mqt_script($date);
warn "#### ret: $ret";



1
