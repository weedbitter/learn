#!/usr/bin/perl

my $ps = `ps -ef | grep db2 | awk '{ print \$8 }'`;

print $ps;
use Data::Dump;
Data::Dump->dump($ps);
