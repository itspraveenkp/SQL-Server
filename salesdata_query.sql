Use JandJConsoleLive

select distinct salinvdate,distcode, rtrcode,prdcode,sum(PrdQty) qty,SUM(NRValue*prdQty) achieve,'d' from DailySales(nolock)
 where  DistCode in(131034,130484,134759,134748) and  salinvdate between '2019-07-29' and '2019-08-24'
group by salinvdate, distcode,rtrcode, prdcode

union all

select distinct salinvdate, distcode,rtrcode, prdcode,sum(PrdQty) qty,SUM(NRValue*prdQty) achieve,'u' from DailySales_undelivered(nolock) 
where DistCode in(131034,130484,134759,134748) and  salinvdate between '2019-07-29' and '2019-08-24' and BillStatus<3
group by salinvdate,distcode,rtrcode, prdcode

union  all 

select distinct SRNDate, DistCode,RtrCode,PrdCode,sum(PrdSalQty+PrdUnSalQty) qty,CONCAT('-',(SUM((NRValue*PrdSalQty)+(NRValue*PrdUnSalQty))) )achieve ,'s' from SalesReturn(nolock)
 where DistCode in(131034,130484,134759,134748) and  srndate  between '2019-07-29' and '2019-08-24'
 group by SRNDate, DistCode,RtrCode,PrdCode