select * from AUDIT_Trace..	job_history where jobname like '%main%' and cast(createddate as date)='2019-10-31' order by step --order by RunDate desc