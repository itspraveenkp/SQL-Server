--	Jan-2016 - Dec-2016
select	yr,mon,PrdCode,DistCode,clStckQty,NR,LP,PTR,Value as NRValue,
		round(isnull(LP,0)*isnull(clStckQty,0),2) as LPValue,
		round(isnull(PTR,0)*isnull(clStckQty,0),2) as PTRValue 
from	lakshya.cdgmaster.tblPf_ClstkM_2016(nolock) 
where	yr=2016 and isnull(clStckQty,0)<>0
order	by yr,mon,DistCode,PrdCode

--	Jan-2017 - Jun-2017
select	yr,mon,PrdCode,DistCode,clStckQty,NR,LP,PTR,Value as NRValue,
		round(isnull(LP,0)*isnull(clStckQty,0),0) as LPValue,
		round(isnull(PTR,0)*isnull(clStckQty,0),0) as PTRValue 
from	lakshya.cdgmaster.tblpf_clstkm(nolock) 
where	yr=2017 and mon<=6 and isnull(clStckQty,0)<>0
order	by yr,mon,DistCode,PrdCode
