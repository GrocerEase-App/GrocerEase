# Sprint 1 Plan & Report

## Sprint 1 Plan

Product/Team Name: GrocerEase  
Revision Number: 1  
Revision Date: April 16, 2025  
Sprint Date: April 9 \- April 22, 2025

### Goal

Begin building the UI for manual data entry as we start researching the best way to scrape item data from store websites.

### User Stories

1. \[High\] As a user, I want to be able to add items to a grocery list so I can keep track of what I need to buy. (8 story points)  
   1. Tasks and Assignments  
      * Create Xcode project with SwiftUI (Finlay)  
      * Set up list UI (Arushi)  
      * Create manual item creation page (Arushi)  
      * Set up data storage (Finlay, Arushi)  
   2. Acceptance Criteria  
      * Given I am on the grocery list page,  
      * When I click the "+" button and search for a product,  
      * Then I see a list of matching products with store name and unit price.  
      * And when I select a product and click "Add",  
      * Then the selected product appears in my grocery list with the store and price displayed.  
2. \[High\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (13 story points)  
   1. Tasks and Assignments  
      * Research Target API (Teddy, Samuel)  
      * Research Safeway API (Finlay, Samarth)  
      * Research Trader Joe’s API (Arushi)  
      * Research aggregator API’s (Samarth)  
   2. Acceptance Criteria  
      * Given I am on the product search view,  
      * When I type in a product name,  
      * Then each result in the list should show the product name, unit price, and store.

### Spikes

1. Find API for product identifiers (UPC/PLU) (Sam, Teddy)  
2. Analyze store sites for scraping (All, see above)  
3. Determine best strategy for local data storage and cloud syncing (Finlay, Samarth)

### Infrastructure Tasks

1. Set up GitHub repository (Finlay)  
2. Set up dev server accounts  
   * Install Xcode and simulator runtime (Finlay)  
   * Set up remote access (Finlay)  
3. Cloud provider account(s) (Arushi)

### Team Roles

Samarth Agarwal: Developer  
Teddy Danielson: Developer  
Finlay Nathan: Product Owner  
Arushi Tyagi: Scrum Master  
Samuel Morrow: Developer

### Scrum Board

![](/docs/s1sb.png)

### Burnup Chart

![](/docs/s1bu.png)

## Sprint 1 Report

Product/Team Name: GrocerEase  
Revision Date: April 22, 2025

### Actions to Stop Doing

- Starting API research without assigning ownership of key tasks/decisions.

### Actions to Start Doing

- Scrum Schedule Planning

### Actions to Keep Doing

- Shared Documentation  
- Regular check-ins through the group chat  
- Coordination on Github setup and UI integration

### Completed/Incomplete User Stories

3. \[COMPLETED\] As a user, I want to be able to add items to a grocery list so I can keep track of what I need to buy. (8 story points)  
4. \[INCOMPLETE\] As a user, I want to see prices of items on my grocery list so I can choose where to shop. (13 story points)  
   1. This user story required significantly more research than expected and will need to continue in the next sprint since it is critical to the app’s functionality.

### Work Completion Rate

Total story points committed: 21  
Story points completed: 8  
Completion rate: 38%
