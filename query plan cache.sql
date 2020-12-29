USE UAT

SELECT CP.usecounts,CP.cacheobjtype,CP.objtype,ST.text,QP.query_plan
FROM SYS.dm_exec_cached_plans AS CP
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY SYS.dm_exec_query_plan(plan_handle) AS qp

DBCC FREEPROCCACHE