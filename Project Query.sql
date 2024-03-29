Select * FROM hr_analytics;

#Which deparmant gives the highest daily rate?
		#R&D Department gives highest daily rate
select Department,round(Avg(DailyRate),2) as 'Avgerage Daily Rate'
FROM hr_analytics
GROUP BY Department
order by 2 DESC;

# Which JobRole gives the highest daily rate?
Select JobRole, round(Avg(MonthlyIncome),2) as 'Avgerage_Daily_Rate'
FROM hr_analytics
GROUP BY 1
ORDER BY 2 desc

Select JobRole, round(Avg(DailyRate),2) as 'Avgerage_Daily_Rate'
FROM hr_analytics
GROUP BY 1
ORDER BY 2 desc

#YearOfEXperienceBefore
ALTER hr_analytics 
ADD YearOfEXperienceBefore INT

UPDATE hr_analytics
SET YearOfEXperienceBefore = TotalWorkingYears - YearsAtCompany




# Which Deparment like to hire nonexperience 
	# Sales Department 
SELECT Department, count(CASE WHEN YearOfEXperienceBefore = 0 THEN 1 END) as '# of people',
round(count(CASE WHEN YearOfEXperienceBefore = 0 THEN 1 END)/count(*)*100,2) as '% of total'
FROM hr_analytics
GROUP BY Department
ORDER BY 3 desc 

# Which JobRole like to hire nonexperience 
	# Sales Rep > Research Scientist > Lab Technician
SELECT JobRole, count(CASE WHEN YearOfEXperienceBefore = 0 THEN 1 END) as '# of people',
round(count(CASE WHEN YearOfEXperienceBefore = 0 THEN 1 END)/count(*)*100,2) as '% of total'
FROM hr_analytics
GROUP BY JobRole
ORDER BY 3 desc 
limit 3


# Which Job pays the best on each job level
	#Level 1 R&D Lab Tech
	#Level 2 Sales Sales REPEAT
	#Level 3 R&D RS
	#Level 4 R&D Manager
	#Level 5 R&D Research Director
WITH cte as(
select Department,JobRole,JobLevel,round(Avg(DailyRate),2) as 'Avgerage_Daily_Rate'
FROM hr_analytics
GROUP BY Department,JobRole,JobLevel
order by 1,2
)
SELECT Department,JobRole, JobLevel, Avgerage_Daily_Rate
from(SELECT *,rank() over (PARTITION by JobLevel ORDER BY Avgerage_Daily_Rate Desc) as RK
from cte) a
where RK =1




# CREATE Top Paid Job role table based on each job level
CREATE TABLE Top_Daily_Job AS
SELECT Department, JobRole, JobLevel, Average_Daily_Rate, RK
FROM (
    SELECT Department, JobRole, JobLevel, Average_Daily_Rate,
           RANK() OVER (PARTITION BY JobLevel ORDER BY Average_Daily_Rate DESC) AS RK
    FROM (
        SELECT Department, JobRole, JobLevel, ROUND(AVG(DailyRate), 2) AS 'Average_Daily_Rate'
        FROM hr_analytics
        GROUP BY Department, JobRole, JobLevel
    ) AS subquery
) AS ranked
WHERE RK = 1;

select h.JobRole, EducationField,h.JobLevel,count(*)
FROM hr_analytics h
right join top_daily_job t
on h.Department = t.Department and h.JobRole=t.JobRole and h.JobLevel = t.JobLevel
GROUP BY h.JobRole,EducationField,h.JobLevel




# With what education Backgroud would most likely get in thest job
with cte as (
select h.JobLevel,h.JobRole, EducationField, rank() Over(PARTITION by h.JobRole ORDER BY count(*) desc) as rk
FROM hr_analytics h
right join top_daily_job t
on h.Department = t.Department and h.JobRole=t.JobRole and h.JobLevel = t.JobLevel
GROUP BY h.JobRole,EducationField,h.JobLevel
)
select JobLevel,JobRole,EducationField
FROM cte
where rk=1
ORDER BY 1



# How TotalWorkingYears affect DailyRate
 # A linechart need for clear trend
Select TotalWorkingYears,round(Avg(DailyRate),2) as 'Avgerage Daily Rate'
FROM hr_analytics
GROUP BY TotalWorkingYears




# How TotalWorkingYears affect MonthlyIncome
	# As TotalWorkingYears increase, MonthlyIncome increase as well, after 20 years, the MonthlyIncome almost tripple
Select TotalWorkingYears,round(Avg(MonthlyIncome),2) as 'Avgerage Daily Rate'
FROM hr_analytics
GROUP BY TotalWorkingYears



