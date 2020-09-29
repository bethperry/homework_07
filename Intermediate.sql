--Write a query to count the number of non-null rows in the low column.

SELECT COUNT(low)
FROM tutorial.aapl_historical_stock_price
--3535

--When used on a single column, the COUNT() function returns the number of non-null values in that column (in this case, low) 


--Write a query that determines counts of every single column. Which column has the most null values?

SELECT
  COUNT(date) AS date_count
  , COUNT(year) AS year_count
  , COUNT(month) AS month_count
  , COUNT(open) AS open_count
  , COUNT(high) AS high_count
  , COUNT(low) AS low_count
  , COUNT(close) AS close_count
  , COUNT(volume) AS volume_count
  , COUNT(id) AS id_count
FROM tutorial.aapl_historical_stock_price

--The high column contains the most NULL values, because it returns the lowest COUNT() result - 3,531 non-null values



--Write a query to calculate the average opening price (hint: you will need to use both COUNT and SUM, as well as some simple arithmetic.).

SELECT
  SUM(open) / COUNT(open) AS avg_aapl_open_price
  , AVG(open) AS avg_open
FROM tutorial.aapl_historical_stock_price

--So the tutorial is suggesting I should do the SUM divided by the COUNT of open, which does calculate the average value of the column
--However, there is a simpler way to get the same result, which is to use the AVG() function



--What was Apple's lowest stock price (at the time of this data collection)?

SELECT
  MIN(low)
FROM tutorial.aapl_historical_stock_price
--6.36

--The minimum "low" value recorded in the table is 6.36.



--What was the highest single-day increase in Apple's share value?

SELECT
  MAX(close - open) AS max_single_day_increase
FROM tutorial.aapl_historical_stock_price
--32.58

--An increase over a single day should mean that the close was higher than the open.
--The difference between close and open would give you the magnitude of that increase.
--The boggest single-day increase would be the maximum difference between the close and open values.



--Write a query that calculates the average daily trade volume for Apple stock.

SELECT
  AVG(volume) AS avg_daily_trading_volume
FROM tutorial.aapl_historical_stock_price
--20745814.34536228

--Since the table holds one row per day, averaging the volume column provides the average daily trading volume.



--Calculate the total number of shares traded each month. Order your results chronologically.

SELECT
  year
  , month
  , SUM(volume) AS shares_traded
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
ORDER BY year, month

--This query groups the table by year and month and adds up the volume column for each group.
--I know the instructions just said by month, but I added year so the results could truly be ordered chronologically.
--Grouping just by month would have grouped January of all years together, February of all years together, etc.



--Write a query to calculate the average daily price change in Apple stock, grouped by year.

SELECT
  year
  , AVG(close - open) AS avg_daily_price_change
FROM tutorial.aapl_historical_stock_price
GROUP BY year
ORDER BY year

--I selected close - open as the base calculation for daily price change (rather than open - close) to make the results easier to interpret:
--An increase in price would be a positive number and a decrease in price would be a negative number



--Write a query that calculates the lowest and highest prices that Apple stock achieved each month.

SELECT
  year
  , month
  , MIN(low) AS lowest_price
  , MAX(high) AS highest_price
FROM tutorial.aapl_historical_stock_price
GROUP BY year, month
ORDER BY year, month

--The minimum low should be the lowest price and the maximum high should be the highest price.
--When grouped by year and month, this gives the lowest and highest prices for each individual month included in the table.

--In this case, you could omit year from the group by and order by if you believe there is a seasonal pattern to the Apple stock prices.
--The query below would tell you the lowest and highest prices for January across all years, February across all years, etc:

--month	lowest_price	highest_price
--1	    6.78	        560.2
--2	    7.03	        547.61
--3	    7.02	        621.45
--4	    6.36	        644
--5	    7	            596.76
--6	    7.99	        590
--7	    6.9	          619.87
--8	    6.98	        680.87
--9	    7.02	        705.07
--10	  6.68	        676.75
--11	  7.5	          603
--12	  6.81	        594.59

--However, in Apple's case, the price has varied too much over the years for this to provide meaningful information.
--This query makes it look like there is considerably more intra-month volatility than there really has been.




--Write a query that includes a column that is flagged "yes" when a player is from California, and sort the results with those players first.

