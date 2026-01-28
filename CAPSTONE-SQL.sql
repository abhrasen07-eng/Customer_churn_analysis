##(1) Calculate the overall churn rate from the main customer data.
select count(*) as total_customers ,
		sum(case when Churn= 'Yes' then 1 else 0 end ) as churned_customers ,
        Round(sum(case when Churn= 'Yes' then 1 else 0 end ) * 100 / count(*) , 2) as churn_rate
        from churn_data ; ---- 1

##(2) Find the average monthly charges for churned vs non-churned customers.
 select AVG(case when Churn = "Yes"then MonthlyCharges END) as Average_churned_customer,
		Avg(case when Churn = "No" then MonthlyCharges end) as average_nonchurned_customers 
		from churn_data ; ----- 2
        
  select Avg(MonthlyCharges),Churn from churn_data group by Churn ;      ----- 2 alt 
  
 ##(3) List the top 5 payment methods with the highest churn rates.
 select PaymentMethod , count(*) as total_customers ,
		sum(case when Churn= 'Yes' then 1 else 0 end ) as churned_customers ,
        Round(sum(case when Churn= 'Yes' then 1 else 0 end ) * 100 / count(*) , 2) as churn_rate
        from churn_data 
        group by PaymentMethod
        order by churn_rate desc limit 5 ; ----- 3
 
##(4) Display the number of customers on each contract type who have churned.
select Contract , count(Churn) from churn_data where Churn = 'Yes' group by Contract ;     ---- 4

##(5)Count how many customers have tenure less than 12 months and have churned.
 select count(*) as no_of_customer_tenure_lessthan12  from churn_data where tenure <12 and Churn='Yes' ;          ####-----5
 
##(6) Identify how many customers have paperless billing and are paying through electronic check 
 select count(*) as no_of_customers from churn_data where PaperlessBilling = 'Yes' and PaymentMethod = 'Electronic check' ; ##------6

 ##(7) Calculate the total revenue generated from non-churned customers only.
 select sum(TotalCharges)  as total_revenue_non_churned from churn_data where Churn = 'No' ;  #---------------7
 
##(8) List customers who have never used phone service or internet service. 
select ch.customerID , ch.PhoneService , i.InternetService 
		from churn_data as ch 
        join internet_data as i
        on ch.customerID = i.customerID
        where ch.PhoneService = 'No'
        and i.InternetService = 'No' ;  #----------8

##(9) Find the number of customers with ‘Month-to-month’ contracts and no online security.
select count(*) as no_of_customers
		from churn_data as ch 
        join internet_data as i
        on ch.customerID = i.customerID
        where ch.Contract = 'Month-to-month'
        and i.OnlineSecurity = 'No' ;  #------------9

## (10) Show the churn rate grouped by senior citizen status.
select SUM(CASE WHEN Churn = 'Yes' THEN 1  END) * 100.0 / COUNT(*) AS ChurnRate, t2.SeniorCitizen
from churn_data as t1
join customer_data as t2 on t1.customerID = t2.customerID
group by t2.SeniorCitizen;
        
## (11) Determine the average customer age for churned vs non-churned customers.
select t1.Churn, Avg(2025 - (t2.year)) as AverageAge
from churn_data as t1
join customer_data as t2
on t1.customerID = t2.customerID
group by t1.Churn; #-------11
 
## (12) List customers with Fiber optic internet who are using all entertainment services (StreamingTV and StreamingMovies). 
 select customerId , InternetService,StreamingMovies,StreamingTV
																from internet_data 
                                                                where InternetService = 'Fiber optic' 
                                                                and StreamingTV = 'Yes'
                                                                and StreamingMovies = 'Yes' ; #-----12

## (13) Identify the top 5 customers who have paid the highest total charges but still churned.
select customerID , TotalCharges , Churn 
										from churn_data 
                                        where Churn = 'Yes' 
                                        order by TotalCharges desc limit 5 ; #---------13
                                        
                                        