# There are two travelrarely in BusinessTravel colnum 
UPDATE hr_analytics
Set BusinessTravel = 'Travel_Rarely'
WHERE BusinessTravel = 'TravelRarely'



# How travel option affect Daily Rate
	# The more you travel the less your DailyRate, which is uncommon
Select BusinessTravel,round(Avg(DailyRate),2) as 'Avgerage Daily Rate'
FROM hr_analytics
GROUP BY BusinessTravel
ORDER BY 2 desc 




# Lets see how monthlyincome deal with Travel Option
	# The more you travel the less your MonthlyIncome
Select BusinessTravel,round(Avg(MonthlyIncome),2) as 'Avgerage Monthly Income '
FROM hr_analytics
GROUP BY BusinessTravel
ORDER BY 2 desc 


# which job require most travel
	# top 5 jobrole that travel frequently
SELECT JobRole,
	COUNT(case when BusinessTravel = 'Travel_Frequently' then 1 END)/ count(*) *100 "Percent of Travel_Frequently"
FROM hr_analytics
GROUP BY JobRole
order by 2 DESC
limit 5 




# If overtime affect MonthlyIncome
	# Overall, there is no big differencet in MonthlyIncome based on overtime
with cte as (
SELECT OverTime, round(Avg(MonthlyIncome),2) as 'Avgerage_Monthly_Income'
FROM hr_analytics
GROUP BY OverTime
ORDER by 2 desc
)
select Overtime, Avgerage_Monthly_Income,ifnull(round(-(previous-Avgerage_Monthly_Income)/Avgerage_Monthly_Income*100,2),0) as 'percent_difference/%'
from(
	select *, LAG(Avgerage_Monthly_Income) over (order by Avgerage_Monthly_Income desc) as previous
	from cte
) a;




# percent salary hike 
	#There isnt pretty much difference between each jobrole 
SELECT JobRole, round(Avg(PercentSalaryHike),2) as 'Average_Salary_Hike'
FROM hr_analytics
GROUP BY JobRole
order by 2 desc;

# What about job level
	#There isnt pretty much difference between each joblevel
	# but as the job level gets higher, the salaryhike decrease 
SELECT JobLevel, round(Avg(PercentSalaryHike),2) as 'Average_Salary_Hike'
FROM hr_analytics
GROUP BY JobLevel
order by 1 asc


#Which Department has the lowest PerformanceRating
	# No big differencen accross each Department
SELECT Department,round(AVG(PerformanceRating),2) 'Average PerformanceRating'
FROM hr_analytics
GROUP BY Department
ORDER BY 2 Asc

#Which JobRole has the lowest PerformanceRating
	# Although RD has the lowest rating but there isnt noticable difference accross all the jobs
SELECT JobRole,round(AVG(PerformanceRating),2) 'Average PerformanceRating'
FROM hr_analytics
GROUP BY JobRole
ORDER BY 2 Asc

# EnvironmentSatisfaction Analysis ----Department
	# There isnt big difference accross all Departments, but the average EnvironmentSatisfaction is pretty low in all Departments
	#!!!! EnvironmentSatisfaction improvment needs to be addressed
	#Department
	
SELECT Department,round(AVG(EnvironmentSatisfaction),2) 'Average EnvironmentSatisfaction',
CASE WHEN round(AVG(EnvironmentSatisfaction),2) < (SELECT round(AVG(EnvironmentSatisfaction),2) FROM hr_analytics) Then 'Below'
	   WHEN round(AVG(EnvironmentSatisfaction),2) > (SELECT round(AVG(EnvironmentSatisfaction),2) FROM hr_analytics) Then 'Above'
		 Else 'Equal'
END as 'Above/Below'
FROM hr_analytics
GROUP BY Department
ORDER BY 2 Asc


#EnvironmentSatisfaction Analysis ----JobRole
	#There isnt big difference accross all JobRole, but the average EnvironmentSatisfaction is pretty low in all JobRole
	#Needs a deeperlook in Resrach Dircetor and Human Resources as they are far below average

SELECT JobRole,round(AVG(EnvironmentSatisfaction),2) 'Average EnvironmentSatisfaction',
CASE WHEN round(AVG(EnvironmentSatisfaction),2) < (SELECT round(AVG(EnvironmentSatisfaction),2) FROM hr_analytics) Then 'Below'
	   WHEN round(AVG(EnvironmentSatisfaction),2) > (SELECT round(AVG(EnvironmentSatisfaction),2) FROM hr_analytics) Then 'Above'
		 Else 'Equal'
END as 'Above/Below'
FROM hr_analytics
GROUP BY JobRole
ORDER BY 2 Asc


# Age Distribution
 # This company has a normal age strcuture that largest age group is  26-35 following by 36-45 

