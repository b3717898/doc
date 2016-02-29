脚本记忆

--get all the locks 4 postgreSQL
SELECT clock_timestamp(), pg_class.relname, pg_locks.locktype, pg_locks.database,
       pg_locks.relation, pg_locks.page, pg_locks.tuple, pg_locks.virtualtransaction,
       pg_locks.pid, pg_locks.mode, pg_locks.granted
FROM pg_locks JOIN pg_class ON pg_locks.relation = pg_class.oid
WHERE relname !~ '^pg_' and relname <> 'active_locks';

--lock the row & sleep
BEGIN;
--INSERT INTO parent (name) VALUES ('Parent 21');
update parent set name='PPP' where id = 2;
select pg_sleep(60);
--SELECT * FROM active_locks;
--select for UPDATE * from parent where id = 3;
--update parent set name='PPP1' where id = 2;
COMMIT;

--查询pos点单时间和进入2GBOH系统的时间间隔
select sale_time,create_time,age(create_time,sale_time) as age from pos_t_sales_header_reduction where business_date='2015-11-18' 
ORDER BY age desc;

--查询pos的平均延迟时间
select avg(A.age) from 
(
select sale_time,create_time,age(create_time,sale_time) as age from pos_t_sales_header_reduction where business_date='2015-11-18' 
) A

--查询SQLServer的正在执行的sql
select A.* from (
SELECT   spid,
         blocked,
         DB_NAME(sp.dbid) AS DBName,
         program_name,
         waitresource,
         lastwaittype,
         sp.loginame,
         sp.hostname,
         a.[Text] AS [TextData],
         SUBSTRING(A.text, sp.stmt_start / 2, 
         (CASE WHEN sp.stmt_end = -1 THEN DATALENGTH(A.text) ELSE sp.stmt_end 
         END - sp.stmt_start) / 2) AS [current_cmd]
FROM     sys.sysprocesses AS sp OUTER APPLY sys.dm_exec_sql_text (sp.sql_handle) AS A
WHERE    spid > 50
) A where A.DBName = 'BOH2G_RSC_WORK_BOH' and program_name = 'WebSphere Application Server                                                                                                   ';

--卸载网卡
sudo kextunload -b expressvpn.tun
--PE库地址
http://run-svn/project/cn/boh2g_2/PE/Store/
--Yum 港汇的wifi用户名密码：
guest-0594692
tqbo0788

--查找sql server的执行sql语句
SELECT     [Spid] = session_Id, ecid, [Database] = DB_NAME(sp.dbid),

 [User] = nt_username, [Status] = er.status, 
 [Wait] = wait_type, 
 [Individual Query] = SUBSTRING(qt.text, er.statement_start_offset / 2, (CASE WHEN er.statement_end_offset = - 1 THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) 
                      * 2 ELSE er.statement_end_offset END - er.statement_start_offset) / 2),
                       [Parent Query] = qt.text, 
                       Program = program_name, Hostname, 
                       nt_domain, start_time
FROM    
     sys.dm_exec_requests er INNER JOIN  sys.sysprocesses sp ON er.session_id = sp.spid 
     CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS qt 
     WHERE     
     session_Id > 50 /* Ignore system spids.*/ 
     AND session_Id NOT IN (@@SPID)

--新增状态表
CREATE TABLE [dbo].[ACP_T_STORE_INFO_WITH_IT_STAUTS_DETAIL] (
  [GUID] varchar(36) COLLATE Chinese_PRC_CI_AS_WS NOT NULL,
  [FUN_ID] varchar(50) COLLATE Chinese_PRC_CI_AS_WS NOT NULL,
  [UPDATE_STATUS_TIME] datetime NULL,
  [STATUS] char(50) COLLATE Chinese_PRC_CI_AS_WS NULL,
  [CREATE_ID] varchar(36) COLLATE Chinese_PRC_CI_AS_WS NOT NULL,
  [CREATE_TIME] datetime NOT NULL,
  [UPDATE_ID] varchar(36) COLLATE Chinese_PRC_CI_AS_WS NOT NULL,
  [UPDATE_TIME] datetime NOT NULL,
  [DEL_FLAG] char(1) COLLATE Chinese_PRC_CI_AS_WS NOT NULL
)


git的脚步记录：
git init
git add fileName
git commit -m "second commit"

git remote add origin https://github.com/b3717898/doc.git

git push -u origin master   --for the first time
git push origin master

git status

git clone https://github.com/b3717898/doc.git
git pull

git remote -v

git config --global user.name "Chris' Desktop"
git config --global user.email "tao_jie@hoperun.com"

 time dd if=/dev/zero of=/test.dbf bs=8k count=300000   --计算io的平均值的命令

modify from Desktop

