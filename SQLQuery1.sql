---Inspecting Data
select * from [dbo].[sales_data_sample]

---Checking Unique Values
select distinct status from [dbo].[sales_data_sample] --Nice one to plot
select distinct year_id from [dbo].[sales_data_sample]
select distinct PRODUCTLINE from [dbo].[sales_data_sample] ---Nice to plot
select distinct COUNTRY from [dbo].[sales_data_sample] --- Nice to plot
select distinct DEALSIZE from [dbo].[sales_data_sample] ---Nice to plot
select distinct TERRITORY from [dbo].[sales_data_sample] ---Nice to plot

--- Analysis 
--- Lets start by srouping sales by productline
select PRODUCTLINE, Sum(sales) as Revenue
from [dbo].[sales_data_sample] 
group by PRODUCTLINE
order by 2 desc;
--- using Aggregate functions
select YEAR_ID, Sum(sales) as Revenue
from [dbo].[sales_data_sample] 
group by YEAR_ID
order by 2 desc;

--- we checked that the revenue was low in the 2005 so we went ahead and checked further whether they operated for the full year or not in 2005

select distinct MONTH_ID from [dbo].[sales_data_sample]
where YEAR_ID = 2005

--- we found that they operated for only 5 months in 2005

select distinct MONTH_ID from [dbo].[sales_data_sample]
where YEAR_ID = 2003 
order by MONTH_ID
--- we again checked for the year 2003 and 2004 found that they were in operations for the whole year
--- that was the reason for low revenue in 2005


--- checking the revenue by the deal size

select DEALSIZE, Sum(sales) as Revenue
from [dbo].[sales_data_sample] 
group by DEALSIZE
order by 2 desc;
--- the medium size deals generate the most revenue so they should stick to that in the future

--- Question
--- What was the best month for sales in a specific year? how much was earned that month?

select  
MONTH_ID, SUM(sales) as Revenue, Count (ORDERNUMBER) AS Frequency
from [dbo].[sales_data_sample]
where YEAR_ID = 2003 --- we can change thiis to see for the rest of the years
group by MONTH_ID
order by 2 desc;

--- but this query only gave us the month id so we modified the above query using a case statement


SELECT 
    CASE MONTH_ID
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month_Name,
    SUM(sales) AS Revenue,
    COUNT(ORDERNUMBER) AS Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2003 -- you can change this to see for other years
GROUP BY MONTH_ID
ORDER BY 2 DESC;

--- From this analysis we found that the month of novenmer has the highest revenue and the frequency of the orders
--- we will quickly change the year and look for the values for the year 2004
SELECT 
    CASE MONTH_ID
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month_Name,
    SUM(sales) AS Revenue,
    COUNT(ORDERNUMBER) AS Frequency
FROM [dbo].[sales_data_sample]
WHERE YEAR_ID = 2004 -- you can change this to see for other years
GROUP BY MONTH_ID
ORDER BY 2 DESC;

--- from this result we can say that the month of Noven=mber is really exceptional

--- November seems to be the best month, What product do they sell in november?

select 

 CASE MONTH_ID
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month_Name,
 PRODUCTLINE, SUM(sales) as Revenue, Count (ORDERNUMBER) AS Frequency
from [dbo].[sales_data_sample]
where YEAR_ID = 2003 and MONTH_ID = 11 --- we can change thiis to see for the rest of the years
group by MONTH_ID, PRODUCTLINE
order by 3 desc;
--- we had to add the PRODUCTLINE in the groupby as it is not a part of the aggregate function
---we will do the same for the year 2004

select 

 CASE MONTH_ID
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END AS Month_Name,
 PRODUCTLINE, SUM(sales) as Revenue, Count (ORDERNUMBER) AS Frequency
from [dbo].[sales_data_sample]
where YEAR_ID = 2004 and MONTH_ID = 11 --- we can change thiis to see for the rest of the years
group by MONTH_ID, PRODUCTLINE
order by 3 desc;

--- now well do the RFM analysis
--- RFM ANALYSIS
---Recency-Frequency-Monetary (RFM)
---• It is an indexing technique that uses past purchase behavior to segment customers.
---• An RFM report is a way of segmenting customers using three key metrics:
---recency (how long ago their last purchase was), frequency (how often they purchase), and monetary value (how much they spent)

--- Data Points used in RFM analysis
---1. Recency - last Order date
---2. Frequency - count of total Orders
---3. Monetary Value - Total Spends

DROP TABLE IF EXISTS #rfm

;with rfm as 
(select 
	CUSTOMERNAME,
	sum(sales) as Total_Monetary_value,
	avg(sales) as Average_Monetary_value,
	COUNT(ORDERNUMBER) as Frequency,
	max(ORDERDATE) AS last_order_date,
	(select max(ORDERDATE)  from [dbo].[sales_data_sample]) as max_order_date,
	DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE)  from [dbo].[sales_data_sample] )) as Recency

from [dbo].[sales_data_sample]
group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
	NTILE(4) over (order by Recency desc) as rfm_recency,
	NTILE(4) over (order by Frequency) as rfm_frequency,
	NTILE(4) over (order by Total_Monetary_value) as rfm_monetary
	from rfm as r
)

select
	c.*, rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
	CAST(rfm_recency as varchar) + CAST (rfm_frequency as varchar) + CAST (rfm_monetary as varchar) as rfm_cell_string
	into #rfm
	from rfm_calc c

select * from #rfm

--- now in order to use the rfm technique we need to make a table that has recency(how recent the customer had last purchaesd)
--- 1. we created a table which had last order date in the daabase along the last order date of the customer, we used 
--- [max(ORDERDATE) AS last_order_date] and {select max(ORDERDATE)  from [dbo].[sales_data_sample]} as the ultimate last date the company had an order
--- we went ahead and used the DATEIFF functun to find the recency of the customer
--- so after runninf select 
---CUSTOMERNAME,
---sum(sales) as Total_Monetary_value,
---avg(sales) as Average_Monetary_value,
---COUNT(ORDERNUMBER) as Frequency,
---max(ORDERDATE) AS last_order_date,
---(select max(ORDERDATE)  from [dbo].[sales_data_sample]) as max_order_date,
---DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE)  from [dbo].[sales_data_sample])) as Recency

---from [dbo].[sales_data_sample]
---group by CUSTOMERNAME
--- we get the recency
--- we dont stop here we go ahead and build on this code to segment our customers
--- we use NTILE function in the sql to segment our data into tiles or buckets of equal values
--- we design it in such a way that a good table #rfm  from which we can query

select  
 CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132,221, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143,234, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331, 412, 421) then 'new_customers'
		when rfm_cell_string in (222, 232, 223, 233, 322, 423) then 'potential_churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active_customer' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal_customers'
	end rfm_segment
from #rfm


--- now from this we can make out thr list of most loyal customers, active customers, potential churners, new customers, the big spenders who are not ordering often and are slipping away we dont want to loose them 




---EXTRAs----
--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from [dbo].[sales_data_sample]
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from [dbo].[sales_data_sample]
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc




UPDATE [dbo].[sales_data_sample] SET ADDRESSLINE1 = UPPER(SUBSTRING(ADDRESSLINE1, 1, 1)) + LOWER(SUBSTRING(ADDRESSLINE1, 2, LEN(ADDRESSLINE1) - 1))
select ADDRESSLINE1 from [dbo].[sales_data_sample]


