#!/usr/bin/perl
use strict;
use warnings;
use Carp;
use DBI;
use Spreadsheet::WriteExcel;
use File::Path qw/mkpath/;
use IO::File;
use constant {
    DEBUG =>    $ENV{ZTOOLS_DEBUG} || 0,
    BOOK  =>    0,
    OBOOK =>    1,
    YSPZ  =>    2,

    SEL   =>    0,
    SEQ   =>    1,
    INS   =>    2,
    FLIST =>    3,

    YSPZ_INS => 0,
    
};

BEGIN {
    require Data::Dump if DEBUG;
}

my $ret = &trans;
unless ($ret) {
    warn "#### 系统迁移失败";
}
else {
    warn "#### 系统迁移成功";
}

sub trans {
    my $books = {
        deposit_bfj         => ['book_deposit_bfj'],
        lfee_psp            => ['book_lfee_psp', 'book_lfee_psp_1'],
        bsc                 => ['book_bsc'],
        blc                 => ['book_blc'],
        bfj_cust            => ['book_bfj_cust', 'book_bfj_cust_1'],
        income_cfee         => ['book_income_cfee'],
        cost_bfee           => ['book_cost_bfee'],
    };

    &_trans($books);
}

sub _trans {
    my $books  = shift;

    my $dbh    = &_dbh; 
    my $odbh   = &_odbh;
    
    my $sths =  &_setup($dbh, $odbh, $books);
    # 创建workbook
    my $dir = "$ENV{ZTOOLS_HOME}/tmp/hisbook"; 
    mkpath($dir);
    my $file = "$dir/book.xls";
    my $workbook = Spreadsheet::WriteExcel->new("$file");
    #
    for my $book (keys $sths) {
        # 为每一个科目添加一个sheet
        my $worksheet = $workbook->add_worksheet($book);
        my $row = 0;
        my $col = 0;
        $worksheet->write($row,    $col,  'id');
        ++$col;
        for my $field (@{$sths->{$book}[BOOK][FLIST]}) {
            $worksheet->write($row,    $col,  $field);
            ++$col;
        }
        ++$row;
        #
        my $count = 0;
        for my $osth_sel (@{$sths->{$book}[OBOOK]}) {
            $osth_sel->execute();
            while( my $rd = $osth_sel->fetchrow_hashref() ) {
                $sths->{$book}[BOOK][SEQ]->execute();
                my ($id) = $sths->{$book}[BOOK][SEQ]->fetchrow_array();
                $sths->{$book}[BOOK][SEQ]->finish();
                my @r = @{$rd}{@{$sths->{$book}[BOOK][FLIST]}};
                
                $sths->{$book}[BOOK][INS]->execute(($id, @r)); 

                # 每读一行，向worksheet写一行
                $col = 0;
                $worksheet->write($row,    $col,  "$id"); 
                ##warn "$row $col $id";
                ++$col;
                for my $ro (@r) {
                    $worksheet->write($row,    $col,  "$ro");
                    ##warn "$row $col $ro";
                    ++$col;
                }
                ++$row;
            }
            $osth_sel->finish();
        }
    }
    $workbook->close();
    # 插入原始凭证
    my $yspz_seq = "values nextval for seq_yspz_init";
    my $yspz_ins = "insert into yspz_init(id, status, content, flag, ts_c) values(?, ?, ?, ?, default)";
    my $sth_seq  = $dbh->prepare($yspz_seq);
    my $sth_ins  = $dbh->prepare($yspz_ins);

    $sth_seq->execute();
    my ($ys_id)  = $sth_seq->fetchrow_array();
    $sth_seq->finish();

    $sth_ins->bind_param(1, $ys_id);
    $sth_ins->bind_param(2, '1');
    warn "$file";
    $sth_ins->bind_param(3, $file, {db2_file => 1});
    $sth_ins->bind_param(4, 0);
    my $rows_affected = $sth_ins->execute();
    $sth_ins->finish();
    
    
    # 一起提交
    $dbh->commit();

    return 1;
}


sub _setup {
    my $dbh   = shift;
    my $odbh  = shift;
    my $books = shift;

    my %sths;

    for my $book (keys %$books) {
        my $obooks  = $books->{$book};

        my $sel     = "select * from book_$book"; 
        my $seq     = "values nextval for seq_$book";
        my $ins;

        # 老
        my @obs;
        for my $obook (@$obooks) {
            my $osel = "select * from $obook";
            my $osth = $odbh->prepare($osel);
            push @obs, $osth; 
        }
        $sths{$book}[OBOOK] = \@obs;

        # 新
        $sths{$book}[BOOK][SEL] = $dbh->prepare($sel);
        $sths{$book}[BOOK][SEQ] = $dbh->prepare($seq);
        my $nhash = $sths{$book}[BOOK][SEL]->{NAME_lc_hash};
        my %nhash = %{$nhash};
        delete @nhash{qw/id ts_c/};
        my $hsh   = {reverse %nhash};
        my @flist = map{$hsh->{$_}} sort { lc $a cmp lc $b  } keys %$hsh;
        $sths{$book}[BOOK][FLIST] = \@flist;

        my $fstrs = join ', ', @flist;
        my $mark  = join ', ', ('?') x (@flist);
        $ins = "insert into book_$book(id, $fstrs, ts_c) values(?, $mark, default)";
        
        $sths{$book}[BOOK][INS] = $dbh->prepare($ins);
    }


    return \%sths;
}

#
# 老账务系统的连接
#
sub _odbh {
    my $dbh = DBI->connect(
        "dbi:DB2:$ENV{ODB_NAME}",
        $ENV{ODB_USER},
        $ENV{ODB_PASS},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
            InactiveDestroy  => 1,
        }
    ); 
    $dbh->do("set current schema $ENV{ODB_SCHEMA}");
    unless($dbh) {
        die "can not connect db[$ENV{ODB_NAME} $ENV{ODB_USER} $ENV{ODB_PASS}]";
    }

    return $dbh;
}

#
# 现有账务系统的连接
#
sub _dbh {
    my $dbh = DBI->connect(
        "dbi:DB2:$ENV{DB_NAME}",
        $ENV{DB_USER},
        $ENV{DB_PASS},
        {
            RaiseError       => 1,
            PrintError       => 0,
            AutoCommit       => 0,
            FetchHashKeyName => 'NAME_lc',
            ChopBlanks       => 1,
            InactiveDestroy  => 1,
        }
    );
    $dbh->do("set current schema $ENV{DB_SCHEMA}");
    unless($dbh) {
        die "can not connect db[$ENV{DB_NAME} $ENV{DB_USER} $ENV{DB_PASS}]";
    }

    return $dbh;
}
