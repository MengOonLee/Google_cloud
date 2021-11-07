-- Total Confirmed Cases
SELECT
  SUM(cumulative_confirmed) AS total_cases_worldwide
FROM 
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE 
  date="2020-04-15";



-- Worst Affected Areas
WITH
deaths_by_US_states AS (
  SELECT
    subregion1_name AS state,
    SUM(cumulative_deceased) AS total_deaths
  FROM 
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE 
    country_name="United States of America"
    AND date="2020-04-10"
    AND subregion1_name IS NOT NULL
  GROUP BY
    subregion1_name
)
SELECT
  COUNT(state) AS count_of_states
FROM 
  deaths_by_US_states
WHERE
  total_deaths>100;



-- Identifying Hotspots
SELECT
  subregion1_name AS state,
  SUM(cumulative_confirmed) AS total_confirmed_cases
FROM 
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE 
  country_name="United States of America"
  AND date="2020-04-10"
  AND subregion1_name IS NOT NULL
GROUP BY
  subregion1_name
HAVING
  total_confirmed_cases>1000
ORDER BY 
  total_confirmed_cases DESC;



-- Fatality Ratio
SELECT
  SUM(cumulative_confirmed) AS total_confirmed_cases,
  SUM(cumulative_deceased) AS total_deaths,
  (SUM(cumulative_confirmed)/SUM(cumulative_deceased))*100 AS case_fatality_ratio
FROM 
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE 
  country_name="Italy"
  AND date BETWEEN "2020-04-01" AND "2020-04-30";



-- Identifying specific day
SELECT
  date
FROM 
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name="Italy"
  AND cumulative_deceased>10000
ORDER BY
  date
LIMIT 1;



-- Finding days with zero net new cases
WITH india_cases_by_date AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="India"
    AND date between "2020-02-21" and "2020-03-15"
  GROUP BY
    date
  ORDER BY
    date ASC
),
india_previous_day_comparison AS
(SELECT
  date,
  cases,
  LAG(cases) OVER(ORDER BY date) AS previous_day,
  cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
FROM 
  india_cases_by_date
)
SELECT
  COUNT(date)
FROM
  india_previous_day_comparison
WHERE
  net_new_cases=0;



-- Doubling rate
WITH us_cases_by_date AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="United States of America"
    AND date BETWEEN "2020-03-22" AND "2020-04-20"
  GROUP BY
    date
  ORDER BY
    date
),
us_previous_day_comparison AS
(SELECT
  date AS Date,
  cases AS Confirmed_Cases_On_Day,
  LAG(cases) OVER(ORDER BY date) AS Confirmed_Cases_Previous_Day,
  (cases - LAG(cases) OVER(ORDER BY date))/(LAG(cases) OVER(ORDER BY date))*100 AS Percentage_Increase_In_Cases
FROM 
  us_cases_by_date
)
SELECT
  *
FROM
  us_previous_day_comparison
WHERE
  Percentage_Increase_In_Cases>10;



-- Recovery rate
WITH cases_by_country AS (
SELECT
  country_name AS country,
  SUM(cumulative_recovered) AS recovered_cases,
  SUM(cumulative_confirmed) AS confirmed_cases
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date="2020-05-10"
GROUP BY
  country_name
)
SELECT
  *,
  recovered_cases/confirmed_cases AS recovery_rate
FROM
  cases_by_country
WHERE
  confirmed_cases>50000
ORDER BY
  recovery_rate DESC
LIMIT 10;



-- CDGR - Cumulative Daily Growth Rate
WITH france_cases AS (
  SELECT
    date,
    SUM(cumulative_confirmed) AS total_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE
    country_name="France"
    AND date IN ("2020-01-24", "2020-05-10")
  GROUP BY
    date
  ORDER BY
    date
), 
summary as (
SELECT
  total_cases AS first_day_cases,
  LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
  DATE_DIFF(LEAD(date) OVER(ORDER BY date), date, day) AS days_diff
FROM
  france_cases
LIMIT 1
)
SELECT 
  first_day_cases,
  last_day_cases,
  days_diff,
  POW((last_day_cases/first_day_cases), (1/days_diff)) - 1 as cdgr
FROM
  summary;



-- Create a Datastudio report
SELECT
  date,
  SUM(cumulative_confirmed) AS country_cases,
  SUM(cumulative_deceased) AS country_deaths
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name="United States of America"
  AND date BETWEEN '2020-03-15' AND '2020-04-30'
GROUP BY date