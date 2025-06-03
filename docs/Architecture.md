# GrocerEase Architecture Design

## User Interface

The GrocerEase user interface is written in Swift using SwiftUI.

Its major components are as follows:

* Home page/launch screen: A list of the user’s grocery lists.  
* List creation/settings page: An interface to create a new list or edit an existing one.  
* Grocery list page: Displays a list of grocery items in a specific list.  
* Item search page: An interface to search for grocery items to add to a list.  
* Item details page: Displays details about an item in search or on the list.

When any list view is empty, a brief tutorial or explanation is displayed to the user in its place.

In the item search page, items from different stores that are known to be equivalent are grouped together. This is done using a Union-Find algorithm which currently compares product name, UPC, PLU, and SKU+retailer name.

## Database Model

GrocerEase uses SwiftData to automatically handle data persistence and relationships.

The database is made up of three primary models:

* GroceryList: A model describing the highest level unit of data, containing one-to-many relationships to the following two models as well as certain configuration data that must persist between app sessions.  
* GroceryStore: A model describing the details and location of a specific physical store.  
* GroceryItem: A model extensively describing a single item at a specific store, including numerous universal identifiers, if available, to determine equivalency with other items.

Instances of models are not persisted until they are inserted into the user’s model context. Thus, unsaved lists (before pressing save) and item instances from search that are not added to a list are not persisted.

## Scraper API & Extensibility

GrocerEase utilizes on-device scraping logic to enhance user privacy, reduce likelihood of rate limiting, and eliminate hosting costs. Each supported store (or more accurately, price source, as some sources can provide data for multiple brands of stores), inherits from the Scraper interface. This interface requires methods to be implemented for finding nearby stores given a location and searching for items given a store location and a query.

Many of the stores’ APIs we researched prevent bots from performing requests like ours using a variety of methods. We found that most could be bypassed by loading their sites’ homepages in a headless browser from a reliable IP address (i.e. one that hasn’t already been blocked due to too much scraping), then using the session cookies from the browser to make subsequent requests. The Scraper interface provides a default implementation for retrieving these details from a headless WKWebView instance which has been sufficient for all of our scrapers thus far.

To add support for another data source, a developer needs to create a final class that properly inherits from Scraper, then add it to the PriceSource enumeration so that it is automatically used in searches.

It’s worth noting that “Scraper” is a slight misnomer, as all of our current instances of this interface make proper API calls and only “scrape” API keys and session credentials.

## Future Considerations

We initially intended for the GrocerEase scraper to be a separate open-source package, fully independent of the UI, so that it could be used on any platform. However, we shelved this idea due to two major constraints we faced: time and bot restrictions. As described in the previous section, we needed a method to retrieve credentials from a headless browser. Building a headless browser into our scraper package would’ve made it dependent on modules specific to Apple platforms, defeating the purpose of having it separate in the first place. Leaving that out would’ve added unnecessary complexity and rigidness to our code, since the scraper package would have to make calls back to the UI module just to execute requests. I still believe this architecture could work by creating a standardized interface and building lightweight, platform-specific headless browser modules, then passing an instance of one to the scraper module when needed, but this was beyond the limit of what we had time to implement. Extracting as much logic as possible to platform-agnostic modules is a high-priority, long-term goal of the project.