## (14) Find customers who are not senior citizens now, but will turn 65 within the next 2 years.
select customerID
from customer_data
where SeniorCitizen = 'No' and (2025 - year) >= 63 ;
                                       
## (15) Get a list of customers who are using all possible services (phone, internet, backup, security, streaming, tech support).                                        
select ch.customerID, ch.PhoneService, i.InternetService, i.OnlineSecurity, i.OnlineBackup, i.TechSupport, i.StreamingTV, i.StreamingMovies
				from internet_data as i
				join churn_data as ch
                on i.customerID = ch.customerID 
                where i.InternetService = 'Yes'
                and i.OnlineSecurity= 'Yes'
                and i.OnlineBackup = 'Yes'
                and i.TechSupport = 'Yes'
				and i.StreamingTV = 'Yes'
                and i.StreamingMovies = 'Yes'
                and ch.PhoneService = 'Yes' ; #---------------------15

## (16) Calculate the churn rate by age group: <30, 30–50, 51–64, 65+.
select case when (2025 - t1.year) < 30 then '<30'
WHEN (2025 - T1.year) between 30 AND 50 then '30-50'
when (2025 - T1.year) between 51 and 64 then '51-64'
else '65+'
end as AgeGroup,
count(case when T2.Churn = 'Yes' then 1 end) * 100 / count(*) AS ChurnRate
from customer_data as t1
JOIN churn_data as t2
on t1.customerID = t2.customerID
group by AgeGroup
order by AgeGroup; 

## (17) Using a subquery, find customers whose total charges are above the average of all churned customers.
select customerID, TotalCharges from churn_data
where TotalCharges > (select avg(TotalCharges) from churn_data where churn = 'Yes');

## (18) Determine the correlation between long tenure (>= 24 months) and churn. Do loyal customers churn less?
select case when tenure >= 24 then 'Long_Tenure'
else 'Short_Tenure' 
end as LoyaltyStatus,
sum(case when Churn = 'Yes' then 1 else 0  end) * 100 / COUNT(*) as ChurnRate from churn_data
group by LoyaltyStatus;

## (19) Create a report showing monthly churn trend — how many customers churned each month.
select  tenure as ChurnMonth,
count(*) as ChurnedCustomers
from churn_data 
where Churn = 'Yes'
group by ChurnMonth
order by ChurnMonth;    

##(20)Rank customers by revenue (total charges) within each contract type using window functions.

select customerID, Contract, TotalCharges,
    rank() over (partition by Contract order by TotalCharges desc) AS revenue_rank
FROM CHURN_DATA
ORDER BY Contract ,
         revenue_rank ;   #-----20            

##(21)Using a CTE, list customers who have either no protection services (OnlineSecurity, Backup, DeviceProtection) and have churned.                
WITH Combinedtable AS (
    select
        c.customerID,c.gender,c.Partner,c.Dependents,
        i.OnlineSecurity,i.OnlineBackup,i.DeviceProtection,
        ch.Churn
     from CUSTOMER_DATA c
     join INTERNET_DATA i
        on c.customerID = i.customerID
    join CHURN_DATA ch
        on c.customerID = ch.customerID
)
select 
    customerID,gender,OnlineSecurity,OnlineBackup,DeviceProtection,Churn
from Combinedtable
where 
    Churn = 'Yes'
    AND OnlineSecurity = 'No'
    AND OnlineBackup = 'No'
    AND DeviceProtection = 'No'; #-------21

 

##(22)I want a to check how many days, month and year is left for each and every employee to reach the Senior Citizen
select customerID, DOB,
    date_add(DOB, INTERVAL 65 YEAR) AS senior_citizen_date,
    TIMESTAMPDIFF(YEAR, curdate(), date_add(DOB, INTERVAL 65 YEAR)) AS years_left,
    mod(TIMESTAMPDIFF(MONTH, curdate(),date_add(DOB, INTERVAL 65 YEAR)),12) AS months_left,
    mod(TIMESTAMPDIFF(DAY, curdate(), date_add(DOB, INTERVAL 65 YEAR)), 30) AS days_left
FROM CUSTOMER_DATA;          #--------------22  








