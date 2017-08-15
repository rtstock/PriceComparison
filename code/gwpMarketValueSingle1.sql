-- select * from portfolio order by default_portfolio_code
-- select * from portfolio_state
set nocount on
if object_id('tempdb..#temp') is not null drop table #temp
if object_id('tempdb..#templist') is not null drop table #templist
if object_id('tempdb..#templist_C') is not null drop table #templist_C

declare @Portcode varchar(30)
declare @ClassSchemeID int
declare @PGAsOfDate varchar(30)

set @PGAsOfDate = '2014-09-30'
set @ClassSchemeID = '34'
set @Portcode = 'xjustj'

--set @Portcode = %Portcode%
--set @ClassSchemeID = %ClassSchemeID%
--set @PGAsOfDate = %PGAsOfDate%


--set @Portcode = 'akbequ'
--set @ClassSchemeID = 34
--set @PGAsOfDate = '2014-3-31'

declare @PortfolioTypeCode varchar(20)

set @PortfolioTypeCode = (select isnull(Portfolio_Type_Code,'') from portfolio where default_portfolio_code=ltrim(rtrim(@portcode)))

declare @PGAsOfDateTime datetime
declare @PGAsOfDateTimeP1d datetime
declare @PGAsOfDateTimeP1dM1m datetime
declare @isMaster int


set @PGAsOfDateTime = convert(datetime, @PGAsOfDate)
set @PGAsOfDateTimeP1d = dateadd(d,1,@PGAsOfDateTime)
set @PGAsOfDateTimeP1dM1m = dateadd(mi,-1,@PGAsOfDateTimeP1d)

set @isMaster = (select is_master_flag from portfolio where default_portfolio_code=@Portcode)

create table #templist (portfoliocode varchar(30))
create table #templist_c (portfoliocode varchar(30))

if (@isMaster=1 )
begin
	insert into #templist(portfoliocode)
	select distinct 
	sp.default_portfolio_code
	from 
	portfolio_hierarchy_hist ph 
	inner join portfolio mp on ph.master_portfolio_id = mp.portfolio_id
	inner join portfolio sp on ph.sub_portfolio_id = sp.portfolio_id
	where 
	mp.default_portfolio_code=@portcode 
	and isnull(effective_end_date,GETDATE()) >= @PGAsOfDate
	--and mp.is_active_flag=1 and sp.is_active_flag=1
	and ph.hierarchy_start_date = 
		(select max(hierarchy_start_date) 
		from portfolio_hierarchy_hist 
		 where master_portfolio_id = (select portfolio_id from portfolio where default_portfolio_code = @portcode)	 
		and hierarchy_start_date <= @PGAsOfDate)

	insert into #templist(portfoliocode)
	
	select @Portcode+'U' 

end
else
begin
	insert into #templist(portfoliocode)
	select @Portcode
	union
	select @Portcode+'U'
end


--remove any duplicates in templist

insert into #templist_C (portfoliocode)
select distinct portfoliocode from #templist
delete #templist
insert into #templist
select distinct portfoliocode from #templist_C

create table #temp(
SortOrder int,
securityid int,
ClassNodeName varchar(30),
MarketValueCurrent float,
originalcost float,
accint float,
YieldAtCost float,
YieldToWorst float,
CurrentYield float)


insert into #temp (
SortOrder,
securityid,
ClassNodeName,
MarketValueCurrent,
originalcost,
accint,
YieldAtCost,
YieldToWorst,
CurrentYield)

SELECT 2 as SortOrder, sp.securityid, cn1.ClassNodeName,
sp.marketvalue * sp.marketfxrate as MarketValueCurrent,
sp.totalcost * sp.bookfxrate AS originalcost,
sp.accruedincome * sp.marketfxrate AS AccInt,
isnull(YieldAtCost,0) as  YieldAtCost,
isnull(YieldToWorst,0) as YieldToWorst,
isnull(CurrentYield,0) as CurrentYield

FROM fmc_pv_securityposition sp
	INNER JOIN fmc_pv_SecurityClassificationAll sc 
		ON sp.securityid = sc.securityid
        and     sc.IsCurrent=1
	INNER JOIN fmc_pv_classnode cn2 on 	cn2.classnodeid = sc.classnodeid
	inner join fmc_pv_classnode cn1 on cn2.ParentClassNodeId=cn1.ClassNodeId
	INNER JOIN fmc_pv_classscheme cs on cs.classschemename = cn2.classschemename 

WHERE portfoliocode in (select PortfolioCode from #templist)
AND SnapshotBasisCode= 'SNAP' 
AND DateBasisCode = 'TRA' 
AND effectivedatetime = @PGAsOfDateTimeP1dM1m
AND cn2.ClassNodeLevel =2
AND ClassSchemeID = @ClassSchemeID


insert into #temp (
SortOrder,securityid,
ClassNodeName,
MarketValueCurrent,
originalcost,
accint,
YieldAtCost,
YieldToWorst,
CurrentYield)
SELECT 1 as SortOrder, 0, 'Cash' as ClassNodeName,
cp.totalcash * cp.marketfxrate as MarketValueCurrent,
0 AS originalcost,
cp.AccruedInterest * cp.marketfxrate AS AccInt,
0 as  YieldAtCost,
0 as YieldToWorst,
0 as CurrentYield
from            fmc_pv_CashPosition                     cp
WHERE portfoliocode in (select PortfolioCode from #templist)
AND SnapshotBasisCode= 'SNAP' 
AND DateBasisCode = 'TRA' 
AND effectivedatetime = @PGAsOfDateTimeP1dM1m



SELECT isnull(sum(isnull(marketvaluecurrent,0)),0) as marketvaluecurrent, isnull(SUM(isnull(AccInt,0)),0) as Accint
FROM #temp

--select * from #temp

drop table #temp
drop table #templist
drop table #templist_C