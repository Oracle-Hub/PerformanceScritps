Transporting SQL PLAN Baselines from One Database to Another. (Doc ID 880485.1)

https://dbaclass.com/article/migrating-sql-baselines-from-one-database-to-another/
https://dbaclass.com/article/migrate-sql-profiles-from-one-database-to-another/

  
  
-------
Crate staging table

BEGIN
DBMS_SPM.CREATE_STGTAB_BASELINE(
table_name => 'spm_9g9rv13y443s2',
table_owner => 'XXIRIS',
tablespace_name => 'APPS_TS_TX_DATA');
END;
/


---- Load plan into Staging table 
  
SET SERVEROUTPUT ON
DECLARE
l_plans_packed PLS_INTEGER;
BEGIN
l_plans_packed := DBMS_SPM.pack_stgtab_baseline(
table_name => 'spm_9g9rv13y443s2',
table_owner => 'XXIRIS',
sql_handle => 'SQL_b965bedab0024296',
plan_name => 'SQL_PLAN_bktdyvas04hnq0743672e');
DBMS_OUTPUT.put_line('Plans Packed: ' || l_plans_packed);
END;
/


-----Export staging table
expdp  tables=XXIRIS.spm_9g9rv13y443s2 directory=SQLTS dumpfile=spm_9g9rv13y443s2.dmp logfile=spm_9g9rv13y443s2.log


----------On Target 
col OWNER for a15 
col DIRECTORY_NAME for a30
col DIRECTORY_PATH for a100
set line 200

select * from dba_directories where directory_name='SQLTS';

--- Import staging table ----- 

impdp full=y directory=SQLTS dumpfile=spm_9g9rv13y443s2.dmp logfile=spm_9g9rv13y443s2.log


----- Load SPM details into database -------------------

SET SERVEROUTPUT ON
DECLARE
l_plans_unpacked PLS_INTEGER;
BEGIN
l_plans_unpacked := DBMS_SPM.unpack_stgtab_baseline(
table_name => 'spm_9g9rv13y443s2',
table_owner => 'XXIRIS');

DBMS_OUTPUT.put_line('Plans Unpacked: ' || l_plans_unpacked);
END;
/
