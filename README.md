# Billetto Events

A Ruby on Rails application to integrate the Billetto API to fetch, store and display public events. It also provides a voting mechanism which allows authenticated users to vote on events.

## Technology Stack

- Ruby `4.0.6`
- Ruby on Rails `8.1.4.1`
- PostgreSQL `18`
- Clerk Authentication
- Rails Event Store
- Pagy
- RSpec
- Tailwind CSS

## Approach & Design Decisions

### 1. Billetto API Integration

The Billetto integration follows a domain-oriented structure, with dedicated classes for individual API resources and a shared generic API client.

- A Rake task triggers the public event ingestion process.
- `Domains::Billetto::PublicEvents` handles API communication and pagination.
- A dedicated mapper transforms API responses into application attributes.
- `Events::CreateOrUpdate` handles event persistence independently of the Billetto domain, allowing reuse by other integrations.
- Individual event processing failures are logged without interrupting the remaining ingestion process.

This separation keeps API-specific logic independent of the application's event persistence layer.

### 2. Authentication (Clerk)

Clerk is used as the external authentication provider through its official Ruby and JavaScript SDKs.

- Clerk handles sign-in, sign-up, sign-out, and session management.
- Rails verifies Clerk session tokens on the backend.
- Authentication is centralized in `ApplicationController`.
- The authenticated Clerk user ID is used to identify users within the application.
- Protected event pages and voting functionality require authentication.

This avoids implementing a separate password authentication system while keeping backend authentication and access control within Rails.

### 3. Voting Architecture

Voting is implemented using a dedicated service, `Voting::CastVote`, to keep business logic separate from controller responsibilities.

- Supports upvotes and downvotes, allowing users to change their existing votes.
- Uses the authenticated Clerk user ID to identify voters.
- Uses event-level database locking to protect concurrent voting operations.
- Prevents duplicate submissions from creating additional voting actions.

**Event Sourcing**

Rails Event Store maintains the historical record of voting actions through two domain events:

- `Voting::EventUpvoted`
- `Voting::EventDownvoted`

Each event records the relevant event ID, Clerk user ID, and previous vote type.

**Vote Count Projection**

A synchronous event handler, `Voting::UpdateVoteCounts`, maintains precomputed upvote and downvote counts in a dedicated `event_vote_counts` table.

This avoids repeatedly calculating vote totals from historical voting records when displaying events.

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
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
CLERK_SECRET_KEY=your_clerk_secret_key
CLERK_FRONTEND_API=your_clerk_frontend_api

BILLETTO_API_KEYPAIR=BILLETTO_ACCESS_KEY_ID:BILLETTO_ACCESS_KEY_SECRET

DATABASE_NAME=billetto_assignment_development
TEST_DATABASE_NAME=billetto_assignment_test
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
bin/rails billetto:fetch_all_public_events
```

### 6. Start the Application

Start the Rails server:

```bash
rails server
```

Visit [http://localhost:3000](http://localhost:3000) to access the application.

## Tailwind CSS

The application uses Tailwind CSS for styling, integrated through `tailwindcss-rails`.

Build the CSS:

```bash
bin/rails tailwindcss:build
```

Watch for stylesheet changes during development:

```bash
bin/rails tailwindcss:watch
```

## Running Tests

Run the RSpec test suite:

```bash
bundle exec rspec
```

## Assumptions

The following assumptions are made for this proof of concept:

- Event location is stored using separate fields: `address`, `city`, `postal_code`, and `country`. The address combines the available location name and address lines.
- Event prices are assumed to be in DKK cents.
- Category, subcategory, and event type are treated as independent attributes.
- We assume that only one request will attempt to find and create or update a particular event at a time.