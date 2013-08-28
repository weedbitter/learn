package ZT::DBM;  
use strict;
use warnings;
use Carp;
use DBI;
use ZT::DBM::Constant;
use IO::File;
use constant {
    DEBUG =>  $ENV{ZTOOLS_DEBUG} || 0,
};


BEGIN {
    require Data::Dump if DEBUG;
}

#
# des
#    构造对象
# req
# res
#
sub new {
    my $self = bless {}, shift; 
    # dbh
    my $dbh       = DBI->connect(
        "dbi:DB2:$ENV{DB_NAME}",
        $ENV{DB_USER},
        $ENV{DB_PASS},
        {
            RaiseError          => 1,
            PrintError          => 0,
            AutoCommit          => 0,
            FetchHashKeyName    => 'NAME_lc',
            ChopBlanks          => 1,
            InactiveDestroy     => 1,
        }
    );
    $dbh->do("set current schema $ENV{DB_SCHEMA}");
    unless ($dbh) {
        confess "can not connect db[$ENV{DB_NAME}, $ENV{DB_USER}, $ENV{DB_PASS}]"; 
    }
    $self->{dbh} = $dbh;
    # 初始化
    $self->_init();

    return $self;
}

#
# des
#    生成add_mqt的脚本文件
# req
# res
#
sub add_mqt {
    my $self = shift;

    my $books = $self->{meta}[DICT][DICT_BOOK];
    my $ret   = 0;
    eval {
        for my $bid (keys %$books) {
            my $book = $books->{$bid}->{value};
            if ( $self->_add_mqt($book) ) {
                $ret = 1;
            }
        }
        $self->{dbh}->commit();
    };
    if ($@) {
        $ret = 0;
    }
    

    return $ret;
}

#
# des
#    生成del_mqt的脚本文件
# req
# res
#
sub del_mqt {
    my $self = shift;

    my $books = $self->{meta}[DICT][DICT_BOOK];
    my $ret   = 0;
    eval {
        for my $bid (keys %$books) {
            my $book = $books->{$bid}->{value};
            if ( $self->_del_mqt($book) ) {
                $ret = 1;
            }
        }
        $self->{dbh}->commit();
    };
    if ($@) {
        $ret = 0;
    }

    return $ret;
}

#
# 初始化
#
sub _init {
    my $self = shift;

    $self->_meta_dict();
    $self->_meta_book();

    return $self;
}

#
# 给book表加mqt表(sum_xxxx) 
#
sub _add_mqt {
    my $self = shift;
    my $book = shift;

    my @dim     = @{$self->{meta}[BOOK]{$book}[BOOK_FLIST]};
    my $dim_fld = join ",\n        ", map { "$_ as $_" } @dim;
    my $dim_grp = join ', ', @dim;

    my $sql_mqt    =<<EOF;
-- sum_$book
alter table sum_$book add materialized query (
    select 
        $dim_fld, 
        sum(j) as j, 
        sum(d) as d, 
        count(*) as cnt 
    from 
        book_$book 
    group by 
        $dim_grp
) data initially deferred refresh immediate;
EOF

    $self->{dbh}->do($sql_mqt);
    $self->{dbh}->do("set integrity for sum_$book materialized query immediate unchecked");


    return 1;
} 

#
# book表解除mqt绑定 
#
sub _del_mqt {
    my $self = shift;
    my $book = shift;

    my $sql_mqt   = <<EOF;
-- sum_$book
alter table sum_$book drop materialized query;
EOF

    $self->{dbh}->do($sql_mqt);

    return $sql_mqt;
}

#
# 获取字典的元数据
#
sub _meta_dict {
    my $self = shift;
    # dict_book
    my %book;
    my $sth = $self->{dbh}->prepare(qq/select * from dict_book/) or return;
    $sth->execute();
    while (my $row = $sth->fetchrow_hashref()) {
        $book{$row->{id}}    = $row;
    }   
    $sth->finish();

    my @meta_dict;
    $meta_dict[DICT_BOOK] = \%book;

    $self->{meta}[DICT] = \@meta_dict;
    #Data::Dump->dump($self->{meta}[DICT]);
    return $self;
}



#
# book 元数据加载
#
sub _meta_book {
    my $self = shift;

    # 找出所有book, 生产所有book清理句柄
    my $books = $self->{dbh}->selectall_arrayref(qq/select id, value from dict_book/);

    # 账簿元数据
    my %meta_book;
    for my $row (@$books) {
        my $name = $row->[1];
        my $sth_nhash = $self->{dbh}->prepare("select * from book_$name") or return;
        $sth_nhash->finish();
        my $nhash = $sth_nhash->{NAME_lc_hash};

        my %nhash = %{$nhash};
        delete @nhash{qw/id j d ys_type ys_id jzpz_id ts_c/};
        my $dim = [sort { lc $a cmp lc $b  } keys %nhash ];    

        $meta_book{$name}[BOOK_FLIST] = $dim;
    }

    $self->{meta}[BOOK] =  \%meta_book;
    #Data::Dump->dump($self->{meta}[BOOK]);
    return $self;
}

1
