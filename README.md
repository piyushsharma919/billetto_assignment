# Billetto Events

A Ruby on Rails application to integrate the Billetto API to fetch, store and display public events. It also provides a voting mechanism which allows authenticated users to vote on events.

## Technology Stack

- Ruby `4.0.6`
- Ruby on Rails `8.1.4.1`
- PostgreSQL `18`
- RSpec

### Assumptions and Scope

The following assumptions are made for this proof of concept:

**Event Location**
- Event location is stored using four separate fields: `address`, `city`, `postal_code`, and `country`.
- The `address` field combines the available location name, address line, and address line 2.

**Event Pricing**
- All event prices are assumed to be in DKK.

**Event Categorization**
- Category, subcategory, and event type are treated as independent attributes.

**Event Persistence and Concurrency**
- We assume that only one request will attempt to find and create or update a particular event at a time.

This assumption can be revisited if concurrent ingestion is introduced in the future.