SELECT
  player_name
  , CASE state 
      WHEN 'CA' THEN 'yes' 
      ELSE NULL 
    END AS is_from_california
FROM benn.college_football_players
ORDER BY is_from_california, player_name

--This query checks whether the state column has a value of CA.
--If it does, the is_from_california field will say "yes".




--Write a query that includes players' names and a column that classifies them into four categories based on height. 
--Keep in mind that the answer we provide is only one of many possible answers, since you could divide players' heights in many ways.

SELECT
  player_name
  , height
  , CASE
      WHEN height >= 78 THEN '4 - really tall'
      WHEN height >= 72 AND height < 78 THEN '3 - tall'
      WHEN height >= 69 AND height < 72 THEN '2 - average'
      WHEN height < 69 THEN '1 - short'
    END AS height_classification
FROM benn.college_football_players
WHERE height > 0 --There seems to be some bad data in the table; I'm ignoring it for the sake of this query
ORDER BY height

--I divided the players into 4 categories based on semi-arbitrary height values.
--Shorter than 5'9", I deemed to be "short"
--Between 5'9" and 6' (exclusive), I labeled "average"
--Between 6' and 6'6" (exclusive), I called "tall"
--Anything 6'6" or taller is considered "really tall"
--(The numbers were selected based on my personal recollections of average/typical male heights in the U.S., nothing official.)

--I added a numeric prefix to each category before I decided to add in the height column itself; 
--the numeric prefix makes it easy to order these records by category from short to really tall, which could be helpful for visualization.

--Because I sorted by height, I discovered several records where the height was entered as 0.
--Since no football player is zero inches tall, this must be bad data.
--My choice for this question was to filter it out; but I could have also added another category called "Not Provided" or something similar as a label for these



--Write a query that selects all columns from benn.college_football_players and adds an additional column that displays the player's name if that player is a junior or senior.

SELECT
  full_school_name
  , school_name
  , player_name
  , position
  , height
  , weight
  , year
  , hometown
  , state
  , CASE
      WHEN year = 'JR' OR year = 'SR' THEN player_name
    END AS jr_sr_player_name
FROM benn.college_football_players

--There are multiple ways to write this case statement. 
--My preference would actually be CASE WHEN year IN ('JR','SR') THEN player_name END
--However, since the lesson was about using multiple conditions within a single WHEN statement, I opted for this way.



--Write a query that counts the number of 300lb+ players for each of the following regions: West Coast (CA, OR, WA), Texas, and Other (Everywhere else).

SELECT
  CASE 
    WHEN state IN ('CA', 'OR', 'WA') THEN 'West Coast'
    WHEN state = 'TX' THEN 'Texas'
    ELSE 'Other'
  END AS region
  , COUNT(1) AS total_300lb_players
FROM benn.college_football_players
WHERE weight >= 300 --players weighing 300+ pounds
GROUP BY region

--I created a region field using the conditions specified by the question, then used that as my group to count the number of players
--Since the query is filtered to players with weight >= 300 lbs, this group counts the total 300lb+ players in each region.



--Write a query that calculates the combined weight of all underclass players (FR/SO) in California 
--as well as the combined weight of all upperclass players (JR/SR) in California.

SELECT
  state
  , CASE 
      WHEN year IN ('FR', 'SO') THEN 'Underclass'
      WHEN year IN ('JR', 'SR') THEN 'Upperclass'
      ELSE 'Other'
    END AS yr_class
  , SUM(weight) AS total_player_weight
FROM benn.college_football_players
WHERE state = 'CA'
GROUP BY yr_class, state

--I divided the players into underclass and upperclass based on their year value, with an "Other" category to catch bad data.
--Then I filtered the query to state = 'CA' and totaled the weight to answer to question.



--Write a query that displays the number of players in each state, with FR, SO, JR, and SR players in separate columns 
--and another column for the total number of players. 
--Order results such that states with the most players come first.

SELECT
  state
  , SUM(CASE WHEN year = 'FR' THEN 1 ELSE 0 END) AS FR_total
  , SUM(CASE WHEN year = 'SO' THEN 1 ELSE 0 END) AS SO_total
  , SUM(CASE WHEN year = 'JR' THEN 1 ELSE 0 END) AS JR_total
  , SUM(CASE WHEN year = 'SR' THEN 1 ELSE 0 END) AS SR_total
  , COUNT(1) AS total_players
