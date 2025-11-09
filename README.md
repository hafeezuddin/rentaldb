# DVD Rental Database Analysis

This repository contains a set of analytical PostgreSQL queries and example scripts for the classic "DVD rental" sample dataset. The SQL focuses on production-style analytics (CTEs, window functions, aggregations) for business intelligence, operational KPIs, and catalog insights.

Author: Khaja Hafeezuddin Shaik

---

## Repository contents
- `Database/dvdrental.tar` - SQL dump/archive of the classic DVD rental sample database.
- `Scripts/` - Main directory containing categorized SQL analysis files. Subfolders include:
	- `01_Basic_Data_Exploration/` (e.g. `basic_Analysis.sql`)
	- `02_Dimensions_Exploration/`
	- `03_Ranking_Analysis/`
	- `04_Data_Segmentation/` (Advanced)
	- `05_Cummulative_Analysis/` 
	- `06_Recommendation_System/` (contains `recommendation_system.sql`)
	- `07_Performance_Analysis/`
	- `08_Inventory_Analysis/` (Advanced)
	- `09_Customer_Insights/` (Advanced)

The repository organizes queries as many smaller, focused SQL files rather than a single monolithic file. Use the `Scripts/` subfolders to find queries by topic.


## Overview
This repo is a query library against a PostgreSQL DVD rental dataset. The SQL expects the classic schema (tables like `customer`, `rental`, `payment`, `film`, `inventory`, `category`, `film_category`, `actor`, `address`, `city`, `country`, `staff`, `store`). Most queries combine transactional tables with geographic and catalog tables to produce analytics and KPIs used for reporting.

Design choices seen in the queries:
- Heavy use of CTEs (WITH) to break complex transformations into readable steps.
- Window functions and dense/rank/row_number for top-n and cohort-style calculations.
- CROSS JOINs used to compare single-value aggregates to many-row datasets (e.g., comparing each customer's spend to overall average).

## Quickstart (run locally)
Prerequisites:
- PostgreSQL (9.6+ recommended)
- The DVD rental sample database restored into a database named `dvdrental` (commonly available from PostgreSQL sample datasets)

Basic workflow:
1. Restore/load the sample dataset into `dvdrental` (use the provided `Database/dvdrental.tar` or vendor-provided dump).
2. Run an individual SQL script (example):

```bash
# Run a specific analysis file
psql -h localhost -U <your_pg_user> -d dvdrental -f Scripts/01_Basic_Data_Exploration/basic_Analysis.sql

# Run the recommendation example for customer 1
psql -h localhost -U <your_pg_user> -d dvdrental -f Scripts/06_Recommendation_System/recommendation_system.sql
```

3. (Optional) Run all SQL scripts in `Scripts/` recursively from your shell:

```bash
# Bash (macOS / Linux): run every .sql under Scripts/
for f in Scripts/**/*.sql; do
	echo "-- Running $f"
	psql -h localhost -U <your_pg_user> -d dvdrental -f "$f"
done
```

Notes:
- Replace `<your_pg_user>` with your PostgreSQL username (for example: `postgres`).
- Some queries in `rentaldb.sql` assume production-like data volumes; when testing locally run a subset of queries or add `LIMIT` where appropriate.

## Useful tips
- Use `EXPLAIN ANALYZE` to profile slow queries before adding indexes.
- When adding new queries, follow existing project conventions: CTE-first style, consistent table aliases (e.g., `r` for `rental`, `c` for `customer`, `f` for `film`).
- For comparing a per-entity value to a global aggregate, compute the aggregate as a single-row CTE and CROSS JOIN it when needed (this pattern is used repeatedly in the project).

## Examples and quick checks
SQL snippets you can run interactively in psql:

```sql
-- List public tables
SELECT * FROM information_schema.tables WHERE table_schema = 'public';

-- Show sample customers
SELECT * FROM customer ORDER BY customer_id LIMIT 5;

-- Top spenders
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS name, SUM(p.amount) AS total_spend
FROM customer c JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 10;
```

## Contributing
- Open an issue to propose larger changes.
- For small fixes and query improvements, submit a pull request with a brief description.

## License
This repository is published under the MIT License — a permissive, free/open license that allows reuse, modification, and redistribution. A full copy of the license is provided in the `LICENSE` file.