SELECT AgeGroup,count(*) as Number_of_People,round(count(*) / sum(count(*)) over() *100,2) as 'Perecentage of Total'
FROM hr_analytics
GROUP BY AgeGroup


#Atrrition Rate
	# Attrion Rate is 16.08%
Select round(count(case when Attrition ='Yes' THEN 1 end)/ count(*)*100,2) as 'Atrrition Rate'
FROM hr_analytics


Select Department,round(count(case when Attrition ='Yes' THEN 1 end)/ count(*)*100,2) as 'Atrrition Rate'
FROM hr_analytics
GROUP BY Department
ORDER BY 2 desc;






# Which Jobpostion has the highest Attrition rate

Select JobRole,round(count(case when Attrition ='Yes' THEN 1 end)/ count(*)*100,2) as 'Atrrition Rate'
FROM hr_analytics
GROUP BY JobRole
ORDER BY 2 desc;



# Atrrition Rate-------------Agegroup
	#18-25 has the the highest attrition rate and followed by 26-35 and 55+
SELECT AgeGroup, round(count(case when Attrition ='Yes' THEN 1 end)/ count(*)*100,2) as 'Atrrition Rate'
FROM hr_analytics
GROUP BY AgeGroup

# Atrrition Rate-------------Distance
 # 18-25: People who left has a shorter DistanceFromHome
 # 25-36, People who left has a 3 miles longer DistanceFromHome
Select AgeGroup,Attrition, round(AVG(DistanceFromHome),2)
FROM hr_analytics
where AgeGroup ='18-25' or Agegroup  = '26-35'
GROUP BY AgeGroup,Attrition

# Atrrition Rate-------------Income
 # 18-25: People who left has 24% less income than who stayed
 # 36-35: People who left has 21.5% less income than who stayed
with cte as(
Select Agegroup, Attrition, round(AVG(MonthlyIncome),2) as 'Avgerage_Monthly_Income' 
FROM hr_analytics
where AgeGroup ='18-25' or Agegroup  = '26-35'
GROUP BY AgeGroup,Attrition
order by 3 desc 
)
select Attrition, Avgerage_Monthly_Income,ifnull(round(-(previous-Avgerage_Monthly_Income)/Avgerage_Monthly_Income*100,2),0) as 'percent_difference/%'
from(
	select *, LAG(Avgerage_Monthly_Income) over ( PARTITION BY AgeGroup order by Avgerage_Monthly_Income desc) as previous
	from cte
) a;

# Atrrition Rate-------------WorklifeBalance
	# not much difference in WorkLifeBalance

Select AgeGroup, Attrition, round(AVG(WorkLifeBalance),2)
FROM hr_analytics
where AgeGroup ='18-25'or Agegroup  = '26-35'
GROUP BY 1,2

# Atrrition Rate-------------EnvironmentSatisfaction 
 # 18-25, no difference
 # 26-35 the rate is 17.8% lower
with cte as(
Select AgeGroup, Attrition, round(AVG(EnvironmentSatisfaction),2) as 'Avg_Rate'
FROM hr_analytics
where AgeGroup ='18-25'or Agegroup  = '26-35'
GROUP BY 1,2
order by 1,2 desc
)
select AgeGroup,Attrition, Avg_Rate,ifnull(round(-(previous-Avg_Rate)/Avg_Rate*100,2),0) as 'percent_difference/%'
from(
	select *, LAG(Avg_Rate) over (PARTITION BY AgeGroup order by Avg_Rate desc) as previous
	from cte
) a;

# Atrrition Rate-------------Performancerating
	# No big difference
Select AgeGroup, Attrition, round(AVG(PerformanceRating),2)
FROM hr_analytics
where AgeGroup ='18-25'or Agegroup  = '26-35'
GROUP BY 1,2


# Atrrition Rate-------------Promotion last year
 # No big difference
Select AgeGroup, Attrition, round(AVG(YearsSinceLastPromotion),2)
FROM hr_analytics
where AgeGroup ='18-25'or Agegroup  = '26-35'
GROUP BY 1,2

#  Atrrition Rate-------------RelationshipSatisfaction
	# 18-25: 17% lower than people who stayed
	# 26-35: 5% lower than people who stayed
WITH cte as (
Select AgeGroup, Attrition, round(AVG(RelationshipSatisfaction),2) as 'Avg_Rate'
FROM hr_analytics
where AgeGroup ='18-25'or Agegroup  = '26-35'
GROUP BY 1,2
order by 3 desc
)
select AgeGroup,Attrition, Avg_Rate,ifnull(round(-(previous-Avg_Rate)/Avg_Rate*100,2),0) as 'percent_difference/%'
from(
	select *, LAG(Avg_Rate) over (PARTITION BY AgeGroup order by Avg_Rate desc) as previous
	from cte
) a;