FROM benn.college_football_players
GROUP BY state
ORDER BY total_players DESC

--I used CASE statements within aggregate functions to selectively count the number of players by year with the results in separate columns



--Write a query that shows the number of players at schools with names that start with A through M, and the number at schools with names starting with N - Z.

SELECT
  SUM(CASE WHEN LEFT(school_name, 1) < 'N' THEN 1 ELSE 0 END) AS a_to_m_school_players
  , SUM(CASE WHEN LEFT(school_name, 1) >= 'N' THEN 1 ELSE 0 END) AS n_to_z_school_players
FROM benn.college_football_players

--This CASE statement looks at the first letter of the school name, then selectively counts 1 for each row (player) that matches.
--There's no need to group by anything since we just want the overall totals for A-M and N-Z.



--Write a query that returns the unique values in the year column, in chronological order.

SELECT DISTINCT year
FROM tutorial.aapl_historical_stock_price
ORDER BY year

--The DISTINCT operator returns just the unique values for the column(s) specified.
--The ORDER BY puts the results in chronological order.



--Write a query that counts the number of unique values in the month column for each year.

SELECT 
  year
  , COUNT(distinct month) AS unique_months
FROM tutorial.aapl_historical_stock_price
GROUP BY year
ORDER BY year

--I grouped by year and did a distinct count of months to answer the question.
--There are 12 distinct months for each year in the table EXCEPT for 2014, which contains data from only 1 month



--Write a query that separately counts the number of unique values in the month column and the number of unique values in the `year` column.

SELECT
  COUNT(distinct year) AS unique_years
  , COUNT(distinct month) AS unique_months
FROM tutorial.aapl_historical_stock_price

--The dataset contains 15 unique years (2000 to 2014) and 12 unique months (1-12).
--This is different than:
--SELECT DISTINCT year, month FROM tutorial.aapl_historical_stock_price
--which would return all the unique combinations of year and month (2000, 1; 2000, 2; 2001, 1; etc.)



--Write a query that selects the school name, player name, position, and weight for every player in Georgia, ordered by weight (heaviest to lightest). 
--Be sure to make an alias for the table, and to reference all column names in relation to the alias.

SELECT
  players.school_name
  , players.player_name
  , players.position
  , players.weight
FROM benn.college_football_players players
WHERE players.state = 'GA'
ORDER BY players.weight DESC

--I aliased the benn.college_football_players table 'players', like the tutorial showed in a previous example.
--I prefaced each field with that alias.
--This query doesn't really need an alias since it doesn't have any joins, 
--but I wholeheartedly agree with the philosophy that if your table has an alias, your fields should reference it.
--This is very important when working with queries with many joins.



--Write a query that displays player names, school names and conferences for schools in the "FBS (Division I-A Teams)" division.

SELECT
  players.player_name
  , teams.school_name
  , teams.division
FROM benn.college_football_players players
  INNER JOIN benn.college_football_teams teams
    ON teams.school_name = players.school_name
WHERE teams.division = 'FBS (Division I-A Teams)'
ORDER BY teams.school_name, players.player_name

--I used an INNER JOIN to bring back all the rows from the teams table where the school name matched the school name on the players table.
--Then I further filtered the results to only records where the team's division was FBS (Division I-A Teams).
--If I'd used a LEFT OUTER JOIN here instead of the INNER JOIN, the WHERE clause would have effectively turned it into an INNER JOIN
--because the division name can't be 'FBS (Division I-A Teams)' if the teams table doesn't match up with that players record.
--I see this confuse a lot of people who are less experienced with SQL - they use a LEFT OUTER JOIN thinking they are properly handling NULL values,
--then undo their NULL handling with a condition in their WHERE clause.



--Write a query that performs an inner join between the tutorial.crunchbase_acquisitions table and the tutorial.crunchbase_companies table, 
--but instead of listing individual rows, count the number of non-null rows in each table.

SELECT 
  COUNT(companies.permalink) AS companies_non_null
  , COUNT(acquisitions.company_permalink) AS acquisitions_non_null
FROM tutorial.crunchbase_companies companies
  INNER JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
--1673 for both counts

