# GrocerEase Release Summary

Product/Team Name: GrocerEase  
Revision Date: June 1, 2025

### User Stories and Acceptance Criteria

1. As a user, I want to be able to add items to a grocery list so I can keep track of what I need to buy.  
   * Given I am on the grocery list page,  
   * When I click the "+" button and search for a product,  
   * Then I see a list of matching products with store name and unit price.  
   * And when I select a product and click "Add",  
   * Then the selected product appears in my grocery list with the store and price displayed.  
2. As a user, I want to see prices of items on my grocery list so I can choose where to shop.  
   * Given I am on the product search view,  
   * When I type in a product name,  
   * Then each result in the list should show the product name, unit price, and store.  
3. As a user, I want to make sure my desired items are in stock so I know I’ll be able to buy what I need.  
   * Given I am on the product review page after selecting a product,  
   * Then I should see the product’s availability status labeled as “In Stock” or “Out of Stock.”  
4. As a developer, I want a consistent API for looking up product prices at any local store so it’s easy to implement each store.  
   * Given I am using the pricing API,  
   * When I pass a product name and store identifier,  
   * Then I receive a standardized GroceryItem object containing the product name, price, store, availability, etc.  
   * And the same API call works across all supported stores.  
   * Also works for searching for store locations.  
5. As a user, I want to be able to compare similar products so I know I’m getting the best deal.  
   * Given I search for an item on the Add Item page,  
   * Then I should see a list of similar products at different stores,  
   * And each product should display name, store, and unit price.  
6. As a user, I want to create multiple shopping lists so I can organize my needs.  
   * Given I am on the main page,  
   * When I click the "+" button,  
   * Then I should see a form to enter a new list name, location, radius, preferences, and store options.  
   * And when I fill in the form and click "Save",  
   * Then the new list appears in the dropdown of grocery lists on the main page.  
7. As a developer, I want to be able to test the app’s functionality automatically so I know what features still need improvement.  
   * Unit tests implemented for all scrapers  
   * Unit tests implemented for all helper functions  
8. As an open source developer, I want to add supported stores so I can help my local community.  
   * Repository is public on github  
   * Repository has a license

### Known Problems

1. Leaving the app open for an extended period of time will cause scraper sessions to expire and requests to fail.  
2. Scrapers are prone to getting rate limited and blocked at high request volumes, hence why users are suggested to limit their searches to 8 stores. Target’s scraper is most susceptible to this issue.  
3. In the simulator only, network requests from the Trader Joe’s scraper are prone to failing. This issue is not reproducible on actual devices.  
4. If users attempt to repeat an asynchronous action before the first one has completed, it may lead to unexpected search results/store lists.  
5. Store finder may return stores further than the selected radius if a store’s API decides to disregard the radius query.  
6. The Trader Joe’s scraper often returns products unrelated to the search. The results are returned exactly as is by their API and more research needs to be done to determine the best way to omit unexpected results.  
7. Target, Trader Joe’s, and Albertsons (Safeway) do not provide universal identifiers to match products between stores. In the initial release, similar or identical products may appear in separate results.  
8. The search results will erroneously compare unit prices of different units.  
9. Stores that sell products other than groceries will display such products in results.  
10. Cached product images cause the app’s storage to grow quickly.

### Product Backlog

1. As a user, I want to see multiple shopping plans so I can choose which works best.  
2. As a user, I want all my items and coupons in one place and sorted by store so I know I’m getting the best deal.  
3. As a user, I want my lists to sync with other users or devices so I can collaborate on lists with family or roommates.  
4. As a user, I want to report missing or incorrect deals to other users so I feel confident about using the app.  
5. As a user, I want to be able to clip all digital coupons for my desired stores at once so I can save time before shopping.  
6. As a user, I want to be able to download and use the app on Android.  
7. As a user, I want to be able to share and access price data for local stores that don’t publish prices online.  
8. As a developer, I want to cache similar API calls to prevent users from being rate limited or blocked from stores they wish to visit.  
9. As a user, I want to compare nutrition information between products so I can decide what to buy.