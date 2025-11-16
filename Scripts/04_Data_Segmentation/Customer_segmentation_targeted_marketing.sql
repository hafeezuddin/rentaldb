/*
We have $50,000 allocated for a Q1 2006 customer reactivation campaign. With thousands of 2005 customers, 
we need to strategically target those most likely to respond to our offers.
Your Mission: Identify which 2005 customers to target, determine the optimal offer for each segment, 
and ensure we maximize ROI within our budget constraints.

ANALYTICAL REQUIREMENTS
METRIC 1: CUSTOMER HEALTH SCORE (0-100 Points)

A. Recency Score (25 points)
    Last rental in December 2005: 25 points
    Last rental in November 2005: 20 points
    Last rental in October 2005: 15 points
    Last rental in July-September 2005: 10 points
    Last rental in January-June 2005: 5 points

B. Frequency Score (25 points)
    15+ rentals in 2005: 25 points
    10-14 rentals: 20 points
    6-9 rentals: 15 points
    3-5 rentals: 10 points
    1-2 rentals: 5 points

C. Monetary Score (25 points)
    Top 20% of 2005 spenders: 25 points
    Next 30% of spenders: 20 points
    Middle 30% of spenders: 15 points
    Next 10% of spenders: 10 points
    Bottom 10% of spenders: 5 points

D. Category Loyalty Score (25 points)
    80%+ of rentals in top 2 categories: 25 points
    60-79% in top 2 categories: 20 points
    40-59% in top 2 categories: 15 points
    20-39% in top 2 categories: 10 points
    <20% category concentration: 5 points



METRIC 2: REACTIVATION PROBABILITY SCORE (0-100 Points)

A. Seasonal Pattern Score (50 points)

    Rented in BOTH November & December 2005: 50 points

    Rented in EITHER November or December: 30 points

    No holiday period rentals: 10 points

B. Rental Gap Analysis (50 points)

    Average days between rentals < 30 days: 50 points

    Average days between rentals 30-60 days: 30 points

    Average days between rentals 60-90 days: 20 points

    Average days >90 days OR only one rental: 10 points


CUSTOMER SEGMENTATION & OFFER STRATEGY

SEGMENT 1: CHAMPIONS

    Criteria: Health Score ≥ 80 AND Probability Score ≥ 80

    Offer: Exclusive loyalty rewards (early access to new releases)

    Max Bid Price: $15 per customer

SEGMENT 2: AT-RISK LOYALISTS

    Criteria: Health Score ≥ 70 AND Probability Score < 60

    Offer: "We Miss You" 25% discount

    Max Bid Price: $12 per customer

SEGMENT 3: RISING STARS

    Criteria: Health Score 60-79 AND Probability Score ≥ 70

    Offer: New release promotions + free rental

    Max Bid Price: $10 per customer

SEGMENT 4: CASUAL VIEWERS

    Criteria: Health Score < 60 AND Probability Score ≥ 50

    Offer: Budget bundle packages

    Max Bid Price: $7 per customer

SEGMENT 5: INACTIVE

    Criteria: All other customers

    Offer: Win-back trial offer

    Max Bid Price: $5 per customer

DELIVERABLE REQUIREMENTS

Final Output Must Include:

    customer_id, first_name, last_name, email

    health_score, probability_score, composite_score

    customer_segment, recommended_offer, max_bid_price

    top_category_1, top_category_2, category_concentration_pct

    total_2005_spent, last_rental_date, total_2005_rentals

Business Rules:

    Sort customers by composite_score DESC (Health × Probability)

    Apply budget constraint: Sum of max_bid_price ≤ $50,000

    Include only customers with at least one 2005 rental

    All calculations based on 2005 data only */


