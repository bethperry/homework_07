--Convert the funding_total_usd and founded_at_clean columns in the tutorial.crunchbase_companies_clean_date table to strings (varchar format) 
--using a different formatting function for each one.

SELECT
  funding_total_usd::varchar AS funding_total_usd_varchar
  , CAST(founded_at_clean AS varchar) AS founded_at_clean_varchar 
FROM tutorial.crunchbase_companies_clean_date


--I used the postgres :: conversion operator for funding_total_usd column and the CAST() function on the founded_at_clean column.



--Write a query that counts the number of companies acquired within 3 years, 5 years, and 10 years of being founded (in 3 separate columns). 
--Include a column for total companies acquired as well. Group by category and limit to only rows with a founding date.

SELECT 
  companies.category_code
  , COUNT(companies.permalink) AS total_companies_acquired
  , SUM(CASE WHEN companies.founded_at_clean::timestamp + INTERVAL '3 years' > acquisitions.acquired_at_cleaned THEN 1 ELSE 0 END) AS acquired_within_3yr
  , SUM(CASE WHEN companies.founded_at_clean::timestamp + INTERVAL '5 years' > acquisitions.acquired_at_cleaned THEN 1 ELSE 0 END) AS acquired_within_5yr
  , SUM(CASE WHEN companies.founded_at_clean::timestamp + INTERVAL '10 years' > acquisitions.acquired_at_cleaned THEN 1 ELSE 0 END) AS acquired_within_10yr
FROM tutorial.crunchbase_companies_clean_date companies
  INNER JOIN tutorial.crunchbase_acquisitions_clean_date acquisitions
    ON acquisitions.company_permalink = companies.permalink
WHERE companies.founded_at_clean IS NOT NULL
GROUP BY companies.category_code
ORDER BY companies.category_code

--The CASE statements within the SUM() functions look to see whether the founding date plus the specified interval is later than the acquisition date.
--If so, it means the company was acquired within that interval.
--The way this is written, companies acquired within 3 years also count as having been acquired within 5 or 10 years,
--and companies acquired within 5 years also count as having been acquired within 10 years,
--so the 3yr total will always be smaller than the 5yr total, which will always be smaller than the 10yr total.



--Write a query that separates the `location` field into separate fields for latitude and longitude. 
--You can compare your results against the actual `lat` and `lon` fields in the table.

SELECT 
  location
  , TRIM(both '()' FROM location) AS trimmed_location
  , POSITION(',' IN location) AS comma_location
  , LEFT(TRIM(both '()' FROM location), POSITION(',' IN location) - 2)::numeric AS lat_cleaned
  , RIGHT(TRIM(both '()' FROM location), LENGTH(location) - POSITION(', ' IN location) - 2)::numeric AS lon_cleaned
  , lat - LEFT(TRIM(both '()' FROM location), POSITION(',' IN location) - 2)::numeric AS lat_diff
  , lon - RIGHT(TRIM(both '()' FROM location), LENGTH(location) - POSITION(', ' IN location) - 2)::numeric AS lon_diff
FROM tutorial.sf_crime_incidents_2014_01


--The actual results are in the lat_cleaned and lon_cleaned columns. I included the others to demonstrate how I worked through the problem.
--First I trimmed the () from the location field
--Then I identified the location of the comma within the location field (separating lat from lon)
--Next I used these values with the LEFT() and RIGHT() functions to bring back the portions of the string I wanted to keep
--Finally I compared my "cleaned" values with the actual lat and lon columns stored in the table (all results were 0, so I matched)

--This query is another way to do the same thing using the SUBSTR() function:

SELECT 
  location
  , POSITION('(' IN location) AS open_paren_location
  , POSITION(')' IN location) AS close_paren_location
  , POSITION(',' IN location) AS comma_location
  , LENGTH(location) AS location_length
  , SUBSTR(location, POSITION('(' IN location) + 1, POSITION(',' IN location) - POSITION('(' IN location) - 1)::numeric AS lat_cleaned
  , SUBSTR(location, POSITION(',' IN location) + 2, POSITION(')' IN location) - POSITION(',' IN location) - 2)::numeric AS lon_cleaned
  , lat - SUBSTR(location, POSITION('(' IN location) + 1, POSITION(',' IN location) - POSITION('(' IN location) - 1)::numeric AS lat_diff
  , lon - SUBSTR(location, POSITION(',' IN location) + 2, POSITION(')' IN location) - POSITION(',' IN location) - 2)::numeric AS lon_diff
