Reducing the Oracle E-Business Suite Data Footprint (Doc ID 752322.1)
  
Reclaim space using Move method 
--------------------------------
Using SHIRNK – 
Advantages : This doesn’t require additional space to create temporary objects and no downtime required.
                Disadvantages : Running forever.

Using MOVE : 
                Advantages : Process is quick, I.e we can complete DB level activities in 2 days.
                Disadvantages : Downtime needed and additional space required at DB level, since we have enough space, this won’t be a problem.


Capture Tables to move grater than 2 GB
=======================================

column "SIZE (GB)" format 99999.99;
col segment_name for a30
set line 200
set pagesize 100
col OWNER for a20
select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;

select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'INDEX' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;

SELECT 'ALTER TABLE '||OWNER||'.'||segment_name||' move PARALLEL 32;' from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and bytes/1024/1024/1024 in
(select bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2);

Now you can append all below entries in sql file and then execute using nohup mode.
================================================================================
col OWNER for a15
column "SIZE (GB)" format 99999.99;
col TABLE_NAME for a35
col segment_name for a30
set line 200
set pagesize 100
col INDEX_NAME for a30
set time on timing on;
set echo on;
set heading on;
spool INV-MTL_UNIT_TRANSACTIONS.out
select distinct sid from v$mystat;
select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;

select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'INDEX' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;

select owner,table_name,num_rows,to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') last_analyzed from dba_tables where  owner like 'INV' and table_name='MTL_UNIT_TRANSACTIONS';

ALTER TABLE INV.MTL_MATERIAL_TRANSACTIONS move PARALLEL 32;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_MATERIAL_TRANSACTIONS' , estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE, cascade => TRUE,method_opt => '  FOR ALL COLUMNS SIZE AUTO ' , degree => 32);

select owner,table_name,num_rows,to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') last_analyzed from dba_tables where  owner like 'INV' and table_name='MTL_UNIT_TRANSACTIONS';

select owner,table_name,index_name,num_rows,to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') last_analyzed from dba_indexes where  owner like 'INV' and table_name='MTL_UNIT_TRANSACTIONS';
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N1 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N2 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N3 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N4 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N5 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N6 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N7 REBUILD PARALLEL 32;
select owner,table_name,index_name,num_rows,to_char(last_analyzed,'YYYY-MM-DD HH24:MI:SS') last_analyzed from dba_indexes where  owner like 'INV' and table_name='MTL_UNIT_TRANSACTIONS';

spool off;
set echo off;
set heading off;
exit;



Followed by Index Rebuild and Gathering Stats and Capture stats info- I've included all information in above script, If you need to capture Index alter script, use below script.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Since we are rebuilding indexes, It captures stats as well, but let's verify. ( upon observation, you don't need to capture stats for Index, it's capturing stats as part of Index rebuild.


select 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD PARALLEL 32;' from dba_indexes where table_name='MTL_UNIT_TRANSACTIONS';

ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N1 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N2 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N3 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N4 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N5 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N6 REBUILD PARALLEL 32;
ALTER INDEX INV.MTL_UNIT_TRANSACTIONS_N7 REBUILD PARALLEL 32;




------------------------------

SELECT 'ALTER INDEX ' || OWNER || '.' ||
INDEX_NAME || ' REBUILD ' ||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_INDEXES
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD PARTITION ' || PARTITION_NAME ||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_IND_PARTITIONS
WHERE STATUS='UNUSABLE'
UNION
SELECT 'ALTER INDEX ' || INDEX_OWNER || '.' ||
INDEX_NAME ||
' REBUILD SUBPARTITION '||SUBPARTITION_NAME||
' TABLESPACE ' || TABLESPACE_NAME || ';'
FROM DBA_IND_SUBPARTITIONS
WHERE STATUS='UNUSABLE';

--------------------------------------

Or another way to rebuil sub partition. 
------------
  -- To find Index name 
select 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD PARALLEL 32;' from dba_indexes where table_name='WF_USER_ROLE_ASSIGNMENTS';
--- and then rebuild sub partition 
select 'ALTER INDEX '||INDEX_OWNER||'.'||INDEX_NAME||' REBUILD partition '||partition_name|| ' PARALLEL 32;' from dba_ind_partitions where index_name ='WF_USER_ROLE_ASSIGNMENTS_N4';