--CTE to calculate Metric #1: recency_score
WITH recency_score AS (
    SELECT sq1.customer_id, 
    sq1.latest_rental_month,
    CASE
        WHEN sq1.latest_rental_month = 12
            THEN 25
        WHEN sq1.latest_rental_month = 11
            THEN 20
        WHEN sq1.latest_rental_month = 10
            THEN 15
        WHEN sq1.latest_rental_month BETWEEN 07 AND 09
            THEN 10
        WHEN sq1.latest_rental_month BETWEEN 01 AND 06
            THEN 5
        END AS recency_score  
    FROM
    (
    SELECT c.customer_id,
    EXTRACT('Month' FROM MAX(r.rental_date)) AS latest_rental_month
    FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    WHERE r.return_date IS NOT NULL AND (r.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
    GROUP BY 1
    ) sq1
),
--CTE to calculate Metric #1: frequency_score
frequency_score AS (
    SELECT sq2.customer_id, 
    sq2.total_rentals,
    CASE
        WHEN sq2.total_rentals >= 15
            THEN 25
        WHEN sq2.total_rentals BETWEEN 10 AND 14
            THEN 20
        WHEN sq2.total_rentals BETWEEN 6 AND 9
            THEN 15
        WHEN sq2.total_rentals BETWEEN 3 AND 5
            THEN 10
        WHEN sq2.total_rentals BETWEEN 1 AND 2
            THEN 5
        END AS frequency_score
    FROM
    (
    SELECT c1.customer_id, 
    COUNT(DISTINCT r1.rental_id) AS total_rentals
    FROM customer c1
    INNER JOIN rental r1 ON c1.customer_id = r1.customer_id
    WHERE r1.return_date IS NOT NULL AND (r1.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
    GROUP BY 1
    )sq2
),
--CTE to calculate Metric #1: monetary_score
monetary_score AS (
    SELECT sq3.customer_id, sq3.total_spent, sq3.spent_rank,
    CASE
        WHEN sq3.spent_rank >= 0.8
            THEN 25
        WHEN sq3.spent_rank BETWEEN 0.5 AND 0.79
            THEN 20
        WHEN sq3.spent_rank BETWEEN 0.20 AND 0.49
            THEN 15
        WHEN sq3.spent_rank BETWEEN 0.10 AND 0.19
            THEN 10
        ELSE 5
        END AS monetary_score
    FROM
    (
    SELECT c2.customer_id,
    SUM(p.amount) AS total_spent,
    PERCENT_RANK() OVER (ORDER BY SUM(p.amount)) AS spent_rank
    FROM customer c2
    INNER JOIN rental r2 ON c2.customer_id = r2.customer_id
    INNER JOIN payment p ON r2.rental_id = p.rental_id
    WHERE r2.return_date IS NOT NULL AND (r2.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
    GROUP BY 1
    )sq3
),
--CTE to calculate Metric #1: category_loyalty_score
category_loyalty AS (
    
    SELECT sq7.customer_id, sq7.top_cat_share,
    CASE
    WHEN sq7.top_cat_share >= 80 THEN 25
    WHEN sq7.top_cat_share >= 60 THEN 20
    WHEN sq7.top_cat_share >= 40 THEN 15
    WHEN sq7.top_cat_share >= 20 THEN 10
    ELSE 5
    END AS loyalty_score 
    FROM
    (
        SELECT sq6.customer_id, sq6.top_two_cat_rentals, 
        COUNT(DISTINCT r4.rental_id) AS total_rentals,
        sq6.top_two_cat_rentals/COUNT(DISTINCT r4.rental_id) * 100 AS top_cat_share
        FROM
        (
            SELECT sq5.customer_id, SUM(sq5.total_rentals) AS top_two_cat_rentals
            FROM 
            (
                SELECT sq4.customer_id, sq4.name, sq4.total_rentals
                FROM
                (
                    SELECT c3.customer_id, 
                    cat.name, 
                    COUNT(*) AS total_rentals,
                    ROW_NUMBER() OVER (PARTITION BY c3.customer_id ORDER BY COUNT(*) DESC) AS rn
                    FROM customer c3
                    INNER JOIN rental r3 ON c3.customer_id = r3.customer_id
                    INNER JOIN inventory i ON r3.inventory_id = i.inventory_id
                    INNER JOIN film f ON i.film_id = f.film_id
                    INNER JOIN film_category fc ON f.film_id = fc.film_id
                    INNER JOIN category cat ON fc.category_id = cat.category_id
                    WHERE r3.return_date IS NOT NULL AND (r3.rental_date BETWEEN '01-01-2005' AND '12-31-2005')
                    GROUP BY 1,2
                    ORDER BY 1
                )sq4
                    WHERE sq4.rn <=2
            )sq5
            GROUP BY 1
        ) sq6
        INNER JOIN rental r4 ON sq6.customer_id = r4.customer_id
        GROUP BY 1,2
    ) sq7   
)
