package ZT::DBM::Constant;
use strict;
use warnings;

# 元信息类别位置
sub BOOK            () { 0 };
sub DICT            () { 1 };


# 科目元信息位置
sub BOOK_FLIST      () { 0 };

# 字典元信息位置
sub DICT_BOOK       () { 1 };


sub import {
    my $caller = caller();
    no strict 'refs';    
    *{ $caller . "::BOOK"        }     =  \&BOOK;
    *{ $caller . "::DICT"        }     =  \&DICT;

    *{ $caller . "::DICT_BOOK"   }     =  \&DICT_BOOK;

    *{ $caller . "::BOOK_FLIST"  }     =  \&BOOK_FLIST;
}


1