FROM tutorial.sf_crime_incidents_2014_01

--I indexed the locations of the (,) characters and used them to slice the location field where I wanted to pull lat and lon
--Lat is the part of the string between the ( and the ,
--Lon is the part of the string between the , and the )



--Concatenate the lat and lon fields to form a field that is equivalent to the location field. 
--(Note that the answer will have a different decimal precision.)

SELECT 
  lat
  , lon
  , CONCAT('(', lat, ', ', lon, ')') AS concat_location
  , location
FROM tutorial.sf_crime_incidents_2014_01

--Here I used the CONCAT() function to wrap the lat and lon values in parentheses with a comma separating them: (late, lon)
--(as they are displayed within the location column)



--Create the same concatenated location field, but using the || syntax instead of CONCAT.

SELECT 
  lat
  , lon
  , CONCAT('(', lat, ', ', lon, ')') AS concat_location
  , '(' || lat || ',' || lon || ')' AS pipe_location
  , location
FROM tutorial.sf_crime_incidents_2014_01

--I added another column for the || syntax version.



--Write a query that creates a date column formatted YYYY-MM-DD

SELECT 
  date
  , LEFT(date, 10)::timestamp AS date_timestamp
  , DATE_PART('year', LEFT(date, 10)::timestamp) || '-' 
    || RIGHT('0' || DATE_PART('month', LEFT(date, 10)::timestamp), 2) || '-' 
    || RIGHT('0' || DATE_PART('day', LEFT(date, 10)::timestamp), 2) AS yyyymmdd
FROM tutorial.sf_crime_incidents_2014_01

--yyyymmdd is the completed column; the other columns explain my process
--First, I have the date column just to see the raw data I'm working with
--Next I converted just the date portion (first 10 characters) of the date column to a timestamp data type
--Finally, I added leading zeroes to month and day values that were only a single digit to get the mm and dd formats
--and concatenated them with the 4-digit year to get the desired YYYY-MM-DD format



--Write a query that returns the `category` field, but with the first letter capitalized and the rest of the letters in lower-case.

SELECT 
  category
  , UPPER(LEFT(category, 1)) || LOWER(RIGHT(category, LENGTH(category) - 1)) AS capitalized_category
FROM tutorial.sf_crime_incidents_2014_01

--I uppercased the first character in category, then lowercased the remainder of the string.
--The tutorial mentions that sometimes you just don't want your data to look like it's screaming at you, and I agree.
--But the funny thing is that in my line of work the users seem to prefer their data in all caps.
--I actually got a request once to "capitalize our database" - meaning every value in the database should be in ALL CAPS - yikes!



--Write a query that creates an accurate timestamp using the date and time columns in tutorial.sf_crime_incidents_2014_01. 
--Include a field that is exactly 1 week later as well.

SELECT 
  date
  , time
  , (LEFT(date, 10) || ' ' || time)::timestamp AS date_cleaned
  , (LEFT(date, 10) || ' ' || time)::timestamp + INTERVAL '1 week' AS one_week_later
FROM tutorial.sf_crime_incidents_2014_01

--I took the first 10 chars of the date field and concatenated them with a space and then the time field value,
--then converted the whole thing to a timestamp value.
--Finally I took that value and tacked on a 1 week interval to get the one_wekek_later value



--Write a query that counts the number of incidents reported by week. Cast the week as a date to get rid of the hours/minutes/seconds.

SELECT
  DATE_TRUNC('week', cleaned_date)::date AS week
  , LEFT(DATE_TRUNC('week', cleaned_date)::varchar, 10) AS week_no_time
  , COUNT(incidnt_num) AS total_incidents
FROM tutorial.sf_crime_incidents_cleandate
GROUP BY week, week_no_time
ORDER BY week

--I case the week as a date, as instructed, but it still showed time: 2013-10-28 00:00:00
--so I cast it as a varchar and took the first 10 characters to remove the 00:00:00



--Write a query that shows exactly how long ago each indicent was reported. Assume that the dataset is in Pacific Standard Time (UTC - 8).

SELECT 
  incidnt_num
  , cleaned_date
  , NOW() AT TIME ZONE 'PST' - cleaned_date AS time_since_incident
