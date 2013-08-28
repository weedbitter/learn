

-- ##################
-- ##################
-- ##################
-- ##################
-- ##################




--
-- 备付金存款       =>  银行存款-备付金存款
--
drop   view book_deposit_bfj;
create view book_deposit_bfj as 
	select 9                               as bfj_acct,
           to_char(rec_c_ts, 'YYYY-MM-DD') as period,
           sum(j_amt)                      as j,
           sum(d_amt)                      as d,
           -1                              as ys_type,
           -1                              as ys_id,
           -1                              as jzpz_id
    from tbl_book_bfj_deposit
    group by 9, to_char(rec_c_ts, 'YYYY-MM-DD');



--
-- 应收客户分润     =>  应收账款-客户-分润方承担品牌费
--
drop   view book_lfee_psp;
create view book_lfee_psp as
    select  concat('41.', c)  as c,
            concat('5_',  c)  as cust_proto,
            period            as period,
            tx_date           as tx_date,
            sum(j_amt)        as j,
            sum(d_amt)        as d,
            -1                as ys_type,
            -1                as ys_id,
            -1                as jzpz_id
    from (
        select  (
                case c_id
                    when 2    then '49914410'
                    when 92   then '49914412'
                    when 1005 then '49914408'
                end
            )                                          as c,
            date(timestamp(concat(tx_date, '000000'))) as period,
            date(timestamp(concat(tx_date, '000000'))) as tx_date,
            j_amt,
            d_amt
        from tbl_book_ys_c_ps
    )
    group by concat('41.', c), concat('5_',  c), period, tx_date;


--
-- 银行短款     => 应收账款-银行-备付金银行短款
--
drop   view book_bsc;
create view book_bsc as
    select bfj_acct     as bfj_acct,
           e_date       as e_date,
           period       as period,
           zjbd_type    as zjbd_type,
           sum(j_amt)   as j,
           sum(d_amt)   as d,
           -1           as ys_type,
           -1           as ys_id,
           -1           as jzpz_id
    from (
        select 9                                            as bfj_acct,
               date(timestamp(concat(error_date,'000000'))) as e_date,
               date(timestamp(concat(error_date,'000000'))) as period,
               11                                           as zjbd_type,
               j_amt                                        as j_amt,
               d_amt                                        as d_amt
        from tbl_book_bank_sc
    ) as t
    group by bfj_acct, e_date, period, zjbd_type;
    

--
-- 银行长款     =>  应付账款-银行-备份金银行长款
--
drop   view book_blc;
create view book_blc as
    select bfj_acct     as bfj_acct,
           e_date       as e_date,
           period       as period,
           zjbd_type    as zjbd_type,
           sum(j_amt)   as j,
           sum(d_amt)   as d,
           -1           as ys_type,
           -1           as ys_id,
           -1           as jzpz_id
    from (
        select 9                                            as bfj_acct,
               date(timestamp(concat(error_date,'000000'))) as e_date,
               date(timestamp(concat(error_date,'000000'))) as period,
               11                                           as zjbd_type,
               j_amt                                        as j_amt,
               d_amt                                        as d_amt
        from tbl_book_bank_lc
    ) as t
    group by bfj_acct, e_date, period, zjbd_type;


--
-- 客户托收备付金   =>  客户备付金-备付金
--
drop   view book_bfj_cust;
create view book_bfj_cust as
    select c          as c,
           period     as period,
           sum(j_amt) as j,
           sum(d_amt) as d,
           -1         as ys_type,
           -1         as ys_id,
           -1         as jzpz_id
    from (
        select  (
            case c_id
                when 2    then '41.49914410'
                when 92   then '41.49914412'
                when 1005 then '41.49914408'
                when 0    then '-41'
                else (select concat('41.', mid) from tbl_cust_prod_undpos where tbl_book_bfj_cts.c_id = id)
            end
            )                                         as c,
            date(timestamp(concat(tx_date,'000000'))) as period,
            j_amt                                     as j_amt,
            d_amt                                     as d_amt
        from tbl_book_bfj_cts
    ) group by c, period;


