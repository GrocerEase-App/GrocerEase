# Sprint 4 Plan & Report

## Sprint 4 Plan

Product/Team Name: GrocerEase  
Revision Number: 4  
Revision Date: June 2, 2025  
Sprint Date: May 21 \- June 3, 2025

### Goal

Finalize product comparison features and perform automated unit testing. Prepare the repository for open-source release and final submission.

### User Stories

#### Sprint Backlog Stories

1. \[High\] As a user, I want to be able to compare similar products so I know I’m getting the best deal. (8 story points)  
   1. Tasks and Assignments  
* Create an algorithm to group items known to be identical between stores. (Finlay)  
  2. Acceptance Criteria  
* Given I search for an item on the Add Item page,  
* Then I should see a list of similar products at different stores,  
* And each product should display name, store, and unit price.

#### New Stories

2. \[High\] As a developer, I want to be able to test the app’s functionality automatically so I know what features still need improvement. (8 story points)  
   1. Tasks and Assignments  
* Write unit tests for grocery list creation and management using the Swift testing library (Arushi)  
  2. Acceptance Criteria  
* Unit tests implemented for all scrapers  
* Unit tests implemented for all helper functions  
3. \[Low\] As an open source developer, I want to add supported stores so I can help my local community. (3 story points)  
   1. Tasks and Assignments  
* Write contribution guidelines (Finlay, Samarth)  
* Write architecture document, API explanation (Finlay)  
  2. Acceptance Criteria  
* Repository is public on github  
* Repository has a license

#### Canceled Stories

4. \[Medium\] As a user, I want to create multiple/reusable shopping lists so I can organize my needs. (8 story points)  
   1. Tasks and Assignments  
      * Design data structure for storing multiple lists (Finlay)  
      * Add UI components for selecting and switching lists (Arushi)  
      * Implement new list creation form with name and optional preferences (Teddy)  
      * Allow users to delete or rename existing lists (Finlay)  
      * Save user’s last active list across sessions (Samuel)  
      * Write unit tests for list management operations (Samarth)  
5. \[Medium\] As a user, I want to report missing or incorrect deals to other users so I feel confident about using the app. (13 story points)  
   1. Tasks and Assignments  
      * Design feedback schema for users to flag a product/deal (Finlay)  
      * Add “Report Issue” button next to each product listing (Arushi)  
      * Send confirmation to user after submitting a report (Samuel)  
      * Handle duplicates and spam filtering for incoming reports (Finlay)  
6. \[Medium\] As a user, I want my lists to sync with other users or devices so I can collaborate on lists with family or roommates. (13 story points)  
   1. Tasks and Assignments  
      * Design shared list data model with multiple user access (Finlay and Samarth)  
      * Add list-sharing option in the list settings screen (Arushi)  
      * Implement invite workflow via email or generated share link (Teddy)  
      * Add activity log or last-edited indicator for shared lists (Samuel)  
      * Write test cases for list sharing, syncing, and conflict resolution (Samarth)

### Spikes

1. ~~Research more variables for the optimization formulas.~~  
   1. For canceled user story  
2. Thoroughly test for UX issues that make the app confusing.

### Infrastructure Tasks

1. Publish git repository for open source contributions and grading

### Team Roles

Samarth Agarwal: Scrum Master  
Teddy Danielson: Developer  
Finlay Nathan: Product Owner  
Arushi Tyagi: Developer  
Samuel Morrow: Developer

### Scrum Board

![](/docs/s4sb.png)

### Burnup Chart

![](/docs/s4bu.png)

## Sprint 4 Report

Product/Team Name: GrocerEase  
Revision Date: June 3, 2025

### Actions to Stop Doing

- Prioritizing new features over testing

### Actions to Start Doing

- Fix key components to support potential open-source extensibility  
- Focus on documentation and user flow simplicity

### Actions to Keep Doing

- Continue with testing and test-driven development  
- Build around user experience

### Completed/Incomplete User Stories

1. \[COMPLETE\] As a user, I want to be able to compare similar products so I know I’m getting the best deal. (8 story points)  
2. \[COMPLETE\] As a developer, I want to be able to test the app’s functionality automatically so I know what features still need improvement. (8 story points)  
3. \[COMPLETE\] As an open source developer, I want to add supported stores so I can help my local community. (3 story points)

### Work Completion Rate

Total story points committed: 19  
Story points completed: 19  
Completion rate: 100%