FROM tutorial.sf_crime_incidents_cleandate

--I tried the tutorial query:
SELECT CURRENT_TIME AS time,
       CURRENT_TIME AT TIME ZONE 'PST' AS time_pst
--but the time_pst value was exactly the same as time

--Has postgres changed the way the CURRENT_TIME value is calculated, or the way it works with AT TIME ZONE?
--My experience is primarily with Microsoft T-SQL...




--Write a query that selects all Warrant Arrests from the tutorial.sf_crime_incidents_2014_01 dataset, 
--then wrap it in an outer query that only displays unresolved incidents.

SELECT wa.*
FROM (
  SELECT *
  FROM tutorial.sf_crime_incidents_cleandate
  WHERE UPPER(descript) = 'WARRANT ARREST'
) wa
WHERE COALESCE(wa.resolution, 'NONE') = 'NONE'

--As instructed, the inner query gets all the incidents with a description of "warrant arrest".
--Then the outer query displays only the records returned by the subquery with a resolution of "none".
--I used the COALESCE() to replace any missing values with "none"; if any exist, those records would be returned also.



--Write a query that displays the average number of monthly incidents for each category. 
--Hint: use tutorial.sf_crime_incidents_cleandate to make your life a little easier.

SELECT
  category
  , COUNT(distinct month) AS total_months
  , ROUND(AVG(monthly_incidents),2) AS avg_monthly_incidents
FROM (
  SELECT
    category
    , DATE_TRUNC('month', cleaned_date)::date AS month
    , COUNT(incidnt_num) AS monthly_incidents
  FROM tutorial.sf_crime_incidents_cleandate
  GROUP BY category, month
) cat_by_month
GROUP BY category
ORDER BY avg_monthly_incidents DESC

--The subquery calculates category totals by month.
--The outer query calculates the average number of incidents using the monthly totals from the subquery.



--Write a query that displays all rows from the three categories with the fewest incidents reported.

SELECT
  incidents.*
FROM tutorial.sf_crime_incidents_2014_01 incidents
  INNER JOIN (
    SELECT
      ROW_NUMBER() OVER (ORDER BY COUNT(incidnt_num)) AS row_num
      , category
      , COUNT(incidnt_num) AS total_incidents
    FROM tutorial.sf_crime_incidents_cleandate
    GROUP BY category
  ) cat_ranks
    ON cat_ranks.category = incidents.category
    AND cat_ranks.row_num < 4 --first 3 categories only
ORDER BY cat_ranks.row_num, incidents.incidnt_num

--Since this section of the tutorial focused on using subqueries in joins, I wrote this using the tutorial.sf_crime_incidents_2014_01 
--table as my base table (aliased incidents).
--In my subquery, I used the row number windowed function to rank the categories according to the number of incidents reported.
--I did an inner join and filtered the incidents table to just the categories ranked 1, 2, and 3 (row_num < 4).
--I ordered the results according to their category rank and the incident number 
--(hypothetically, chronologically, as I would expect the incident numbers to increase over time)

--I noticed that the given answer provided by the tutorial sorts the subquery by count and then limits it to 3 results.
--In T-SQL, you can't use an ORDER BY clause within a subquery, so it's important to understand how your "flavor" of SQL works.



--Write a query that counts the number of companies founded and acquired by quarter starting in Q1 2012. 
--Create the aggregations in two separate queries, then join them.

SELECT
  COALESCE(founded.founded_quarter, acquired.acquired_quarter) AS quarter
  , COALESCE(founded.companies_founded, 0) AS companies_founded
  , COALESCE(acquired.companies_acquired, 0) AS companies_acquired
FROM (
  SELECT
    founded_quarter
    , COUNT(*) AS companies_founded
  FROM tutorial.crunchbase_companies
  WHERE founded_quarter >= '2012-Q1'
  GROUP BY founded_quarter
) founded
  FULL OUTER JOIN (
    SELECT
      acquired_quarter
      , COUNT(*) AS companies_acquired
    FROM tutorial.crunchbase_acquisitions
    WHERE acquired_quarter >= '2012-Q1'
    GROUP BY acquired_quarter
  ) acquired
    ON acquired.acquired_quarter = founded.founded_quarter
ORDER BY quarter

