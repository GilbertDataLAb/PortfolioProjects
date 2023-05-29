/*
Hotel Data Analysis

This repository focuses on performing simple calculations to answer specific questions related to hotel data analysis. 
The dataset used for this analysis includes hotel data from a specific time period or source.

The goal of this analysis is to extract meaningful insights and provide answers to key questions regarding the hotel industry. 
Although the calculations performed are straightforward, they serve as a foundation for understanding various aspects of hotels.

Here are some of the questions answered by my analysis:

-What is the total revenue generated by each hotel in each year?
-How does the revenue vary across different hotels and years?
-What is the total discount amount for each hotel in each year?
-How do discounts impact the overall revenue of each hotel?
-How many parking spaces were used in each year?
-What is the total count of used parking spaces?

These are just a few examples, and the calculations performed can be tailored to address specific questions or goals 
of the analysis. The simplicity of the calculations allows for a clear understanding of the metrics and facilitates effective 
decision-making in the hotel industry.

Feedback and suggestions for further analysis or improvements are always welcome. Thank you for your interest in this project!

*/


----------------------------------------------------------------------------------------------------------

-- Combine Tables (year)
-- Temp Table

SELECT *
INTO #Hotels
FROM (
    SELECT *
    FROM PortfolioProject..yr2018
    UNION
    SELECT *
    FROM PortfolioProject..yr2019
    UNION
    SELECT *
    FROM PortfolioProject..yr2020
) AS Hotels;


-- Combine Discount table

SELECT * 
FROM #Hotels ho
LEFT JOIN PortfolioProject..market_segment mar
	ON ho.market_segment = mar.market_segment




-- Revenue

SELECT arrival_date_year, hotel
,ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights)*adr), 2) AS Revenue
FROM #Hotels
GROUP BY arrival_date_year, hotel
ORDER BY hotel, arrival_date_year



-- Discount
SELECT ho.arrival_date_year, ho.hotel,
       ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr * (mar.discount / 100)), 2) AS TotalDiscount,
       ROUND(AVG((mar.discount/ 100) * 100), 2) AS DiscountPercentage
FROM #Hotels ho
LEFT JOIN PortfolioProject..market_segment mar
    ON ho.market_segment = mar.market_segment
GROUP BY ho.arrival_date_year, ho.hotel
ORDER BY ho.arrival_date_year, ho.hotel



-- Total Revenue Less Discount

SELECT
    ho.arrival_date_year, ho.hotel,
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr), 2) AS TotalRevenue,
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr * (mar.discount / 100)), 2) AS TotalDiscount,
    ROUND(SUM((stays_in_weekend_nights + stays_in_week_nights) * adr) - SUM((stays_in_weekend_nights + stays_in_week_nights) * adr * (mar.discount / 100)), 2) AS RevenueLessDiscount
FROM #Hotels ho
LEFT JOIN PortfolioProject..market_segment mar ON ho.market_segment = mar.market_segment
GROUP BY ho.arrival_date_year, ho.hotel
ORDER BY ho.arrival_date_year, ho.hotel



-- Parking space


-- Parking spaced used through 2018-2020
SELECT arrival_date_year, COUNT(required_car_parking_spaces) AS TotalCarSpace
FROM #Hotels
WHERE required_car_parking_spaces <> 0
GROUP BY arrival_date_year
ORDER BY arrival_date_year


-- Total Parking Space Used
SELECT COUNT(required_car_parking_spaces) AS TotalCarSpace
FROM #Hotels
WHERE required_car_parking_spaces <> 0
--GROUP BY required_car_parking_spaces


-- Car Space Percentage
SELECT ROUND(SUM(required_car_parking_spaces)/SUM(stays_in_weekend_nights + stays_in_week_nights)*100, 2) AS PercentageCarSpacesPerStay
FROM #Hotels


-- Car Space Percentage each Year by Hotel
SELECT arrival_date_year, hotel
, COUNT(required_car_parking_spaces) AS TotalCarSpaceUsed
, ROUND(SUM(required_car_parking_spaces)/SUM(stays_in_weekend_nights + stays_in_week_nights)*100, 2) AS PercentageCarSpacesPerStay
FROM #Hotels
WHERE required_car_parking_spaces <> 0
GROUP BY arrival_date_year, hotel
ORDER BY arrival_date_year, hotel