--The INNER JOIN requires both tables to match to bring back a result. 
--Since I'm counting the keys used to perform the join, the counts are going to be the same.



--Modify the query above to be a LEFT JOIN. Note the difference in results.

SELECT 
  COUNT(companies.permalink) AS companies_non_null
  , COUNT(acquisitions.company_permalink) AS acquisitions_non_null
FROM tutorial.crunchbase_companies companies
  LEFT OUTER JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
--27355 for companies, 1673 for acquisitions

--Now that the query uses a LEFT OUTER JOIN, it's able to return all the permalink values from the companies table.
--It only returns company_permalink values from the acquisitions table if they match up to a companies.permalink value
--(so you see the number that matched, like in the INNER JOIN example above).



--Count the number of unique companies (don't double-count companies) and unique acquired companies by state. 
--Do not include results for which there is no state data, and order by the number of acquired companies from highest to lowest.

SELECT 
  COALESCE(companies.state_code, acquisitions.company_state_code) AS state_code
  , COUNT(distinct companies.permalink) AS unique_companies
  , COUNT(distinct acquisitions.company_permalink) AS unique_acquired_companies
FROM tutorial.crunchbase_companies companies
  LEFT OUTER JOIN tutorial.crunchbase_acquisitions acquisitions
    ON companies.permalink = acquisitions.company_permalink
WHERE COALESCE(companies.state_code, acquisitions.company_state_code) IS NOT NULL
GROUP BY COALESCE(companies.state_code, acquisitions.company_state_code)
ORDER BY unique_acquired_companies DESC

--I calculated the distinct counts for both permalink fields. 
--I opted to count the permalink values rather than company names in case multiple companies have the same name, but are, in fact, distinct companies.
--The COALESCE() statements are meant to handle the instruction "do not include results for which there is no state data".
--COALESCE() returns the first non-null value from the series of fields listed within the parentheses.
--In this instance, I'll bring back the state_code from companies first; if that's NULL, I'll check the company_state_code from acquisitions.
--If they're both NULL (i.e., there's no state data), I'll filter out the record.
--This is definitely an argument in favor of normalization - why does the state data reside in multiple tables? 
--Having it in multiple places makes it much more likely to get out of sync, so your answer would change depending on the table you source the field from.



--Rewrite the previous practice query in which you counted total and acquired companies by state, but with a RIGHT JOIN instead of a LEFT JOIN. 
--The goal is to produce the exact same results.

SELECT 
  COALESCE(companies.state_code, acquisitions.company_state_code) AS state_code
  , COUNT(distinct companies.permalink) AS unique_companies
  , COUNT(distinct acquisitions.company_permalink) AS unique_acquired_companies
FROM tutorial.crunchbase_acquisitions acquisitions 
  RIGHT OUTER JOIN tutorial.crunchbase_companies companies
    ON companies.permalink = acquisitions.company_permalink
WHERE COALESCE(companies.state_code, acquisitions.company_state_code) IS NOT NULL
GROUP BY COALESCE(companies.state_code, acquisitions.company_state_code)
ORDER BY unique_acquired_companies DESC

--I flipped the tables so I join FROM acquisitions TO companies instead of from companies to acquisitions
--Like the tutorial said, in my experience RIGHT OUTER JOINS are rarely used



--Write a query that shows a company's name, "status" (found in the Companies table), and the number of unique investors in that company. 
--Order by the number of investors from most to fewest. Limit to only companies in the state of New York.

SELECT 
  company.name AS company_name
  , company.status
  , COUNT(distinct investor_permalink) AS unique_investors
FROM tutorial.crunchbase_companies company
  INNER JOIN tutorial.crunchbase_investments invest
    ON company.permalink = invest.company_permalink
    AND company.state_code = 'NY'
GROUP BY company.name, company.status
ORDER BY unique_investors DESC

--Here I elected to take the company name and status from the company table (figuring it should have the "most correct" company name)
--and count the distinct investor permalink values from the investors table so each investor only gets counted once, 
--regardless of how many times they invested in the company.
--Since the exercise is inside the tutorial portion that talks about filtering as part of the ON clause, I filtered my state there.
--I used an INNER JOIN because, well... the next exercise uses an outer join :)




--Write a query that lists investors based on the number of companies in which they are invested. 
--Include a row for companies with no investor, and order from most companies to least.

