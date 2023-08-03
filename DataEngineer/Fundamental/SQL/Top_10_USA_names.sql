
# Query bigquery-public-data.usa_names.usa_1910_2013 for the 
# name and gender of the babies in this dataset, and then list 
# the top 10 names in descending order.
SELECT
    name, gender,
    SUM(number) AS total
FROM
    `bigquery-public-data.usa_names.usa_1910_2013`
GROUP BY
    name, gender
ORDER BY
    total DESC
LIMIT
    10
