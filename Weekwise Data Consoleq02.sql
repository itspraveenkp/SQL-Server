select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytargetparameter_output_del]--6
select count(*) from [JandJConsoleLive3].[dbo].[rcustomer]--652993
select count(*) from [JandJConsoleLive3].[dbo].[rcustomerroute]--1645540
select count(*) from [JandJConsoleLive3].[dbo].[rcustomershipaddress]
select count(*) from [JandJConsoleLive3].[dbo].[rdailysales] --2350491
select count(*) from [JandJConsoleLive3].[dbo].[rdailysales_del]
select count(*) from [JandJConsoleLive3].[dbo].[rdailysales_undelivered]
select count(*) from [JandJConsoleLive3].[dbo].[rdailysales_undelivered_del]
select count(*) from [JandJConsoleLive3].[dbo].[rdistributor]
select count(*) from [JandJConsoleLive3].[dbo].[rgeohierarchy]
select count(*) from [JandJConsoleLive3].[dbo].[rjccalander]
select count(*) from [JandJConsoleLive3].[dbo].[rmrpstockprocess]
select count(*) from [JandJConsoleLive3].[dbo].[rmrpstockprocess_del]
select count(*) from [JandJConsoleLive3].[dbo].[rorderbooking]
select count(*) from [JandJConsoleLive3].[dbo].[rorderbooking_del]
select count(*) from [JandJConsoleLive3].[dbo].[rproduct]
select count(*) from [JandJConsoleLive3].[dbo].[rproductuom]
select count(*) from [JandJConsoleLive3].[dbo].[rproductwisestock]
select count(*) from [JandJConsoleLive3].[dbo].[rproductwisestock_del]
select count(*) from [JandJConsoleLive3].[dbo].[rpurchasedetail]
select count(*) from [JandJConsoleLive3].[dbo].[rpurchasedetail_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmmonthlytarget]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmmonthlytarget_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmmonthlytarget_output]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmmonthlytarget_output_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytarget]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytarget_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytarget_output]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytarget_output_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytargetparameter]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytargetparameter_del]
select count(*) from [JandJConsoleLive3].[dbo].[rrdssmweeklytargetparameter_output]
select count(*) from [JandJConsoleLive3].[dbo].[rretailerhierarchy]
select count(*) from [JandJConsoleLive3].[dbo].[rroute]
select count(*) from [JandJConsoleLive3].[dbo].[rsaleshierarchy]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesinvoiceorders]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesinvoiceorders_del]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesman]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesmanroute]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesreturn]
select count(*) from [JandJConsoleLive3].[dbo].[rsalesreturn_del]
select count(*) from [JandJConsoleLive3].[dbo].[rsamplereceiptdetail]
select count(*) from [JandJConsoleLive3].[dbo].[rsamplereceiptdetail_del]
select count(*) from [JandJConsoleLive3].[dbo].[rschemecustomer]
select count(*) from [JandJConsoleLive3].[dbo].[rschemedistributor]
select count(*) from [JandJConsoleLive3].[dbo].[rschememaster]
select count(*) from [JandJConsoleLive3].[dbo].[rschemeproduct]
select count(*) from [JandJConsoleLive3].[dbo].[rschemeproductcategory]
select count(*) from [JandJConsoleLive3].[dbo].[rschemereatilercategory]
select count(*) from [JandJConsoleLive3].[dbo].[rschemeslab]
select count(*) from [JandJConsoleLive3].[dbo].[rschemeutilization]
select count(*) from [JandJConsoleLive3].[dbo].[rschemeutilization_del]
select count(*) from [JandJConsoleLive3].[dbo].[rstockdiscrepancy_withproduct]
select count(*) from [JandJConsoleLive3].[dbo].[rstockdiscrepancy_withproduct_del]
select count(*) from [JandJConsoleLive3].[dbo].[rsupplier]
select count(*) from [JandJConsoleLive3].[dbo].[rtbl_idtmanagementupload]
select count(*) from [JandJConsoleLive3].[dbo].[rtbl_idtmanagementupload_del]
select count(*) from [JandJConsoleLive3].[dbo].[rudcdetails]
select count(*) from [JandJConsoleLive3].[dbo].[rudcmaster]

select * from [JandJConsoleLive3].[dbo].[rproduct] where ProductCode='HBJ'

select count(*) from rdailysales(nolock) 
select top 1* from rdailysales(nolock) 

select count(*) from JandJConsoleLive3.dbo.rdailysales(nolock)

select * into [JandJConsoleLive3].[dbo].[rdailysales_old] from [JandJConsoleLive3].[dbo].[rdailysales](nolock)

--week wise data fetching query : 
select count(*) from csngjnjreport.RSchemeUtilization where DATE_FORMAT(createddt, '%Y-%m-%d') between '2019-08-25' and '2019-08-31' --344922 