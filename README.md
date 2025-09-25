# DVD Rental Database Analysis
PostgreSQL analysis of a DVD rental business database demonstrating advanced SQL techniques and business intelligence queries.
**Author:** Khaja Hafeezuddin Shaik

## Database Schema
Analysis performed on PostgreSQL database with normalized schema including:
- `customer`, `rental`, `payment` - Transaction and customer data
- `film`, `inventory`, `category` - Catalog and stock management  
- `actor`, `film_actor`, `film_category` - Relational mappings
- `address`, `city`, `country`, `store`, `staff` - Geographic and operational data


### SQL Techniques Demonstrated
- **Complex Joins**: Multi-table INNER/LEFT/CROSS joins with 8+ table relationships
- **CTEs**: Multi-level Common Table Expressions for data transformation
- **Window Functions**: RANK(), ROW_NUMBER(), PARTITION BY for analytical processing
- **Subqueries**: Correlated and nested subqueries for comparative analysis
- **Aggregation**: Advanced GROUP BY with HAVING clauses and statistical functions
- **Date Operations**: EXTRACT(), date arithmetic, and temporal analysis

### Query Categories
Basic Analytics (20+ queries)
Advanced Analysis (30+ queries)
Business Intelligence (25+ queries)

## Key Analysis Areas
### Performance Optimization
- Films categorized by demand levels (High: 30+ rentals, Medium: 15-29, Low: <15)
- Revenue per rental calculations with statistical comparisons
- Inventory turnover analysis using date arithmetic

### Customer Analytics  
- Cohort analysis using temporal window functions
- Customer scoring based on multiple metrics (frequency, monetary, recency)
- Geographic clustering with revenue attribution

### Operational Intelligence
- Staff performance metrics with comparative ranking
- Peak hour analysis using time extraction functions
- Store profitability analysis with cross-location comparisons

## Technical Highlights
- **Query Complexity**: Up to 8-table joins with multiple CTEs
- **Performance**: Optimized queries using appropriate indexes and join strategies  
- **Data Types**: Proper handling of timestamps, numerics, and text data
- **Business Logic**: Complex calculations for metrics like customer lifetime value, inventory turnover
- **Statistical Analysis**: Percentile calculations, moving averages, and comparative analysis

## Usage
Requires PostgreSQL with DVD rental sample database. Each query includes:
- Business problem definition
- Technical approach explanation  
- Complete executable SQL code
- Performance considerations

The queries demonstrate production-level SQL skills applicable to business intelligence, data analytics, and database development roles.