SELECT
  invest.investor_name
  , COUNT(distinct company.permalink) AS companies_invested
FROM tutorial.crunchbase_investments invest
  RIGHT OUTER JOIN tutorial.crunchbase_companies company
    ON company.permalink = invest.company_permalink
GROUP BY invest.investor_name
ORDER BY companies_invested DESC

--This problem was worded a bit oddly, but I think the query provides the requested data.
--I grouped by investor name, but I did a RIGHT OUTER JOIN here so investor_name could be NULL 
--(i.e., the results include companies with no investors).




--Write a query that joins tutorial.crunchbase_companies and tutorial.crunchbase_investments_part1 using a FULL JOIN. 
--Count up the number of rows that are matched/unmatched as in the example above.

SELECT 
  COUNT(CASE WHEN companies.permalink IS NOT NULL AND part1.company_permalink IS NULL THEN companies.permalink ELSE NULL END) AS companies_only
  , COUNT(CASE WHEN companies.permalink IS NOT NULL AND part1.company_permalink IS NOT NULL THEN companies.permalink ELSE NULL END) AS both_tables
  , COUNT(CASE WHEN companies.permalink IS NULL AND part1.company_permalink IS NOT NULL THEN part1.company_permalink ELSE NULL END) AS investments_p1_only
FROM tutorial.crunchbase_companies companies
  FULL JOIN tutorial.crunchbase_investments_part1 part1
    ON companies.permalink = part1.company_permalink

--Because the permalink and company_permalink are always populated for their respective tables, essentially:
--Wherever companies.permalink is NULL, the record is only in the investments part 1 table
--Wherever part1.company_permalink is NULL, the record is only in the companies table
--If they're both populated, the record has data in both tables

--Proof the permalink columns are always populated:
SELECT COUNT(*) FROM tutorial.crunchbase_companies WHERE permalink IS NULL --count = 0
SELECT COUNT(*) FROM tutorial.crunchbase_investments_part1 WHERE company_permalink IS NULL --count = 0



--Write a query that appends the two crunchbase_investments datasets above (including duplicate values). 
--Filter the first dataset to only companies with names that start with the letter "T", 
--and filter the second to companies with names starting with "M" (both not case-sensitive). 
--Only include the company_permalink, company_name, and investor_name columns.

SELECT
  p1.company_permalink
  , p1.company_name
  , p1.investor_name
FROM tutorial.crunchbase_investments_part1 p1
WHERE p1.company_name ILIKE ('T%')

UNION ALL

SELECT
  p2.company_permalink
  , p2.company_name
  , p2.investor_name
FROM tutorial.crunchbase_investments_part2 p2
WHERE p2.company_name ILIKE ('M%')

--As requested, I filtered the first query on companies starting with T and the second on companies starting wtih M
--I used UNION ALL to allow for duplicates (although there won't be any, because there's no logical way for the company name to start with both T and M)
--I included the 3 columns requested. Both queries return these in the same order to support the UNION ALL operator



--Write a query that shows 3 columns. 
--The first indicates which dataset (part 1 or 2) the data comes from, 
--the second shows company status, 
--and the third is a count of the number of investors.

--Hint: you will have to use the tutorial.crunchbase_companies table as well as the investments tables. And you'll want to group by status and dataset.

SELECT
  'Part 1' AS data_source
  , c.status AS company_status
  , COUNT(distinct p1.investor_permalink) AS total_investors
FROM tutorial.crunchbase_companies c
  LEFT OUTER JOIN tutorial.crunchbase_investments_part1 p1
    ON p1.company_permalink = c.permalink
GROUP BY c.status

UNION ALL

SELECT
  'Part 2' AS data_source
  , c.status AS company_status
  , COUNT(distinct p2.investor_permalink) AS total_investors
FROM tutorial.crunchbase_companies c
  LEFT OUTER JOIN tutorial.crunchbase_investments_part2 p2
    ON p2.company_permalink = c.permalink
GROUP BY c.status

--The top query gets the data from the part1 table and aggregates it by status
--The bottom query gets the data from the part2 tablr and aggregates by status
--The UNION ALL operator appends the second result set to the first
--I created a column called 'data source' to hold the Part 1/Part 2 labels 