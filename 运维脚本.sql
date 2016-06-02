ePQC相关：

select * from epqc_t_pos_data_message where del_flag = 'N' ORDER BY business_date desc;

select * from epqc_t_fcst_forecast_batch_info where del_flag = 'N' and execute_forecast_date = '2015-04-09';

--如果要重出某一天的预估，可以执行这个删除语句
delete from epqc_t_fcst_product_forecast_sr where del_flag = 'N' and forecast_code like '%20150409%';

--查询每天预估的进度，一般是14天左右
select DISTINCT forecast_date from epqc_t_fcst_product_forecast_sr where del_flag = 'N' and forecast_code like '%20150409%' ORDER BY forecast_date desc;

--查询每天的预估计划任务的sql：
SELECT * FROM epqc_t_fcst_forecast_batch_info where forecast_code like '%20150428';

--从threeday中查找热豆浆的售卖
SELECT * from v_pos_product_three_day where product_code = '540074';

--zabbix dashboard:
http://172.31.79.150:8080/zabbix/screenedit.php?form=update&screenid=28

POS相关：
查询SOD操作时间：select max(event_time) from pos_t_event_header where event_type_code='sod';

查询pos里面未结单的单据
select * from pos_t_sales_header_reduction where new_flag='1' 
and sale_type='stored' and sale_terminal_id='9' ;

--查询pos导入时间和实际开单时间的差异
select sale_time,create_time,age(create_time,sale_time) as age from pos_t_sales_header_reduction where business_date='2015-06-03' 
ORDER BY age desc;

-fcst weekly & monthly
select * from fcst_t_task_exe_history where task_no = '09' ORDER BY update_time desc; --weekly fcst
select * from fcst_t_task_exe_history where task_no = '10' ORDER BY update_time desc; --monthly fcst


FUND相关
--查询死在容器里的计划任务：
select s.sch_name,t.* from fnd_t_sch_log t INNER JOIN fnd_t_sch_schedule s on t.task_id=s.guid
where t.log_type = '00004' and t.create_time 'yyyy-mm-dd 00:00:00'

--查询每天epqc的预估计划任务的运行时间
select age(update_time, create_time),create_time,execute_resutl from fnd_t_sch_log where task_id='8e5f4701-8d1b-43d3-9bb1-fd490ded0a99' 
and create_time>='2015-05-11 00:00:00' and log_type='00001' and schedule_action='00007' 
ORDER BY create_time desc;

--查询每天epqc的预估计划任务的运行时间
select age(update_time, create_time),create_time,execute_resutl from fnd_t_sch_log where task_id='8e5f4701-8d1b-43d3-9bb1-fd490ded0a99' 
and create_time>='2015-05-11 00:00:00' and log_type='00001' and schedule_action='00007' 
ORDER BY create_time desc;

--查询平均执行时间
select avg(a.age) from (
select age(update_time, create_time),create_time,execute_resutl 
from fnd_t_sch_log where task_id='515021b9-dd95-406f-ac55-f68e5b46b64f' 
and create_time>='2015-07-17 00:00:00' and create_time<='2015-07-17 23:59:59' 
and log_type='00001' and schedule_action='00007' 
ORDER BY create_time desc
) as a

--查看性能的dashboard：
http://172.31.79.150:8080/zabbix/screenedit.php?form=update&screenid=28

ePQC看预估是否完成：
--sale DATE in talbe name
select * from epqc_t_pos_data_message ORDER BY business_date desc limit 16; --080

-- history pos sale DATA
SELECT DISTINCT business_date from v_pos_product_all ORDER BY business_date desc;

-- epqc pos data EACH TABLE
SELECT DISTINCT sale_date, product_code, product_name, tc_business_type_code,
  tc_business_status_code, create_time
from epqc_t_pos_product_actual_sale_080
where tc_business_type_code in('1','2','3','4','5','6')
ORDER BY product_code, product_name, tc_business_type_code;

-- epqc forecast sr result info
SELECT * from epqc_t_fcst_forecast_batch_info ORDER BY forecast_code desc LIMIT 1;

SELECT * from acp_t_fcst_bt where templet_code ='485' ORDER BY pos_fcst_bt_code;

SELECT * from epqc_t_mpc_basic_info where plan_code like '%20150423%' and del_flag = 'N';
--update epqc_t_mpc_basic_info set del_flag = 'Y', update_id = 'hand modify' WHERE plan_code like '%20150423%' and del_flag = 'N';

--拆分物料
epqc/epqc/ePQC_S000000Action_Init.action

--手工转换的地址：
epqc/epqc/ePQC_PARSEDATA_TEST_Init.action

运维相关
--恢复数据库
psql -h localhost -c -U {0} -d {1} < {2}/{1}/{1}.bak

CPU耗时TOP 10
select t1.datname, t2.query, t2.calls, t2.total_time, t2.total_time/t2.calls from pg_database t1, pg_stat_statements t2 where t1.oid=t2.dbid order by t2.total_time desc limit 10;
 
调用次数TOP 10
select t1.datname, t2.query, t2.calls, t2.total_time, t2.total_time/t2.calls from pg_database t1, pg_stat_statements t2 where t1.oid=t2.dbid order by t2.calls desc limit 10;
 
