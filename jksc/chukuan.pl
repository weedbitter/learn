#!/usr/bin/perl
use strict;
use warnings;
use Net::FTP;
use IO::File;
use Zeta::Log;
use DataTime;
use File::Path qw/mkpath/;

my $down_u;
my $down_p;
my $up_u;
my $up_p;

my @files = qw/
    二代-工行
    二代-工行
    二代-工行
    二代-工行
    二代-工行
/;

my %proc = (
    工行二代  => sub {
    },
    工行二代  => sub {
    },
    工行二代  => sub {
    },
    工行二代  => sub {
    },
);


my $dfile;


# $ENV{CKPRE_HOME};

# 昨日
my $date;

# 日志
my $log = Zeta::Log->new(
    logurl => "file://$ENV{CKPRE_HOME}/log/ckpre-$date.log",
    loglevel => 'DEBUG',
);


# 目标文件
$dfile = "ck-0019.dat";
my $df = IO::File->new(">$dfile");

# 1. 下载文件 放到$ENV{CKPRE_HOME}/data/$date/工行二代.$date.csv
mkpath("$ENV{CKPRE_HOME}/data/$date", 0711);
$log->debug("开始下载文件...");
$ftp = Net::FTP->new($ftp_host, Debug => 0) or die "Cannot connect to some.host.name: $@";
$ftp->login($down_u, $down_p) or die "Cannot login ", $ftp->message;
ftp->cwd("/data/$date") or die "Cannot change working directory ", $ftp->message;
for (@files) {
    my $fname = "$_-$date.csv";
    $log->debug("开始下载文件$fname...");
    $ftp->get($fname, "$ENV{CKPRE_HOME}/data/$date/$fname") or die "get failed ", $ftp->message;
}
$ftp->quit;
$log->debug("文件下载完成!!!");

for (@files) {
    my $file = $_ . "$date.csv";
    $log->debug("开始处理文件$file...");

    my $fh = IO::File->new("<$file");
    my $type;
    while(<$fh>) {
        s/^\s+//g;
        s/\s+$//g;
        next if /^$/;
        my $r = $proc{$type}->($_);
        $df->print(join '|', @r);
    }
    $fh->close();
}
$df->close();

#
# 上传ck-0019.dat文件
#
$log->debug("开始上传文件...");
my $dftp - Net::FTP->new();


