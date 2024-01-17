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

col segment_name for a30
set line 200
set pagesize 100
select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;

SELECT 'ALTER TABLE '||OWNER||'.'||segment_name||' move PARALLEL 32;' from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and bytes/1024/1024/1024 in
(select bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2);


set echo on;
set heading on;
set time on timing on;
spool INV-MTL_UNIT_TRANSACTIONS.out
select distinct sid from v$mystat;
col segment_name for a30
set line 200
set pagesize 100
select segment_name,segment_type,owner,bytes/1024/1024/1024 "SIZE (GB)" from dba_segments where segment_type = 'TABLE' and segment_name not like 'BIN%' and owner not in ('SYS')
and bytes/1024/1024/1024 > 2 order by bytes/1024/1024/1024 desc;
ALTER TABLE INV.MTL_MATERIAL_TRANSACTIONS move PARALLEL 32;
ALTER TABLE INV.MTL_SERIAL_NUMBERS move PARALLEL 32;
ALTER TABLE INV.MTL_UNIT_TRANSACTIONS move PARALLEL 32;
spool off;
set echo off;
set heading off;
exit;





Followed by Index Rebuild and Gathering Stats and Capture stats info
---------------------------------------------------------------------

Since we are rebuilding indexes, It captures stats as well, but let's verify.


select 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD PARALLEL 32;' from dba_indexes where table_name='MTL_UNIT_TRANSACTIONS';



