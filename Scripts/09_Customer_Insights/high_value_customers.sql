/* Analysis Request: High-Value Customer & Premium Film Affinity

Hi Team,
Our board is asking for a smarter investment strategy for our premium film inventory (those with a high replacement cost). 
Instead of just buying more copies of popular films, 
I want to understand who is renting our high-end films and how efficiently that rental activity translates into revenue.
I need you to mine the rental data to find the most profitable customer and film combinations.

Please provide me with a report that identifies:
Which valuable customers are repeatedly renting our premium films.
How much revenue each customer is generating per rental of a specific high-value film.
How the total revenue from that customer compares to the film's initial cost.

Deliverable Requirements:
The final output must contain these columns:
Customer ID and Name
Film ID and Title
The Film's Replacement Cost
Total Revenue earned from that customer for that specific film
Number of times the customer rented that specific film
Revenue per Rental (Total Revenue / Number of Rentals)
Revenue-to-Cost Ratio (Total Revenue / Replacement Cost)

Please apply the following filters to focus on high-signal relationships:
Only include films with a replacement cost of $20 or more.
Only include customer/film pairs where the customer has rented the same film at least twice.
Only include pairs where the customer has generated revenue that is at least half of the film's cost (Revenue-to-Cost Ratio > 0.5).

Final sorting: I want to see the most efficient pairs first. Please sort by Revenue per Rental (Highest to Lowest), and then by Revenue-to-Cost Ratio (Highest to Lowest). */


