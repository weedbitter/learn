#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Getopt::Long;
use constant {
    DEBUG => 1,
};

BEGIN {
    require Data::Dump if DEBUG;
}

my $batch;
my $ys_type;
my $rtn = GetOptions(
    "ys|y=s"    => \$ys_type,
    "batch|b=s" => \$batch
) or die &usage;

unless ($batch) {
    die &_usage;
}

unless ($ys_type) {
    die &_usage;
}


sub _dbh {
    my $dbh = DBI->connect(
        "DBI:DB2:$ENV{DB_NAME}",
        $ENV{DB_USER},
        $ENV{DB_PASS},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
        }
    ) or die "can not connect db $ENV{DB_NAME}";
    $dbh->do("set current schema $ENV{DB_SCHEMA}") or die "can not set schema $ENV{DB_SCHEMA}";

    return $dbh;
}

sub _cls_yspz {
    my $dbh         = shift;
    my $ys_type     = shift;
    my $batch       = shift;
    my %dict_book;
    my $sth_dict = $dbh->prepare("select * from dict_book");
    $sth_dict->execute();
    while ( my $row = $sth_dict->fetchrow_hashref() ) {
        $dict_book{delete $row->{id}} = $row;
    }
    
    my $sth         = $dbh->prepare("select * from jzpz where ys_type = ?"); 
    my $sth_yspz    = $dbh->prepare("delete from yspz_$ys_type where id = ? and period = ?");
    my $sth_jzpz    = $dbh->prepare("delete from jzpz where id = ? and period = ?"); 
    $sth->execute($ys_type);
    my $ys_id;
    my $line = 0;
    while ( my $row = $sth->fetchrow_hashref() ) {
        if ($ys_id) {
            if ($ys_id ne $row->{ys_id}) {
                if ($line == $batch) {
                    $dbh->commit;
                    $line = 0;
                }
                $ys_id = $row->{ys_id};
                $sth_yspz->execute($ys_id, $row->{period});
                ++$line;
            }
        }
        else {
            $ys_id = $row->{ys_id};
            $sth_yspz->execute($ys_id, $row->{period});
            ++$line;
        }
        &_cls_book($dbh, $dict_book{$row->{jb_id}}->{value}, $row->{j_id}, $row->{period});
        &_cls_book($dbh ,$dict_book{$row->{db_id}}->{value}, $row->{d_id}, $row->{period});
        $sth_jzpz->execute($row->{id}, $row->{period}); 
    }
    if ($line > 0)  {
        $dbh->commit;
    }
}


sub _cls_book {
    my $dbh         = shift;
    my $book        = shift;

    my $sth_book    = $dbh->prepare("delete from book_$book where id = ? and period = ?");
    $sth_book->execute(@_);
}

sub _usage {
    "./clrYspz.pl -y 0001 -b 500";
}




my $dbh = &_dbh();
&_cls_yspz($dbh, $ys_type, $batch);

__DATA__