--
-- 应付客户分润     =>  应收账款-客户-分润方承担品牌费
--
drop   view book_lfee_psp_1;
create view book_lfee_psp_1 as
        select  concat('41.', c)  as c,
                concat('5_',  c)  as cust_proto,
                period            as period,
                tx_date           as tx_date,
                sum(j_amt)        as j,
                sum(d_amt)        as d,
                -1                as ys_type,
                -1                as ys_id,
                -1                as jzpz_id
        from (
            select  (
                case c_id
                     when 2    then '49914410'
                     when 92   then '49914412'
                     when 1005 then '49914408'
                end
                )                                          as c,
                date(timestamp(concat(tx_date, '000000'))) as period,
                date(timestamp(concat(tx_date, '000000'))) as tx_date,
                j_amt,
                d_amt
            from tbl_book_yf_c_ps
        )
        group by concat('41.', c), concat('5_',  c), period, tx_date; 


--
-- 未结客户款       =>  客户备付金-备付金
--
drop   view book_bfj_cust_1;
create view book_bfj_cust_1 as
    select c          as c,
           period     as period,
           sum(j_amt) as j,
           sum(d_amt) as d,
           -1         as ys_type,
           -1         as ys_id,
           -1         as jzpz_id
    from (
        select  (
            case c_id
                when 2    then '41.49914410'
                when 92   then '41.49914412'
                when 1005 then '41.49914408'
                when 0    then '-41'
                else (select concat('41.', mid) from tbl_cust_prod_undpos where tbl_book_wj.c_id = id)
            end
                )                               as c,
                to_char(rec_c_ts, 'YYYY-MM-DD') as period,
                j_amt                           as j_amt,
                d_amt                           as d_amt
        from tbl_book_wj
    ) group by c, period;


--
-- 收入     =>  收入-客户手续费收入
--
drop   view book_income_cfee;
create view book_income_cfee as
    select c          as c,
       p          as p,
       period     as period,
       sum(j_amt) as j,
       sum(d_amt) as d,
       -1         as ys_type,
       -1         as ys_id,
       -1         as jzpz_id
    from (
        select  (
                case c_id
                    when 2    then '41.49914410'
                    when 92   then '41.49914412'
                    when 1005 then '41.49914408'
                    when 0    then '-41'
                    else (select concat('41.', mid) from tbl_cust_prod_undpos where tbl_book_income.c_id = id)
                end
                )                                               as c,
                5                                               as p,
                (
                    case 
                        when confirm_date is null then to_char(rec_c_ts, 'YYYY-MM-DD')
                        else date(timestamp(concat(confirm_date, '000000')))
                    end
                )                               as period,
                j_amt                           as j_amt,
                d_amt                           as d_amt
        from tbl_book_income
    ) group by c, p, period;



--
-- 成本     =>  成本-银行手续费支出
--
drop   view book_cost_bfee;
create view book_cost_bfee as
    select bi         as bi,
           c          as c,
           p          as p,
           period     as period,
           sum(j_amt) as j,
           sum(d_amt) as d,
           -1         as ys_type,
           -1         as ys_id,
           -1         as jzpz_id
    from (
        select  11                                              as bi,
                (
                case c_id
                    when 2    then '41.49914410'
                    when 92   then '41.49914412'
                    when 1005 then '41.49914408'
                    when 0    then '-41'
                    else (select concat('41.', mid) from tbl_cust_prod_undpos where tbl_book_cost.c_id = id)
                end
                )                                               as c,
                5                                               as p,
                (
                    case 
                        when confirm_date is null then to_char(rec_c_ts, 'YYYY-MM-DD')
                        else date(timestamp(concat(confirm_date, '000000')))
                    end
                )                               as period,
                j_amt                           as j_amt,
                d_amt                           as d_amt
        from tbl_book_cost
    ) group by bi, c, p, period;
