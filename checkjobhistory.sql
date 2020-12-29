select 
 j.name as 'invokeRT',
 run_date,
 run_time
From msdb.dbo.sysjobs j 
INNER JOIN msdb.dbo.sysjobhistory h 
 ON j.job_id = h.job_id 
where j.enabled = 1  --Only Enabled Jobs
order by  run_date, run_time desc