/*  Sales and inventory data of toy store - Data exploration

Skills used - Joins, Temp Tables, Aggregate Functions, Converting Data Type

*/


Use [Maven Toy Sales]

---- Total Products and Stores

Select Count(Product_ID) as Total_Products
from products

Select Count(Store_ID) as Total_Stores
from stores




---- Adding Profit Column to show profit for each product

Select * 
From products

Alter table products
Add Product_Profit money

Update products
set Products.Product_Profit = products.Product_Price-products.Product_Cost




----  Calculate the percent of total sales and profit contributed by each product category

If OBJECT_ID (N'tempdb..#temp_Overallpercent') is not Null
Begin
Drop table #temp_Overallpercent
End

Create table #temp_Overallpercent
(
Product_Category varchar(50),
Total_sales float,
Overall_sales float,
Total_profit float,
Overall_profit float
)

Insert into #temp_Overallpercent
Select pr.Product_Category,
cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales,

(select cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales
From products pr
join sales sa
on pr.Product_ID=sa.Product_ID),

cast(sum(Pr.Product_Profit*sa.Units) as int) as Total_Profit,

(select cast(sum(Pr.Product_Profit*sa.Units) as int) as Total_Profit
From products pr
join sales sa
on pr.Product_ID=sa.Product_ID)

From products pr
join sales sa
on pr.Product_ID=sa.Product_ID
Group by pr.Product_Category

Select Product_category, 
Total_sales,
Round((Total_sales/Overall_sales)*100,2) as  'Salespercent%',
Total_profit,
Round((Total_profit/overall_profit)*100,2) as 'Profitpercent%'
from #temp_Overallpercent
Order by [Profitpercent%] desc




----Top 10 products based on profit and Total units sold in particular product

Select Top(10) pr.Product_Name,
cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales,
cast(sum(Pr.Product_Profit*sa.Units) as int) as Total_Profit,
sum(sa.units) as Total_units_Sold
From products pr
join sales sa
on pr.Product_ID=sa.Product_ID
Group by pr.Product_Name
Order by Total_Sales Desc




---- Total Sales and profit Across Store location

Select st.Store_Location, pr.Product_Category,
cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales,
cast(sum(Pr.Product_Profit*sa.Units) as int) as Total_Profit,
sum(sa.units) as Total_units_Sold
From products pr
join sales sa
on pr.Product_ID=sa.Product_ID
join stores st
on sa.Store_ID=st.Store_ID
Group by st.Store_Location,pr.Product_Category
Order by st.Store_Location,Total_Profit Desc




--Top 10 Store city in Total Sales and profit 

Select Top(10) st.Store_City,
cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales,
cast(sum(Pr.Product_Profit*sa.Units) as int) as Total_Profit,
sum(sa.units) as Total_units_Sold
From products pr
join sales sa
on pr.Product_ID=sa.Product_ID
join stores st
on sa.Store_ID=st.Store_ID
Group by st.Store_City
Order by Total_Sales Desc




---- No of stores with Zero Stocks with Product category---- 

Select st.Store_Location,pr.Product_Category,count(st.Store_Name) as Store_count_W_zerostock
from stores st
join inventory inv
on st.Store_ID=inv.Store_ID 
join products pr
on pr.Product_ID= inv.Product_ID
Where inv.Stock_On_Hand = 0
Group by st.Store_Location,pr.Product_Category
order by st.Store_Location,Store_count_W_zerostock desc




----How much money is tied up in inventory at the toy stores

Select st.Store_Location,pr.Product_Category,pr.Product_Name,
cast(sum(Pr.Product_Cost*inv.Stock_On_Hand) as int) as Inventory_Cost, sum(inv.Stock_On_Hand) as Total_Stock
from stores st
join inventory inv
on st.Store_ID=inv.Store_ID 
join products pr
on inv.Product_ID=pr.Product_ID
Group by st.Store_Location,pr.Product_Category,pr.Product_Name
order by st.Store_Location,Inventory_Cost desc, Total_Stock desc




---- First 5 stores opened ----

Select Top(5) Store_Name,cast(Max(Store_Open_Date) as date) as Opendate,
cast(sum(Pr.Product_Price*sa.Units) as int) as Total_Sales
from stores st
join sales sa
on st.Store_ID=sa.Store_ID
join products pr
on sa.Product_ID=pr.Product_ID
Group by Store_Name
order by Opendate 