--The founded subquery calculates the total companies founded by quarter.
--The acquired subquery calculates the total companies acquired by quarter.
--I used a FULL OUTER JOIN in case there were quarters were only one subquery contained data.
--I did a COALESCE on the quarter to make combine the founded and acquired quarters into a single column that's more reader-friendly.
--I used COALESCE on the two totals so I could show 0 instead of NULL. 
--I tried using NVL() for this but it apparently NVL() only works for integers and the two calculated totals are bigints.
--T-SQL has an ISNULL() function that I typically use for this, but postgres doesn't have an exact equivalent.



--Write a query that ranks investors from the combined dataset above by the total number of investments they have made.

SELECT
  investments.investor_permalink
  , investments.investor_name
  , COUNT(*) AS total_investments
FROM (
  SELECT *
  FROM tutorial.crunchbase_investments_part1
  
  UNION ALL
  
  SELECT *
  FROM tutorial.crunchbase_investments_part2
) investments
GROUP BY
  investments.investor_permalink
  , investments.investor_name
ORDER BY total_investments DESC

--I unioned the two investments tables together, then grouped by investor to count the total number of investments they've made



--Write a query that does the same thing as in the previous problem, 
--except only for companies that are still operating. 
--Hint: operating status is in tutorial.crunchbase_companies.

SELECT
  investments.investor_permalink
  , investments.investor_name
  , COUNT(*) AS total_investments
FROM (
  SELECT *
  FROM tutorial.crunchbase_investments_part1
  
  UNION ALL
  
  SELECT *
  FROM tutorial.crunchbase_investments_part2
) investments
WHERE investments.company_permalink IN (SELECT permalink FROM tutorial.crunchbase_companies WHERE status = 'operating')
GROUP BY
  investments.investor_permalink
  , investments.investor_name
ORDER BY total_investments DESC

--I added the WHERE clause subquery to filter the results to count only 'operating' companies




--Write a query modification of the above example query that shows the duration of each ride as a percentage of the total time accrued by riders from each start_terminal

SELECT 
  start_terminal
  , duration_seconds
  , SUM(duration_seconds) OVER (PARTITION BY start_terminal) AS start_terminal_total
  , duration_seconds / SUM(duration_seconds) OVER (PARTITION BY start_terminal) * 100.0 AS ride_duration_pct_of_total
FROM tutorial.dc_bikeshare_q1_2012
WHERE start_time < '2012-01-08'

--The example query provided everything except ride_duration_pct_of_total.
--I added this field to calculate the percent each ride contributes to the overall duration recorded from each start terminal.



--Write a query that shows a running total of the duration of bike rides (similar to the last example), 
--but grouped by end_terminal, and with ride duration sorted in descending order.

SELECT 
  end_terminal
  , duration_seconds
  , SUM(duration_seconds) OVER (PARTITION BY end_terminal ORDER BY duration_seconds DESC) AS running_total
FROM tutorial.dc_bikeshare_q1_2012
WHERE start_time < '2012-01-08'

--The SUM() function adds up the duration_seconds.
--The PARTITION BY groups my calculation by end_terminal. 
--The ORDER BY creates the running total by having the sum increase every row, ordered from longest ride to shortest.



--Write a query that shows the 5 longest rides from each starting terminal, ordered by terminal, and longest to shortest rides within each terminal. 
--Limit to rides that occurred before Jan. 8, 2012.

SELECT *
FROM (
  SELECT
    start_terminal
    , bike_number
    , duration_seconds
    , RANK() OVER (PARTITION BY start_terminal ORDER BY duration_seconds DESC) AS ride_rank
  FROM tutorial.dc_bikeshare_q1_2012
  WHERE start_time < '1/8/2012'
) rides
WHERE rides.ride_rank <= 5
ORDER BY start_terminal, duration_seconds DESC

--I used a subquery to calculate the rank of eadh ride within each start terminal.
--In the outer query I limited the results to just the top 5 for each start terminal 
--(since postgres doesn't allow use of windowed functions within the WHERE or HAVING clauses).



--Write a query that shows only the duration of the trip and the percentile into which that duration falls (across the entire dataset—not partitioned by terminal).

SELECT
  duration_seconds
  , NTILE(100) OVER (ORDER BY duration_seconds) AS percentile
FROM tutorial.dc_bikeshare_q1_2012
ORDER BY duration_seconds

--This returns a whole lotta rows.
--But I can see it being useful as a subquery when you want to get all records within a particular percentile threshold.



