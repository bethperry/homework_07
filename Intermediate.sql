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



