# Sprint 2 Plan & Report

## Sprint 2 Plan

Product/Team Name: GrocerEase  
Revision Number: 2  
Revision Date: April 23, 2025  
Sprint Date: April 23 \- May 6, 2025

### Goal

Finish research on store APIs and start analyzing them to create a common interface to interact with all of them.

### User Stories

#### Sprint Backlog Stories

1. \[High\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (13 story points)  
   1. Tasks and Assignments  
      * Research and document available APIs for Target, Safeway, and Trader Joe’s (All)  
      * Write scrapers or API integration for each store (Finlay)  
      * Implement UI components to display product prices per store (Arushi)  
      * Normalize price units (Samuel)  
      * Unit and integration testing for different product queries (Teddy, Samarth)  
   2. Acceptance Criteria  
      * Given I am on the product search view,  
      * When I type in a product name,  
      * Then each result in the list should show the product name, unit price, and store.

#### New Stories

2. \[Medium\] As a user, I want to make sure my desired items are in stock so I know I’ll be able to buy what I need. (3 story points)  
   1. Tasks and Assignments  
      * Check if each store API provides stock data (Finlay)  
      * Update UI to show “In Stock” or “Out of Stock” (Arushi)  
      * Handling for stores with no stock info (Teddy)  
      * Check for location-specific stock and price differences (Samarth)  
   2. Acceptance Criteria  
      * Given I am on the product review page after selecting a product,  
      * Then I should see the product’s availability status labeled as “In Stock” or “Out of Stock.”  
3. \[Medium\] As a developer, I want a consistent API for looking up product prices at any local store so it’s easy to implement each store. (8 story points)  
   1. Tasks and Assignments  
      * Research what methods are necessary and how they should be implemented by each store’s scraper (Finlay)  
      * Implement adapters for at least 2 stores (Arushi)  
      * Add error handling and rate limiting logic (Samuel)  
      * Write documentation/comments (Samarth)  
   2. Acceptance Criteria  
      * Given I am using the pricing API,  
      * When I pass a product name and store identifier,  
      * Then I receive a standardized GroceryItem object containing the product name, price, store, availability, etc.  
      * And the same API call works across all supported stores.  
      * Also works for searching for store locations.

### Spikes

1. Find API for geographical data (Samuel, Teddy)  
2. Determine best strategy for platform agnostic scraping logic (Finlay)  
   1. Decide best cross-platform language  
   2. Decide what frameworks/libraries will be used  
   3. Decide how to package and distribute  
3. Determine permissions in terms of service for web scraping (Finlay and Sam)

### Infrastructure Tasks

1. Design and launch backend user data storage model  
   1. Decide whether to store fully locally, use private cloud (CloudKit), or our own backend (Finlay)  
   2. Begin designing data models (Finlay, Samarth)

### Team Roles

Samarth Agarwal: Developer  
Teddy Danielson: Developer  
Finlay Nathan: Product Owner  
Arushi Tyagi: Developer  
Samuel Morrow: Scrum Master

### Scrum Board

![](/docs/s2sb.png)

### Burnup Chart

![](/docs/s2bu.png)

## Sprint 2 Report

Product/Team Name: GrocerEase  
Revision Date: May 6, 2025

### Actions to Stop Doing

- ### Delaying UI implementation until all research is finalized.

- Working on large user stories without breaking them down into smaller subtasks.

### Actions to Start Doing

- Implementing partial features even if all data sources aren’t ready  
- Use mock data while API responses are incomplete  
- Create hard deadlines for API decisions and backend design approvals

### Actions to Keep Doing

- Collaborative research and shared documentation  
- Dedicated roles for research, UI, backend  
- Ownership of user stories and clear documented progress updates

### Completed/Incomplete User Stories

4. \[INCOMPLETE\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (13 story points)  
   1. Research still ongoing for analyzing API responses, how to standardize data models in app persistent storage.  
5. \[COMPLETE\] As a user, I want to make sure my desired items are in stock so I know I’ll be able to buy what I need. (3 story points)  
6. \[INCOMPLETE\] As a developer, I want a consistent API for looking up product prices at any local store so it’s easy to implement each store. (8 story points)  
   1. API designed but implementation still being polished, existing scraper implementations need to conform to new standards, data models need to be improved.

### Work Completion Rate

Total story points committed: 24  
Story points completed: 3  
Completion rate: 12.5%
