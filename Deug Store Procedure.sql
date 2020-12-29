USE [UAT]
GO
/****** Object:  StoredProcedure [cdgmaster].[usp_VMR_SuggestOrder_RT]    Script Date: 8/24/2020 11:02:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--V20190820
  Create PROCEDURE sp_suggestOrder_RT  
   @distCode VARCHAR(50),  
   @SRC VARCHAR(50),  
   @testDate dateTime = null,  
   @genPL char(1) ='N'  
  as  
    begin 
  
  SET NOCOUNT ON  
  
  declare @UNIT_PC varchar(2)  
  set @UNIT_PC = 'PC'  -- UOM for piece  
  
  declare @ERRORNUM int, @LOCALROWCOUNT int, @updatedBy int  

  declare @BCweek varchar(10)--vasanthi
 set @BCweek = '0'
  
  declare @curStDt dateTime  
  if @testDate is null  
   set @curStDt = getDate()  
  else  
   set @curStDt = @testDate  
  
  declare @curStDtYMD varchar(8)  
  select @curStDtYMD = replace(convert(varchar, @curStDt, 111), '/', '')  
  
  Declare  
   @stateCode  int,  
   @recFound   char(1),  
   @canOrdId   int,  
   @ordId      int,  
   @scheduleId int,  
   @curStYr    int,  
   @curStMM    int  
  , @sitPastDays  int  
  , @loopId int, @MapFound char(1), @ClsFound char(1), @curCloseMaxDt dateTime, @curCloseQtyPC int, @prdCodeMap varchar(50), @prdCodeVMR varchar(50)  
  , @curSITQtyPC int  
  
  set @sitPastDays = 10  
  select @sitPastDays = convert(int, ParamVal) from cdgmaster.tblSystemParam With(Nolock) where ParamName = 'VMRsitDaysPast'  
  
 select distinct @curStYr= [year], @curStMM=monthkey, @BCweek=[Week] from cdgmaster.BusinessCalender with(nolock) where datediff(d, salInvDate, @curStDt)= 0  --Added by vasanthi for VMR 2019 001 RDR
  
  create table #tmpTodaysDist (  
   DistCode    varchar(50)  
    , overrideYes  char(1) default 'N'    
  )  
  
  create table #tmpSKU (  
    prdCode varchar(50)  
  )  
  
  create table #tmpSKUMap (  
    serNo int identity(1,1),  
    prdCodeVMR varchar(50),  
    prdCodeMap varchar(50)    
  )  
  
  create table #tmpProdUOM (  
   PrdCode varchar(100)  
   , SaleUOM varchar(50)  
   , cnvFact  numeric(18,2)  
  )  
  
  create table #tmpErrDist (  
   DistCode    varchar(50)  
  )  
  
  if @genPL = 'Y'  
   exec cdgmaster.usp_VMR_PriceList  
  
  insert into #tmpSKU (prdCode)   
   select distinct case when p.VMR_SAPID is null then  
        case when isnull(p.ParentCode,'0') ='0' then p.sapId   
        else (select SAPId from cdgmaster.SKU q with(nolock) where q.SKUCode= p.ParentCode) end   
       else p.VMR_SAPID end vmr_SapId  
   from cdgmaster.SKU p with(nolock) where VMRApply='Y' and IsActive='Y' and isDeleted != 'Y' and isDeleted != 'Y'  
  
  delete from #tmpSKU where prdCode not in (select SAPId from cdgmaster.SKU p with(nolock) where VMRApply='Y' and IsActive='Y' and isDeleted != 'Y')  --if parent or VMR sap id were selected  
  
  insert into #tmpSKUMap (prdCodeVMR, prdCodeMap)   
   select distinct case when p.VMR_SAPID is null then  
        case when isnull(p.ParentCode,'0') ='0' then p.sapId   
        else (select SAPId from cdgmaster.SKU q with(nolock) where q.SKUCode= p.ParentCode) end   
       else p.VMR_SAPID end vmr_SapId, p.SAPId  
   from cdgmaster.SKU p with(nolock) where IsActive='Y' and isDeleted != 'Y' and isDeleted != 'Y'  
  --    from cdgmaster.SKU p with(nolock) where VMRApply='Y' and IsActive='Y' and isDeleted != 'Y' and isDeleted != 'Y'  
  
  delete from #tmpSKUMap where prdCodeVMR =prdCodeMap  
  delete from #tmpSKUMap where prdCodeVMR not in (select prdCode from #tmpSKU)  --VMR code inactive/deleted  
  delete from #tmpSKUMap where prdCodeMap not in (select SAPId from cdgmaster.SKU p with(nolock) where IsActive='Y' and isDeleted != 'Y')    
  insert into #tmpSKUMap (prdCodeMap, prdCodeVMR) select prdCode, prdCode from #tmpSKU  
  
    
  ---------------debugging purpose-----------------------  
  --select * from #tmpSKUmap  
  -------------------------------------------------------  
    
    
  insert into #tmpTodaysDist(DistCode)   
  select DistCode from cdgmaster.tblVMRDistRunSugOrd with(nolock) where IsActive='Y' and ordDateYMD= @curStDtYMD  
   and distCode in (select SAPID from cdgmaster.customer with(nolock) where IsActive = 'Y' and VMRApply='Y')  
  
  update #tmpTodaysDist   
     set overrideYes = 'Y' where DistCode in (select Distinct DistCode from cdgmaster.tblVMRdistOverride with(nolock) where avgDailyPrdQty > 0 or safetyDays > 0)  
  
  select @scheduleId = max(scheduleId) from cdgmaster.tblVMRavgDailySchd with(nolock)   
  
  delete from #tmpTodaysDist where overrideYes = 'N'   
   and DistCode not in   
    (select DistCode from cdgmaster.tblVMRavgDailySales  with(nolock) where scheduleId = @scheduleId)  
  
  create table #tmpMaxASL (  
    mDistCode varchar(50)  
  , mprdCode varchar(50)  
  , maxASLmonth int  
  , maxASLyear int)  
  
  insert into #tmpMaxASL (mDistCode, mprdCode, maxASLyear)  
    select DistCode, prdCode, max(ASLyear)   
   from cdgmaster.tblVMRdistOverride  with(nolock)   
     where DistCode in (select DistCode from #tmpTodaysDist)  
    and ASLyear <= @curStYr  
  group by DistCode, prdCode  
  
  update #tmpMaxASL set maxASLmonth = (select max(ASLmonth)   
    from cdgmaster.tblVMRdistOverride  with(nolock)   
   where mDistCode = DistCode and mprdCode = prdCode and ASLyear = maxASLyear  
     and ( ( ASLyear = @curStYr and ASLmonth <= @curStMM) or (ASLyear < @curStYr) ) )  
  
  insert into #tmpProdUOM (prdCode, SaleUOM, cnvFact)  
   select t1.prdCode, t2.UnitID, t2.ConvrcnRatio from   
   (select distinct prdCode from cdgmaster.tblVMRavgDailySales s with(nolock)   
    where scheduleId=@scheduleId and DistCode in (select DistCode from #tmpTodaysDist)  
      and prdCode in (select prdCode from #tmpSKU)  
   union   
    select distinct prdCode from cdgmaster.tblVMRdistOverride  with(nolock)   
    where DistCode in (select DistCode from #tmpTodaysDist)  
    and prdCode in (select prdCode from #tmpSKU)  
   ) t1   
   left outer join   
   (select sku.SAPID, u.UnitID, (Case WHEN (ConvrcnRatio is null AND u.unitCode=3) then 1 else ConvrcnRatio end) ConvrcnRatio  
      from cdgmaster.SKU with(nolock)   
   inner join cdgmaster.Unit u  with(nolock) on u.isDeleted='N'   
   and u.unitCode=   
  
       (case when isnull(VMR_UOM,0)=0   
       then (  
         Case when isnull(SKU.saleUOM,0)=0   
         then isnull(SKU.baseUOM,0) else SKU.saleUOM end  
       )  
       else VMR_UOM end)   
   left join cdgmaster.SKUUnitConvrsnDtl d  with(nolock) on d.skuid = sku.SAPid and d.UnitId1= u.UnitID AND d.UnitId2= @UNIT_PC   
   where sku.SAPID in (select prdCode from #tmpSKU)  
  
   ) t2 on t1.prdCode = t2.SAPID  
  
  declare @transDate dateTime  
  
  
  select @stateCode=c.stateCode from #tmpTodaysDist d inner join cdgmaster.customer c With(Nolock) on c.SAPId = d.DistCode and c.SAPId = @distCode --20140320  
  
  create table #tmpSuggOrderDet (  
    PrdCode   varchar(50)  
  , ComputePrdQtyPC     int  
  , CloseStockPrdQtyPC  int  
  , InTransitPrdQtyPC   int  
  , UOMdisplay  varchar(10)  
  , UOMConversion  numeric(12,3)  
  , avgDailyPrdQty  int  
  , exception  char(1),  
  mapcode varchar(20)  
  )  
  
  
  set @recFound = 'N'  
  select  top 1  @recFound='Y', @canOrdId=serno   
     from cdgmaster.tblVMRsuggOrderHdr with(nolock)  
   where DistCode= @DistCode and forRunDateYMD = @curStDtYMD and iscancel='N'  
  order by serno desc  
  
  IF @recFound='Y'   
  BEGIN --{  
  UPDATE cdgmaster.tblVMRsuggOrderHdr SET isCancel='Y', CancelReason='This order has been superseded by the Real time order'  
  WHERE serno=@canOrdId  
  END -- }  
  
   insert into cdgmaster.tblVMRsuggOrderHdr (DistCode, createDate, forRunDateYMD, lastUpdatedBy, lastUpdatedOn,SRC,realtimeYN ,isCancel)  
    values (@DistCode, getdate(), @curStDtYMD, 0, getDate(),@SRC,'Y','N')  
  
   select @ordId = @@identity  
   truncate table #tmpSuggOrderDet  
   
   insert into #tmpSuggOrderDet(PrdCode, ComputePrdQtyPC  
      , CloseStockPrdQtyPC  
      , InTransitPrdQtyPC  
  
      , UOMdisplay, UOMConversion, avgDailyPrdQty, exception)   
    select  isnull(s.PrdCode, ov.PrdCode) PrdCode  
  
    , case when isnull(ov.avgDailyPrdPC,0) = 0 then  
     (case when isnull(s.avgDailyPrdQty,0) =0 then isnull(ov.avgDailyPrdPC, 0) else isnull(s.avgDailyPrdQty,0) end)   
        * isnull(ov.safetyDays, 0)  
      else ov.avgDailyPrdPC end  
    , 0 
     
    , 0 
    , u.saleUOM, u.cnvFact, isnull(s.avgDailyPrdQty, 0)  
    , case when u.PrdCode is null then 'P' when u.SaleUOM is null or isnull(u.cnvFact,0) = 0 then 'U' else 'N' end  
      from (select * from cdgmaster.tblVMRavgDailySales with(nolock) where scheduleId=@scheduleId) as s   
     full outer join   
    (select cdgmaster.tblVMRdistOverride.*   
       from cdgmaster.tblVMRdistOverride with(nolock)   
        inner join #tmpMaxASL on mDistCode= DistCode and mprdCode= prdCode and maxASLyear= ASLyear and maxASLmonth= ASLmonth  
      where isnull(safetyDays, 0) <> 0 or isnull(avgDailyPrdPC,0) <> 0  
     ) ov on ov.DistCode = s.DistCode and ov.PrdCode = s.PrdCode  
     left outer join #tmpProdUOM u on u.PrdCode = isnull(s.prdCode, ov.prdCode)  
     where isnull(s.DistCode, ov.DistCode) = @DistCode  
       and isnull(s.prdCode, ov.prdCode) in (select prdCode from #tmpSKU)  
       
   IF EXISTS (  
   select *  
  from (select distinct prdCodeVMR from #tmpSKUMap where prdCodeVMR not in ( select PrdCode from #tmpSuggOrderDet)) as z  
  left outer join #tmpProdUOM u on u.PrdCode = z.prdCodeVMR   
  
  )  
  BEGIN  
   insert into #tmpSuggOrderDet (PrdCode, ComputePrdQtyPC, CloseStockPrdQtyPC, InTransitPrdQtyPC  
       , UOMdisplay, UOMConversion, avgDailyPrdQty, exception)   
    select  z.prdCodeVMR, 0,0,0  
     , u.saleUOM, u.cnvFact, 0, case when u.PrdCode is null then 'P' when u.SaleUOM is null or isnull(u.cnvFact,0) = 0 then 'U' else 'N' end  
   from (select distinct prdCodeVMR from #tmpSKUMap where prdCodeVMR not in ( select PrdCode from #tmpSuggOrderDet)) as z  
   left outer join #tmpProdUOM u on u.PrdCode = z.prdCodeVMR  
  
  END  
  
  --Change Start delete outdated promo product  
   delete from #tmpSuggOrderDet where PrdCode in(select sapid from cdgmaster.tblVMRLimitedSKU with(nolock) where datediff(d, startDate, getdate()) >= 0 and datediff(d, endDate, getdate()) > 0 and isnull(deletionMark,'Y') = 'N' and limitType='O')  
  --Change End  
  
  
   IF(@SRC<>'VMR')  
   BEGIN -- Closing FROM CONSOLE Current Stock   
    update #tmpSuggOrderDet set InTransitPrdQtyPC = isnull(InTransitPrdQtyPC,0) + isnull(qtyPc, 0)   
      from (  
     select sum(isnull(qty,0)) qtyPc, productCode from (  
      select case when d.designCode=@UNIT_PC then isnull(d.indentQtyPcs, 0)   
          else isnull(d.indentQtyPcs, 0)   
         * (select top 1 ConvrcnRatio from cdgmaster.SKUUnitConvrsnDtl du with(nolock)   
          where du.skuid = Mp.prdCodeMap and du.UnitId1= d.designCode and du.UnitId2= @UNIT_PC)  
        end qty, Mp.prdCodeMap, Mp.prdCodeVMR productCode  
    from jandjconsolelive.dbo.purchaseDetail d with(nolock)  
      inner join jandjconsolelive.dbo.purchaseHeader h with(nolock) on d.CompInvNo collate database_default = h.CompInvNo collate database_default  
      inner join #tmpSKUMap Mp on Mp.prdCodeMap collate database_default = d.productCode collate database_default  
     where 
	
	(isnull(POSGrnNo,'') = '' or  isnull(POSGrnNo,'0') = '0')
	 and h.siteCode = @DistCode and datediff(d, h.CompInvDate, getDate()) <= @sitPastDays  
    ) as xt group by productCode   
    ) tt where tt.productCode= #tmpSuggOrderDet.PrdCode  
  
  
    set @MapFound = 'N'  
    select top 1 @loopId= serNo, @MapFound= 'Y', @prdCodeMap= prdCodeMap, @prdCodeVMR= prdCodeVMR  
    from #tmpSKUMap order by serNo  
  
    while (@MapFound = 'Y')  
    begin  --{  
     set @curCloseQtyPC = 0  
     set @ClsFound='N'   
     select top 1 @ClsFound='Y', @curCloseMaxDt = transdate from jandjconsolelive.dbo.CurrentStockSnapshot pws with(nolock)  
      where pws.PrdCode =@prdCodeMap  
        and pws.distCode= @DistCode order by transdate desc -- Closing Stk  
  
     if @ClsFound='Y'  
     begin  
      select @curCloseQtyPC= sum(isnull(salClsStock,0)) from jandjconsolelive.dbo.CurrentStockSnapshot pws with(nolock)  
       where pws.PrdCode collate database_default =@prdCodeMap collate database_default  
         and pws.distCode collate database_default = @DistCode collate database_default and transdate =@curCloseMaxDt -- Closing Stk  
  
      update #tmpSuggOrderDet set CloseStockPrdQtyPC = isnull(CloseStockPrdQtyPC,0) + isnull(@curCloseQtyPC,0)  
       where #tmpSuggOrderDet.PrdCode = @prdCodeVMR  
     end  
  
     set @MapFound = 'N'  
     select top 1 @loopId= serNo, @MapFound= 'Y', @prdCodeMap= prdCodeMap, @prdCodeVMR= prdCodeVMR  
       from #tmpSKUMap where serNo > @loopId  
       order by serNo  
    end --}  
   
   END  
   ELSE  
   BEGIN -- Closing FROM VMR Closing Tables  
    PRint 'vmr closing'  
  
    SET @MapFound = 'N'  
    SELECT TOP 1 @loopId = serNo, @MapFound = 'Y', @prdCodeMap = prdCodeMap, @prdCodeVMR = prdCodeVMR  
    FROM #tmpSKUMap ORDER BY serNo  
  
    WHILE (@MapFound = 'Y')  
     BEGIN  --While loop starts  
      SET @curCloseQtyPC = 0  
      SET @curSITQtyPC = 0  
      DECLARE @ConvrcnRatio NUMERIC(18,2)  
      SET @ConvrcnRatio = 0  
      
      SET @ClsFound='N'   
  
      SELECT @ClsFound='Y'  
      FROM cdgmaster.tblVMRCLStkSIT VMRCLSIT WITH(nolock)  
      WHERE VMRCLSIT.prdCode = @prdCodeMap AND VMRCLSIT.distCode = @DistCode AND isProcessed = 'N'   
  
      IF (@ClsFound='Y')  
       BEGIN    
        SELECT @curCloseQtyPC = ClstkQty  * (select top 1 ConvrcnRatio from cdgmaster.SKUUnitConvrsnDtl du with(nolock)   
              where du.skuid = VMRCLSIT.prdCode and du.UnitId1= VMRCLSIT.UOM and du.UnitId2= @UNIT_PC),  
          @curSITQtyPC = SITQty  * (select top 1 ConvrcnRatio from cdgmaster.SKUUnitConvrsnDtl du with(nolock)   
              where du.skuid = VMRCLSIT.prdCode and du.UnitId1= VMRCLSIT.UOM and du.UnitId2= @UNIT_PC)  
        FROM cdgmaster.tblVMRCLStkSIT VMRCLSIT WITH(nolock)  
        WHERE VMRCLSIT.prdCode = @prdCodeMap AND VMRCLSIT.distCode= @DistCode AND isProcessed = 'N' AND VMRCLSIT.UOM <> @UNIT_PC  
  
        SELECT @curCloseQtyPC = ClstkQty * 1,  
          @curSITQtyPC = SITQty * 1  
        FROM cdgmaster.tblVMRCLStkSIT VMRCLSIT WITH(nolock)  
        WHERE VMRCLSIT.prdCode = @prdCodeMap AND VMRCLSIT.distCode= @DistCode AND isProcessed = 'N' AND VMRCLSIT.UOM = @UNIT_PC  
  
        UPDATE #tmpSuggOrderDet   
        SET  CloseStockPrdQtyPC = ISNULL(CloseStockPrdQtyPC,0) + ISNULL(@curCloseQtyPC,0),  
          InTransitPrdQtyPC = ISNULL(InTransitPrdQtyPC,0) + ISNULL(@curSITQtyPC,0)  
        WHERE #tmpSuggOrderDet.PrdCode = @prdCodeVMR  
       END  
  
      SET @MapFound = 'N'  
  
      SELECT TOP 1 @loopId = serNo, @MapFound = 'Y', @prdCodeMap = prdCodeMap, @prdCodeVMR = prdCodeVMR  
      FROM #tmpSKUMap   
      WHERE serNo > @loopId ORDER BY serNo  
  
     END --While loop end  
  
   END  
  
  
  
   ------debugging---------  
    update #tmpSuggOrderDet set mapcode = @prdcodemap   
    where PrdCode = @prdCodeVMR  
    ------end---------------  
  
  IF Exists (Select * from #tmpSuggOrderDet)   
  BEGIN  
   insert into cdgmaster.tblVMRsuggOrderDet (HdrSerNo, PrdCode, ComputePrdQtyPC  
       , CloseStockPrdQtyPC, InTransitPrdQtyPC, UOMdisplay, UOMConversion, avgDailyPrdQty, exception)   
   select @ordId, PrdCode, ComputePrdQtyPC  
       , CloseStockPrdQtyPC, InTransitPrdQtyPC, UOMdisplay, UOMConversion, avgDailyPrdQty, exception   
     from #tmpSuggOrderDet  
  END  


   ----------------------------------------------------------- Added by vasanthi for VMR 2019 001 RDR----------------------------------------------------------
  if (@BCweek like '%4%' or @BCweek like '%5%' or @BCweek like '%6%')
begin
	Declare @zone int,
	 @compute numeric(18,2)

	 set @zone = (select ZoneCode from cdgmaster.Customer where SAPID=@DistCode)
	 create table #ASLincrease(
	 zone int,
	 class varchar(10),
	 sku bigint
	 );

	 create table #ASLfactor(
	 sku bigint, 
	 ASLfactor int
	 );

	 insert into #ASLincrease (zone,class,sku)
	 select ZoneCode, class, [SKU Code] from cdgmaster.tblVMRSKUClassification where ZoneCode = @zone and isactive ='Y';

	 if(@BCweek like '%4%')
	 begin
	 insert into #ASLfactor (sku, ASLfactor)  
	 select al.sku, isnull(wk.W4_Target,0) from cdgmaster.tblvmr_Zone_class_WeekTarget wk
	 inner join #ASLincrease al with(nolock) on al.zone = wk.ZoneCode and al.class = wk.Class where wk.IsActive = 'Y'

		update dt set  OldComputePRdQtyPc = isnull(ComputePrdQtyPC ,0)
		from cdgmaster.tblVMRsuggOrderDet dt with(nolock) 
		left join #ASLfactor asl with(nolock) on dt.PrdCode = convert(varchar(20),asl.sku) where dt.HdrSerNo = @ordId 

		update det set det.ComputePrdQtyPC = round(isnull(det.ComputePrdQtyPC,0) + (isnull(det.ComputePrdQtyPC,0) * isnull(af.ASLfactor,0) / 100),0),
		ASLFactorValue = isnull(af.ASLfactor,0)
		from  cdgmaster.tblVMRsuggOrderDet det with(nolock)
		inner join #ASLfactor af with(nolock) on det.PrdCode = convert(varchar(20),af.sku) where det.HdrSerNo = @ordId

	end
	else if(@BCweek like '%5%')
	 begin
	 insert into #ASLfactor (sku, ASLfactor)  
	 select al.sku, isnull(wk.W5_Target,0) from cdgmaster.tblvmr_Zone_class_WeekTarget wk
	 inner join #ASLincrease al with(nolock) on al.zone = wk.ZoneCode and al.class = wk.Class where wk.IsActive = 'Y'

		update dt set  OldComputePRdQtyPc = isnull(ComputePrdQtyPC ,0)
		from cdgmaster.tblVMRsuggOrderDet dt with(nolock) 
		left join #ASLfactor asl with(nolock) on dt.PrdCode = convert(varchar(20),asl.sku) where dt.HdrSerNo = @ordId 

		update det set det.ComputePrdQtyPC = round(isnull(det.ComputePrdQtyPC,0) + (isnull(det.ComputePrdQtyPC,0) * isnull(af.ASLfactor,0) / 100),0),
		ASLFactorValue = isnull(af.ASLfactor,0)
		from  cdgmaster.tblVMRsuggOrderDet det with(nolock)
		inner join #ASLfactor af with(nolock) on det.PrdCode = convert(varchar(20),af.sku) where det.HdrSerNo = @ordId

	end
	else if(@BCweek like '%6%')
	 begin
		 insert into #ASLfactor (sku, ASLfactor)  
		 select al.sku, isnull(wk.W6_Target,0) from cdgmaster.tblvmr_Zone_class_WeekTarget wk
		 inner join #ASLincrease al with(nolock) on al.zone = wk.ZoneCode and al.class = wk.Class where wk.IsActive = 'Y'

		update dt set  OldComputePRdQtyPc = isnull(ComputePrdQtyPC ,0)
		from cdgmaster.tblVMRsuggOrderDet dt with(nolock) 
		left  join #ASLfactor asl with(nolock) on dt.PrdCode = convert(varchar(20),asl.sku) where dt.HdrSerNo = @ordId 

		update det set det.ComputePrdQtyPC = round(isnull(det.ComputePrdQtyPC,0) + (isnull(det.ComputePrdQtyPC,0) * isnull(af.ASLfactor,0) / 100),0),
		ASLFactorValue = isnull(af.ASLfactor,0)
		from  cdgmaster.tblVMRsuggOrderDet det with(nolock)
		inner join #ASLfactor af with(nolock) on det.PrdCode = convert(varchar(20),af.sku) where det.HdrSerNo = @ordId

	end

	drop table #ASLfactor -- Added By Amit On 15 April 2019
	drop table #ASLincrease  -- Added By Amit On 15 April 2019
	
end

  
  Begin  
     UPDATE CDGMASTER.tblVMRCLStkSIT SET isProcessed='Y',ordDateYMD=@curStDtYMD,ordHdr=@ordId WHERE isProcessed='N' AND distCode=@DistCode   
     --Select * from #tmpSuggOrderDet   
  End  
  /*----------------*/  
  
  SELECT @ERRORNUM=@@Error, @LOCALROWCOUNT = @@ROWCOUNT      
  if @ERRORNUM <> 0 or @@ROWCOUNT < 1  
  begin   
   --ROLLBACK TRANSACTION  
   insert into #tmpErrDist values (@DistCode)  
   insert into cdgmaster.tblVMRJobLog (jobCode, LogMsg) values ('usp_VMR_SO', 'insert tblVMRsuggOrderDet fail @dist:' + @DistCode)  
       
  end  
  
 
  select top 1 @transDate = transDate from jandjconsolelive.dbo.CurrentStockSnapshot pws with(nolock)  
    where pws.PrdCode collate database_default in   
    (select top 1 PrdCode from cdgmaster.tblVMRsuggOrderDet with(nolock) where HdrSerNo =@ordId)  
    and pws.distCode collate database_default = @DistCode collate database_default  
  order by transdate desc  
  
  --end  
  
  update cdgmaster.tblVMRsuggOrderHdr set transDateClose =@transDate where SerNo =@ordId  
  
  select top 1 @updatedBy=UpdatedBy from cdgmaster.tblvmrRT_Ord_Req With(Nolock) where distCode=@DistCode and Req_DtYMD=@testDate order by 1 desc  
  
  update cdgmaster.tblVMRsuggOrderHdr set lastUpdatedBy =@updatedBy where SerNo =@ordId  
  
 
   update cdgmaster.tblVMRsuggOrderDet   
     set NetQtyPCNoRound = case when isnull(ComputePrdQtyPC,0) - isnull(CloseStockPrdQtyPC, 0) - isnull(InTransitPrdQtyPC,0)<0   
     then 0 else isnull(ComputePrdQtyPC,0) - isnull(CloseStockPrdQtyPC, 0) - isnull(InTransitPrdQtyPC,0) end  
   where HdrSerNo= @ordId  
 
  update OrderDet  
    set UOMConversion = (select top 1 ConvrcnRatio from cdgmaster.SKUUnitConvrsnDtl skd with(nolock)   
         where skd.skuid = DU.prdCode and skd.UnitId1= DU.UOM and skd.UnitId2= @UNIT_PC)  
   , UOMdisplay = DU.UOM  
  from cdgmaster.tblVMRsuggOrderDet as OrderDet  
  right JOIN cdgmaster.tblVMRDistUOM as DU On DU.prdCode=OrderDet.prdCode AND DU.DistCode=@DistCode and DU.isarchived='N'  
  where HdrSerNo= @ordId   
 
  UPDATE cdgmaster.tblVMRsuggOrderDet  
  SET  UOMConversion = 1  
  WHERE HdrSerNo = @ordId   
  AND  UOMdisplay = @UNIT_PC  
  
     update cdgmaster.tblVMRsuggOrderDet   
     set NetQtyPCNoRound_Old = NetQtyPCNoRound  
     where HdrSerNo= @ordId  
  
   update cdgmaster.tblVMRsuggOrderDet set   
   multiplier = isnull(s.Multiplier,0) ,  
     
   allocation_qty = case when   
  
       isnull(allc.serNo,0) <> 0 and isnull(s.Multiplier ,0)  <= 0   
       then   
       isnull(allc.Allocation_qty,0)   
       else  
       0   
       end ,  
  
   invoice_qty =isnull((  
            select sum((isnull(mtdinv.invoice_qty,0)) )  
   from   
   (  
    select isnull(invoice_qty ,0) as invoice_qty  , PrdCode from cdgmaster.tbl_MonthlyTillDate_Invoicing with (nolock) where [month]= @curStMM and [year] = @curStYr   
    and DistCode = shdr.DistCode   
   )   
   as  mtdinv where prdcode  in   
   (     
    select sapid from cdgmaster.sku with (nolock) where VMR_SAPID = s.VMR_SAPID  
   )  
    ),0)   
  ,  
  
  returns_qty  =isnull((  
            select sum((isnull(mtdinv.Returns_qty,0)) )  
   from   
   (  
    select isnull(Returns_qty ,0) as Returns_qty , PrdCode from cdgmaster.tbl_MonthlyTillDate_Invoicing with (nolock) where [month]= @curStMM and [year] = @curStYr   
    and DistCode = shdr.DistCode  
   )   
   as  mtdinv where prdcode  in   
   (  
    select sapid from cdgmaster.sku with (nolock) where VMR_SAPID = s.VMR_SAPID and isactive  ='Y' and isdeleted ='N'  
   )  
  ) ,0)  
                    
  from  cdgmaster.tblVMRsuggOrderDet as  tblso   
  left join cdgmaster.tblVMRsuggOrderHdr shdr on tblso.HdrSerNo =shdr.serNo  
  left  join   
  (  
   select t2.sapid , t1.CustomerType , t1.serNo , t1.skucode  from cdgmaster.tblVMR_SKUActivation  t1  with (nolock)  
   inner join cdgmaster.SKU t2  on t1.SKUCode = t2.VMR_SAPID where t1.isDeleted ='N'  
  ) sa on tblso.PrdCode  = sa.sapid   
  left outer join   
  (  
   select * from cdgmaster.tblVMRAllocation with (nolock) where [month] = @curStMM and [year] =@curStYr   
  ) allc   
  on tblso.PrdCode = allc.SKU  and shdr.DistCode = allc.distributor   
  left join cdgmaster.Customer cust on cust.SAPID = shdr.DistCode and cust.isactive ='Y'  
  left join cdgmaster.sku  s on  tblso.PrdCode = s.SAPID  
  
  where tblso.HdrSerNo= @ordId   
  
    select * into #tblscheme from cdgmaster.tblVMR_PrimaryScheme where (isnull(BaseQty,0) > 0 or isnull(freeQty,0) > 0) and isDelete='N' and isActive='Y' 
	and Fromdate <= GETDATE() and Todate >= GETDATE()  -- Added By Amit on 24 April 2019 -- amit add between/ date range condition 

  update dt set dt.BaseQty =case when  pr.isDelete='N' and pr.isActive='Y' and  convert(date,GETDATE()) between convert(date,pr.Fromdate) and convert(date,pr.Todate) then isnull(pr.BaseQty,0) else 0  end ,

				dt.FreeQty = case when  pr.isDelete='N' and pr.isActive='Y' and convert(date,GETDATE()) between convert(date,pr.Fromdate) and convert(date,pr.Todate)  then isnull(pr.freeQty,0) else 0 end
  from  cdgmaster.customer (nolock) cu 
