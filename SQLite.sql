CREATE TABLE applestore_description_combined  AS

SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

** EXPLORATORY DATA ANALYSIS**
-- check the number of unique apps in both tables.

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT (DISTINCT id) AS UniqueAppIDs
FROM applestore_description_combined 

-- check for any missing values in key fields.AppleStore. 

SELECT COUNT(*) As MissingValues
FROM AppleStore 
WHERE track_name IS null OR user_rating IS null OR prime_genre IS NULL

SELECT count (*) AS MissingValues
FROM applestore_description_combined
WHERE app_desc IS NULL 

-- Find out the number of apps per genre 

SELECT prime_genre, COUNT (*) AS NumApps
FROM AppleStore
GROUP BY prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps' ratings. 

SELECT min(user_rating) AS Minrating,
       max(user_rating) AS MaxRating,
       avg(user_rating) as AvgRating
FROM AppleStore        

-- Get the distribution of app prices. 

SELECT 
      (price / 2) * 2 AS PriceBinStart,
      ((price / 2) * 2) +2 AS PriceBinEnd,
      count (*) AS NumApps
FROM AppleStore
GROUP by PriceBinStart
ORDER by PriceBinStart

** DATA ANALYSIS **
 --Determine whether paid apps have higher ratings than free apps. 
 
 SELECT CASE
            when price >0 THEN 'Paid'
            else 'Free'
            END AS App_Type,
            avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY App_Type

-- Check if apps with more supported languages have higher ratings. 

SELECT CASE 
          WHEN lang_num <10 THEN '<10 languages'
          when lang_num BETWEEN 10 AND 30 THEN '10-30 languages'
          else '>30 languages'
END AS language_bucket,
       avg(user_rating) AS Avg_Rating
       
FROM AppleStore
GROUP by language_bucket
ORDER by Avg_Rating DESC

-- check genres with low ratings. 

SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
group by prime_genre
ORDER by Avg_Rating ASC 
LIMIT 10

-- check if there is correlation between the length of the app description & the user rating. 

SELECT CASE 
       when length(b.app_desc) < 500 THEN 'short'
       when length(b.app_desc) BETWEEN 500 and 1000 then 'Medium'
       else 'Long'
       end as description_length_bucket,
       avg(a.user_rating) as average_rating
from AppleStore as a 
join applestore_description_combined as b 
on a.id = b.id
GROUP by description_length_bucket
order by average_rating DESC 

-- check the top-rated apps for each genre. 

SELECT prime_genre,
       track_name,
       user_rating
FROM (
       SELECT prime_genre,
              track_name,
              user_rating,
              RANK() OVER(PARTITION BY prime_genre ORDER by user_rating DESC, rating_count_tot desc) as rank
       from AppleStore
     ) as A
 where a.rank=1    