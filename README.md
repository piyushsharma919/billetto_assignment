# Billetto Events

A Ruby on Rails application to integrate the Billetto API to fetch, store and display public events. It also provides a voting mechanism which allows authenticated users to vote on events.

## Technology Stack

- Ruby `4.0.6`
- Ruby on Rails `8.1.4.1`
- PostgreSQL `18`
- RSpec

## Setup

### 1. Clone the Repository

Clone the repository and navigate to the project directory:

```bash
git clone <repository-url>
cd billetto_assignment
```

### 2. Install Dependencies

Install the required Ruby gems:

```bash
bundle install
```

### 3. Configure Environment Variables

Copy the example environment file:

```bash
cp .env.example .env
```

Open `.env` and configure the required credentials:

```dotenv
BILLETTO_API_KEYPAIR=your_billetto_access_key_id:your_billetto_access_key_secret

DATABASE_NAME=billetto_integration_development
DATABASE_USERNAME=your_pg_user
DATABASE_PASSWORD=your_pg_password
DATABASE_HOST=localhost
DATABASE_PORT=5432
```

### 4. Create and Migrate the Database

Create the development database and run migrations:

```bash
rails db:create
rails db:migrate
```

### 5. Fetch Events from Billetto

Run the import task to fetch public events from Billetto and create them in the database:

```bash
rails billetto:ingest
```

### 6. Start the Application

Start the Rails server:

```bash
rails server
```

Visit [http://localhost:3000](http://localhost:3000) to access the application.

## Running Tests

Run the RSpec test suite:

```bash
bundle exec rspec
```

### Assumptions and Scope

The following assumptions are made for this proof of concept:

**Event Location**
- Event location is stored using four separate fields: `address`, `city`, `postal_code`, and `country`.
- The `address` field combines the available location name, address line, and address line 2.

**Event Pricing**
- All event prices are assumed to be in DKK cents.

**Event Categorization**
- Category, subcategory, and event type are treated as independent attributes.

**Event Persistence and Concurrency**
- We assume that only one request will attempt to find and create or update a particular event at a time.

This assumption can be revisited if concurrent ingestion is introduced in the future.