# GrocerEase Test Plan and Report

Product/Team Name: GrocerEase  
Revision Date: June 1, 2025

## System Test Scenarios: 

1. User Story 1: As a user, I want to be able to add items to the grocery list that then identifies those products for me online so I know where I can shop.  
2. User Story 2: As a user, I want to see prices of items on my grocery list so that I can choose where to shop.  
3. User Story 3: As a user, I want to make sure my desired items are in stock.  
4. User Story 4: As a developer, I want a consistent API for looking up product prices at any local store.  
5. User Story 5: As a user, I want to be able to compare similar products so I know I’m getting the best deal.  
6. User Story 6: As a user, I want to create multiple/reusable shopping lists.

### Scenario 1:

1. Start GrocerEase; Press “+” button in top right corner  
Name \= \<test1\>  
Location \= \<Coolidge Dr, Santa Cruz, CA\>  
Radius \= \<7 miles\>  
Shopping Preferences \= \<Off\>
2. User should see screen with grocery list named “test”   
3. Enter “Test” list; Press “+” button in top right corner to enter add item page.  
Search \= \<Hot cheetos\>  
In results, choose top option; under cheapest tab, choose Safeway \#2607  
Press “Add”  
Press the “+” button in the top right corner to enter the add item page.  
Search \= \<Bagels\>  
In results, choose top option; under closest tab, choose Trader Joe’s \#193
4. Users should now see under their “test1” page, two distinct products with prices attached.   
5. With Scenario 1, User Story 1 and User Story 2 are complete

### Scenario 2:

1. Navigate into the cheetos product that was added to the list.  
2. It can be observed whether the item is in stock under the "Availability" tab.  
3. With Scenario 2, User Story 3 is complete.

### Scenario 3: 

1. Navigate to “test1” list  
Search \= \<Apples\>  
Users should be able to see prices from all local stores, as well as product information. Retrieved info is consistent and reproducible.
2. With Scenario 3, User Story 4 is complete.

### Scenario 4: 

1. Given you are in test1 tab, press “+” in top right corner  
Search \= \<Sirloin Steak\>  
2. Users should see a list of all choices of sirloin steak in their selected stores.   
The user can see the item description/picture  
The user can see price  
The user can see location  
3. With Scenario 4, User Story 5 is complete.

### Scenario 5:

1. Navigate back to grocery lists tab; Press “+” button in top right corner  
Name \= \<test2\>  
Location \= \<Coolidge Dr, Santa Cruz, CA\>  
Radius \= \<7 miles\>  
Shopping Preferences \= \<Off\>
2. User should see screen with two grocery lists named “test1” and “test2”  
Press “test1”  
User can see all of the previously inputted products  
Go back to grocery lists page  
Press “test2”   
User can add new items to the new grocery list  
3. The user can create multiple lists that are reusable  
4. With Scenario 5, User Story 6 is complete.

## Unit Tests

**Goal:** Ensure each store’s search function returns non-empty results for valid input  
These tests are located in [ScraperTests.swift](/GrocerEaseTests/ScraperTests.swift)  
- testSearchAlbertsons()  
- testSearchTraderJoes()  
  - See Release Plan Known Problem 3  
- testSearchTarget()

**Goal:** Test that the function returns at least one store near a known location  
These tests are located in [ScraperTests.swift](/GrocerEaseTests/ScraperTests.swift)  
- testFindStoresAlbertsons()  
- testFindStoresTraderJoes()  
  - See Release Plan Known Problem 3  
- testFindStoresTarget()

**Goal:** Test location utility functions  
These tests are located in [HelperTests.swift](/GrocerEaseTests/HelperTests.swift)
- testLocationDistance()  
- testAddressToLocation()  
- testAddressPartsToString()  
- testPlacemarkToAddressString()