单次耗时TOP 10
select t1.datname, t2.query, t2.calls, t2.total_time, t2.total_time/t2.calls from pg_database t1, pg_stat_statements t2 where t1.oid=t2.dbid order by t2.total_time/t2.calls desc limit 10;

--pg_top
pg_top -d BOH2G_STORE_WORK -U postgres -W

--执行脚本耗时
SELECT
         procpid as 进程ID,
         START as 开始时间,
         now() - START AS 消耗时间,
         current_query as 执行语句
FROM
         (
                   SELECT
                            backendid,
                            pg_stat_get_backend_pid (s.backendid) AS procpid,
                            pg_stat_get_backend_activity_start (s.backendid) AS START,
                            pg_stat_get_backend_activity (s.backendid) AS current_query
                   FROM
                            (
                                     SELECT
                                               pg_stat_get_backend_idset () AS backendid
                            ) AS s
         ) AS s
WHERE
         current_query <> '<IDLE>'  ORDER BY  消耗时间 DESC;
     
--更加靠谱的查询sql进程的语句
SELECT pid, query,
date_part('day', interval_value) as day_value,
date_part('day', interval_value) * 24 * 60 * 60 
+ date_part('minute', interval_value) * 60
+ date_part('second', interval_value) as seconds
from (
select pid, query,(current_timestamp -query_start) as interval_value
from pg_stat_activity
where datname='BOH2G_STORE_WORK' 
and state='active'
) tab order by seconds desc


--查找sql server的执行sql语句
select A.spid,A.[Database],A.status,A.wait,A.[SQL],A.[PSQL],A.program,A.hostname,A.start_time,DATEDIFF(SECOND, A.start_time, GETDATE()) as duration from (
SELECT     [Spid] = session_Id, ecid, [Database] = DB_NAME(sp.dbid),

 [User] = nt_username, [Status] = er.status, 
 [Wait] = wait_type, 
 [SQL] = SUBSTRING(qt.text, er.statement_start_offset / 2, (CASE WHEN er.statement_end_offset = - 1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) 
                      * 2 ELSE er.statement_end_offset END - er.statement_start_offset) / 2),
                       [PSQL] = qt.text, 
                       Program = program_name, Hostname, 
                       nt_domain, start_time
FROM    
     sys.dm_exec_requests er INNER JOIN  sys.sysprocesses sp ON er.session_id = sp.spid 
     CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt 
     WHERE     
     session_Id > 50 /* Ignore system spids.*/ 
     AND session_Id NOT IN (@@SPID)
   --and DB_NAME(sp.dbid) = 'BOH2G_RSC_WORK_BOH'
) A
GROUP BY A.spid,A.[Database],A.status,A.wait,A.[SQL],A.[PSQL],A.program,A.hostname,A.start_time
ORDER BY start_time desc;
     
     
--terminate the postgresql process by processid
 select  pg_terminate_backend(‘进程ID’)
 
 --search the materal inv from 1G
 select * from epqc_t_inv_materal_theory_inv;
 
 --kill the process by cmd
 taskkill /im BOH2G_Agent.EXE /f
 
 --filter the process by name in cmd
 tasklist |findstr 


select * from epqc_t_mpc_basic_info where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_plan_part_relation  where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--MPC计划
select * from epqc_t_mpc_fried_plan where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_fried_plan_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--鸡类解冻计划
select * from epqc_t_mpc_chicken_thaw_plan_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_chicken_thaw_plan_batch where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_chicken_thaw_task_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--半成品制备计划
select * from epqc_t_mpc_preparat_plan_opsmaterial_norms_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_preparat_plan_work_area_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_preparat_plan_work_station_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_preparat_task_work_area_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_preparat_task_work_station_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_preparat_task_opsmaterial_norms_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_opsmaterial_receive_list where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_back_inv_materal_theory_inv where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--存量控制计划
select * from epqc_t_mpc_plan_stock_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--常规解冻计划
select * from epqc_t_mpc_nomal_thaw_plan_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_nomal_thaw_plan_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_nomal_thaw_task_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--快速解冻计划
select * from epqc_t_mpc_fast_thaw_plan_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_fast_thaw_plan_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';
select * from epqc_t_mpc_fast_thaw_task_execute_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--成品制备计划
select * from epqc_t_mpc_product_plan_detail where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';

--日排程计划
select * from epqc_t_mpc_daily_cook_plan where to_char(create_time, 'yyyy-MM-dd') = '2015-06-02';


--更新库存
UPDATE epqc_t_inv_opsmaterial_theory_inv SET task_confirmed_flag = 'Y' WHERE task_confirmed_flag = 'N' AND del_flag = 'N' AND opsmaterial_status = '2';


--pos的数据查询
select * from v_pos_tc_sales order by business_date limit 10;
select * from pos_t_sales_header order by business_date desc limit 10;
select * from pos_t_event_header;

1G-->D:\YUM\101\POSXML-->(Agent) D:\2GBOH\

--查看该服务器有无配置不限上限io访问的事宜
 sysctl -n net.ipv4.tcp_tw_recycle