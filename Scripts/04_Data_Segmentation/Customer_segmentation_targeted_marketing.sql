/*
We have $50,000 allocated for a Q1 2006 customer reactivation campaign. With thousands of 2005 customers, we need to strategically target those most likely to respond to our offers.

Your Mission: Identify which 2005 customers to target, determine the optimal offer for each segment, and ensure we maximize ROI within our budget constraints.
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