inner join cdgmaster.tblVMR_PrimaryScheme (nolock) pr on cu.ZoneCode=pr.ZoneCode
inner join  cdgmaster.tblVMRsuggOrderHdr (nolock) hd on cu.SAPID=hd.DistCode
inner join cdgmaster.tblVMRsuggOrderDet (nolock)  dt on hd.serNo=dt.HdrSerNo and pr.SKUCode=dt.PrdCode
where hd.forRunDateYMD=@curStDtYMD and convert(date,GETDATE()) between convert(date,pr.Fromdate) and convert(date,pr.Todate) and pr.IsActive='Y'
     and pr.Isdelete ='N' and pr.isActive='Y' and  convert(date,GETDATE()) between convert(date,pr.Fromdate) and convert(date,pr.Todate) and
	 (isnull(dt.allocation_qty,0) = 0 and isnull(dt.multiplier,0) = 0)

  update cdgmaster.tblVMRsuggOrderDet  set diff_alloc_netinvqty = isnull(allocation_qty,0) -(isnull(invoice_qty,0) - isnull(returns_qty,0))  
  ,  
  NetQtyPCNoRound  =  
  (   
  case  
  when  isnull(nullif(rtrim(ltrim(Multiplier)),''),0) > 0      
  then  
  (  

   select cdgmaster.fn_getGeneratedOrderValue  
   (0,1,0,0,isnull(Multiplier,0),isnull(NetQtyPCNoRound_Old,0),0,ISNULL(UOMConversion,0))  
  )  
  when  isnull(Allocation_qty,0) >0  

  then   
  (  
   select cdgmaster.fn_getGeneratedOrderValue(1,0,isnull(Invoice_qty,0),isnull(Returns_qty,0),0,isnull(NetQtyPCNoRound_Old,0),isnull(Allocation_qty,0),0  )  
  )  
  else  
      case when isnull(NetQtyPCNoRound_Old,0) <0 then 0 else isnull(NetQtyPCNoRound_Old,0) end  --isnull(tblso.NetQtyPCNoRound,0)     
  end  
  )     
  where HdrSerNo = @ordId ;  
  SELECT @ERRORNUM=@@Error, @LOCALROWCOUNT = @@ROWCOUNT      
  if @ERRORNUM <> 0 or @LOCALROWCOUNT < 1  
  begin  

   insert into #tmpErrDist values (@DistCode)  
   insert into cdgmaster.tblVMRJobLog (jobCode, LogMsg) values ('usp_VMR_SO', 'update NetQtyPCNoRound fail @dist:' + @DistCode )  
       
  end  
  
  update cdgmaster.tblVMRsuggOrderDet set NetQtyPCNoRound = 0 where HdrSerNo= @ordId and NetQtyPCNoRound < 0  
  update cdgmaster.tblVMRsuggOrderDet   
    set netQty = round((NetQtyPCNoRound / UOMConversion ), 0) * UOMConversion  
  where HdrSerNo= @ordId and UOMConversion > 0  
  
  update cdgmaster.tblVMRsuggOrderDet set overridePrdQty = netQty where HdrSerNo= @ordId and netQty is not null  
  
  SELECT @ERRORNUM=@@Error, @LOCALROWCOUNT = @@ROWCOUNT      
  if @ERRORNUM <> 0 or @LOCALROWCOUNT < 1  
  begin  
   --ROLLBACK TRANSACTION  
   insert into #tmpErrDist values (@DistCode)  
   insert into cdgmaster.tblVMRJobLog (jobCode, LogMsg) values ('usp_VMR_SO', 'update overridePrdQty fail @dist:' + @DistCode )       
  end  
  
  update cdgmaster.tblVMRsuggOrderDet   
      set  ratePerPC = isnull((select top 1 ClaimRateVMR from cdgmaster.tblVMRPriceList pl  with(nolock)   
           where pl.stateCode = @stateCode  
           and pl.prdCode = tblVMRsuggOrderDet.prdCode ), 0)  
       ,MRPPerPack = isnull((select top 1 MRPPerPack from cdgmaster.tblVMRPriceList pl  with(nolock)  -- 20140320   
           where pl.stateCode = @stateCode  
           and pl.prdCode = tblVMRsuggOrderDet.prdCode ), 0)  
    where HdrSerNo= @ordId          
  
  
  SELECT @ERRORNUM=@@Error, @LOCALROWCOUNT = @@ROWCOUNT      
  if @ERRORNUM <> 0 or @LOCALROWCOUNT < 1  
  begin  
   --ROLLBACK TRANSACTION  
   insert into #tmpErrDist values (@DistCode)  
   insert into cdgmaster.tblVMRJobLog (jobCode, LogMsg) values ('usp_VMR_SO', 'update ratePerPC fail @dist:' + @DistCode )       
  end   
  
  UPDATE cdgmaster.tblVMRsuggOrderHdr SET isRT_Req = (  
  Select max(serno) from cdgmaster.tblvmrRT_Ord_Req With(Nolock) WHERE distCode=@DistCode AND datediff(d,createdDate,getdate())=0  
  ) WHERE serno=@ordId  
  
  UPDATE cdgmaster.tblVMRsuggOrderHdr SET OSAMT =(SELECT top 1 OSAMT FROM cdgmaster.tblVMRLedgerAmt With(Nolock) WHERE DistCode=@DistCode),  
            SapOsDate = (SELECT top 1 SapDate FROM cdgmaster.tblVMRLedgerAmt With(Nolock) WHERE DistCode=@DistCode)  
  WHERE serno=@ordId  
  --commit transaction  
  
  delete from cdgmaster.tblVMRsuggOrderDet  where serno  in   
  (  
   select tblso.serno  from  cdgmaster.tblVMRsuggOrderDet as  tblso   
   left join cdgmaster.tblVMRsuggOrderHdr shdr on tblso.HdrSerNo =shdr.serNo  
   left  join   
   (  
    select t2.sapid , t1.CustomerType , t1.serNo , t1.skucode  from cdgmaster.tblVMR_SKUActivation  t1  with (nolock)  
    inner join cdgmaster.SKU t2  on t1.SKUCode = t2.VMR_SAPID where t1.isDeleted ='N'  
   ) sa on tblso.PrdCode  = sa.sapid   
   left outer join   
   (  
    select * from cdgmaster.tblVMRAllocation with (nolock) where [month] = @curStMM and [year] =@curStYr   
   ) allc   
   on tblso.PrdCode = allc.SKU  and shdr.DistCode = allc.distributor   
   left join cdgmaster.Customer cust on cust.SAPID = shdr.DistCode  
  
   where tblso.HdrSerNo= @ordId   
  
   and   
  
    (   
     isnull(sa.serNo,0) <>  0  and  (isnull(nullif(cust.channel,''),-1) <> sa.CustomerType)  
    )   
   )  
  ) ;  
  
  drop table #tmpErrDist  
  drop table #tmpTodaysDist   
  drop table #tmpProdUOM  
  drop table #tmpMaxASL  
  drop table #tmpSKU  
  drop table #tmpSKUMap   
  drop table #tmpSuggOrderDet  
   
  end