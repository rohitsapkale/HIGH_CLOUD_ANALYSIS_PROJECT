select * from book1;

desc maindata_final;

drop table maindata_final;

truncate table maindata_final;

-- C:\ProgramData\MySQL\MySQL Server 8.0\Uploads
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/maindata_final.csv'
INTO TABLE maindata_final
FIELDS TERMINATED BY ','
optionally enclosed by '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS; -- if your CSV file has a header row you want to ignore

rename table book1 to maindata_final;

select * from maindata_final;

select count(*) from maindata_final;
ALTER TABLE maindata_final
CHANGE COLUMN `ï»¿Airline ID` `Airline ID`	 INT; 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
create view order_date as
select
concat(Year,"_", Month,"_",Day) as order_date, `Transported Passengers`,`Available Seats`,`From - To City`,`Carrier Name`,`Distance Group ID`
from 
maindata_final;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*-- "1.calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)"
   A.Year
   B.Monthno
   C.Monthfullname
   D.Quarter(Q1,Q2,Q3,Q4)
   E. YearMonth ( YYYY-MMM)
   F. Weekdayno
   G.Weekdayname
   H.FinancialMOnth
   I. Financial Quarter
   */
   
create view kpi1 as select year(order_date) as year_number,
month(order_date) as month_number,
day(order_date) as day_number,
monthname (order_date) as month_name,
concat("Q", quarter (order_date)) as quarter_number,
concat(year(order_date),"_",monthname (order_date)) as year_month_number,
weekday (order_date) as weekday_number,
dayname (order_date) as day_name,
Case
when quarter(order_date)=1 then "FQ4"
when quarter (order_date)=2 then "FQ1"
when quarter(order_date)=3 then "FQ2"
when quarter(order_date)=4 then "FQ3"
end as Financial_Quarter,
case
when month(order_date) = 1 then "10"
when month(order_date) = 2 then "11"
when month(order_date) = 3 then "12"
when month(order_date) = 4 then "1"
when month(order_date) = 5 then "2"
when month(order_date) then "3"
when month(order_date) = 7 then "4"
when month(order_date) = 8 then "5"
when month(order_date) = 9 then "6"
when month(order_date) = 10 then"7"
when month(order_date) = 11 then"8"
when month(order_date) = 12 then "9"
 end as Financial_month,

case
when weekday (order_date) in (5,6) then "weekend"
when weekday (order_date) in (0,1,2,3,4) then "Weekday"
end as weekend_weekday,
`Transported Passengers`,
`Available Seats`,
`From - To City`,
`Carrier Name`,
`Distance Group ID`
from order_date;

select * from kpi1;
select count(*) from kpi1;

-----------------------------------------------------------------------------------------------
-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

select `year_number`,sum(`Transported passengers`),sum(`Available Seats`),
(sum(`Transported Passengers`)/sum(`Available Seats`)*100)
as `load Factor` from kpi1 group by `year_number`;
-----------------------------------------------------------------------------------------------
select `Quarter_number`,sum(`Transported passengers`),sum(`Available Seats`),
(sum(`Transported Passengers`)/sum(`Available Seats`)*100)
as `load Factor` from kpi1 group by `Quarter_number` order by `Quarter_number`;
-----------------------------------------------------------------------------------------------
select `Month_name`,sum(`Transported passengers`),sum(`Available Seats`),
(sum(`Transported Passengers`)/sum(`Available Seats`)*100)
as `load Factor` from kpi1 group by `Month_name` order by `load Factor`;
------------------------------------------------------------------------------------------------
-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

select `carrier name`,sum(`Transported passengers`),sum(`Available Seats`),
(sum(`Transported Passengers`)/sum(`Available Seats`)*100)
as `load Factor` from kpi1 group by `carrier name` order by `load Factor`desc;

------------------------------------------------------------------------------------------------
-- 4. Identify Top 10 Carrier Names based passengers preference 
select`carrier name`,sum(`Transported passengers`) 
from kpi1 group by `Carrier name` order by sum(`Transported passengers`)desc limit 10;

------------------------------------------------------------------------------------------------
-- 5. Display top Routes ( from-to City) based on Number of Flights 
select `From - To City`,count(`From - To City`) as `Number_of_flights` from kpi1
group by `From - To City` order by count(`From - To City`) desc limit 10;

------------------------------------------------------------------------------------------------

-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
select `Weekend_Weekday`,sum(`Transported passengers`),sum(`Available Seats`),
(sum(`Transported Passengers`)/sum(`Available Seats`)*100)
 as `load Factor` from kpi1 group by `Weekend_Weekday`;
 
 ----------------------------------------------------------------------------------------------------------
-- 7. Identify number of flights based on Distance group
SELECT `Distance Group ID`, COUNT(*) AS Number_of_Flights
FROM maindata_final
GROUP BY `Distance Group ID`;
