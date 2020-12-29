select * from SalesmanMaster(nolock)

select count(*) from Retailermaster(nolock)  where status=0 --1692294
select count(*) from Retailermaster(nolock)  where distcode in (select distcode from ActiveDistributor where DistStatus=1) --851134
select count(*) from Retailermaster(nolock)  where distcode in (select distcode from ActiveDistributor where DistStatus=0) --841160

select 841160+851134

select * from Retailermaster(nolock)

select DistCode,RtrCode,CSRtrCode,Status from Retailermaster(nolock) where distcode in (select distcode from ActiveDistributor where DistStatus=1)
select DistCode,RtrCode,CSRtrCode,Status from Retailermaster(nolock) where distcode in (select distcode from ActiveDistributor where DistStatus=0)

select * from Retailermaster(nolock) where status=0