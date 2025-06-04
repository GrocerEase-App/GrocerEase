# Sprint 3 Plan & Report

## Sprint 3 Plan

Product/Team Name: GrocerEase  
Revision Number: 3  
Revision Date: May 14, 2025  
Sprint Date: May 7 \- May 20, 2025

### Goal

Complete pricing display, stabilizing a consistent store API, and introducing basic multi-list support. Begin development of product comparison features to enable better grocery decisions.

### User Stories

#### Sprint Backlog Stories

1. \[High\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (5 story points)  
   1. Tasks and Assignments  
      * Finish standardizing data output from each store’s API responses (All)  
      * Unit and integration testing for different product queries (All)  
   2. Acceptance Criteria  
      * Given I am on the product search view,  
      * When I type in a product name,  
      * Then each result in the list should show the product name, unit price, and store.  
2. \[Medium\] As a developer, I want a consistent API for looking up product prices at any local store so it’s easy to implement each store. (8 story points)  
   1. Tasks and Assignments  
      * Work on data model for grocery lists, stores, items (Finlay, Samarth)  
   2. Acceptance Criteria  
      * Given I am using the pricing API,  
      * When I pass a product name and store identifier,  
      * Then I receive a standardized GroceryItem object containing the product name, price, store, availability, etc.  
      * And the same API call works across all supported stores.  
      * Also works for searching for store locations.

#### New Stories

3. \[High\] As a user, I want to create multiple lists so I can organize my needs. (3 story points)  
   1. Tasks and Assignments  
      * Note: This story was moved up from sprint 4 as it needed to coincide with the previous user story. The story points were reduced as we shelved the idea of “reusable” lists.  
      * Create UI for managing multiple lists (Arushi and Finlay)  
      * Create list creation page  
      * Move location selection settings to list settings (Teddy and Finlay)  
   2. Acceptance Criteria  
      * Given I am on the main page,  
      * When I click the "+" button,  
      * Then I should see a form to enter a new list name, location, radius, preferences, and store options.  
      * And when I fill in the form and click "Save",  
      * Then the new list appears in the dropdown of grocery lists on the main page.  
4. \[High\] As a user, I want to be able to compare similar products so I know I’m getting the best deal. (8 story points)  
   1. Tasks and Assignments  
      * Group similar products across stores (Samarth)  
      * Design and implement matching algorithm (All)  
   2. Acceptance Criteria  
      * Given I search for an item on the Add Item page,  
      * Then I should see a list of similar products at different stores,  
      * And each product should display name, store, and unit price.

#### Canceled Stories

5. \[Medium\] As a user, I want to see multiple shopping plans so I can choose which works best. (5 story points)  
   1. Tasks and Assignments  
* Research optimization strategies for shopping plans (Finlay and Samarth)  
* Create an algorithm to generate alternative shopping plans (Finlay)  
* Implement UI component to display shopping plans (Arushi)  
* Add sorting/filtering logic for shopping plans (Samuel)  
* Write test cases for plan generation logic (Samarth)  
6. \[Medium\] As a user, I want all my items and coupons in one place and sorted by store so I know I’m getting the best deal. (5 story points)  
   1. Tasks and Assignments  
* Design data model for coupons and associate with items (Finlay and Arushi)  
* Scrape or load sample coupon data from each store (Samarth)  
* Group items by store in the UI and coupon indicators (Teddy)  
* Add logic to select best coupon per store per item (Arushi)  
* Test edge cases (expired coupons, no coupons, multiple matching coupons) (Samuel)

### Spikes

1. ~~Generate formulas for mathematically optimizing shopping plans~~  
   1. For canceled user story  
2. ~~Balance additional considerations like time and distance~~  
   1. For canceled user story

### Infrastructure Tasks

1. N/A

### Team Roles

Samarth Agarwal: Developer  
Teddy Danielson: Scrum Master  
Finlay Nathan: Product Owner  
Arushi Tyagi: Developer  
Samuel Morrow: Developer

### Scrum Board

![](/docs/s3sb.png)

### Burnup Chart

![](/docs/s3bu.png)

## Sprint 3 Report

Product/Team Name: GrocerEase  
Revision Date: May 20, 2025

### Actions to Stop Doing

- Deferring feature testing until all components are merged  
- Overestimating number of new features that can fit in each sprint

### Actions to Start Doing

- Break comparison logic into testable components  
- Build and test incrementally with mock data for front-end and scraper dependencies  
- Start documentation

### Actions to Keep Doing

- Code reviews for major logic components  
- Update story status mid-sprint

### Completed/Incomplete User Stories

1. \[COMPLETE\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (5 story points)  
2. \[COMPLETE\] As a developer, I want a consistent API for looking up product prices at any local store so it’s easy to implement each store. (8 story points)  
3. \[COMPLETE\] As a user, I want to create multiple lists so I can organize my needs. (3 story points)  
4. \[INCOMPLETE\] As a user, I want to be able to compare similar products so I know I’m getting the best deal. (8 story points)  
   1. Still need to create an algorithm to group items known to be identical between stores.

### Work Completion Rate

Total story points committed: 24  
Story points completed: 16  
Completion rate: 66%
