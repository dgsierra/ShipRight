# ShipRight

ShipRight is an internal operations dashboard built with Ruby on Rails 8. It centralises shipment management, providing a unified place to track, organise, and manage order lifecycle workflows.

## Features

- **Staff-only authentication** via Devise — no self-registration
- **Order lifecycle management** — explicit, validated status transitions (pending → approved → shipped → delivered / cancelled)
- **Reusable audit history** — polymorphic `AuditEntry` records every status change with who did it
- **Simulated carrier tracking integration** — `Carriers::FakeCarrierClient` behind a clean service boundary
- **Background job** — `TrackingSyncJob` syncs tracking events asynchronously
- **Orders dashboard** — filterable list, detail page, bulk approval
- **Precise money storage** — all prices and totals stored as integer cents
- **Tailwind CSS** — clean, responsive UI

## Tech Stack

| Concern        | Solution                          |
|----------------|-----------------------------------|
| Language       | Ruby 3.2, Rails 8.1               |
| Database       | PostgreSQL                        |
| Authentication | Devise                            |
| CSS            | Tailwind CSS v4                   |
| Testing        | RSpec, FactoryBot, Shoulda Matchers |
| Jobs           | Solid Queue                       |
| Pagination     | Pagy                              |

## Services:

Services:
- `app` runs Rails on port `3000`
- `db` runs PostgreSQL `16`
- `redis` runs Redis for Sidekiq/shared app services
- `test` runs the RSpec suite against `ship_right_test`

### Prerequisites

- Ruby 3.2+
- PostgreSQL 14+
- Docker
- Docker Compose
- Node.js (for Tailwind CSS build)
- Bundler

### Setup

```bash
# 1. Clone the repository
git clone <repo-url>
cd ShipRight

# 2. Install dependencies
bundle install

# 3. Set up the database
bin/rails db:create db:migrate db:seed

# 4. Start the server
bin/dev
```

Open [http://localhost:3000](http://localhost:3000).

### Seed Login Credentials

| Email                   | Password     | Role  |
|-------------------------|--------------|-------|
| admin@shipright.io      | password123  | Staff |
| ops@shipright.io        | password123  | Staff |

## Architecture

```
app/
├── controllers/
│   ├── application_controller.rb     # authenticate_user! globally
│   ├── sessions_controller.rb        # Devise sessions override
│   └── dashboard/
│       └── orders_controller.rb      # Index, show, transitions, bulk approve
├── models/
│   ├── user.rb                       # Devise + staff flag
│   ├── order.rb                      # Lifecycle, VALID_TRANSITIONS map
│   ├── product.rb
│   ├── order_line_item.rb
│   ├── tracking_event.rb
│   └── audit_entry.rb                # Polymorphic, self.log helper
├── services/
│   ├── orders/
│   │   ├── status_transition_service.rb  # Validates + applies transition + audit
│   │   └── bulk_approve_service.rb       # Iterates StatusTransitionService
│   ├── carriers/
│   │   └── fake_carrier_client.rb        # Simulated carrier with 5% failure rate
│   └── tracking/
│       └── sync_tracking_events_service.rb  # Deduplicates + persists events
├── jobs/
│   └── tracking_sync_job.rb          # Async wrapper for SyncTrackingEventsService
└── views/
    ├── layouts/application.html.erb  # Nav + flash messages
    ├── devise/sessions/new.html.erb  # Tailwind login page
    └── dashboard/orders/
        ├── index.html.erb            # Filterable table, bulk select
        └── show.html.erb             # Detail page, actions sidebar, audit log
```

### Order Lifecycle

```
pending ──► approved ──► shipped ──► delivered
   │              │
   └──────────────┴──► cancelled
```

All transitions go through `Orders::StatusTransitionService`, which:
1. Validates the transition is allowed
2. Updates the order status in a transaction
3. Creates an `AuditEntry` recording the before/after status and the acting user

Invalid transitions return a user-friendly error message — they never raise exceptions to the controller.

### Carrier Integration

`Carriers::FakeCarrierClient` simulates a real carrier API:
- Deterministic events based on the tracking number (reproducible)
- ~5% simulated failure rate for realistic error handling
- Returns a `TrackingResult` struct with `success?`, `events`, `error`

To swap in a real carrier, implement the same interface (`.fetch_tracking(tracking_number)` → `TrackingResult`).

### Audit Logging

Any model can gain audit history by:
1. Adding `has_many :audit_entries, as: :auditable`
2. Calling `AuditEntry.log(auditable:, event:, user:, changes:)`

### Money Handling

All monetary values are stored as **integer cents** (`total_cents`, `unit_price_cents`). Helper methods (`#total_dollars`, `#unit_price_dollars`) convert for display. Never use floats for money.

## Testing

```bash
# Run all specs
bundle exec rspec

# Run specific suites
bundle exec rspec spec/models
bundle exec rspec spec/services
bundle exec rspec spec/requests
bundle exec rspec spec/jobs
```
### Test With Docker

```bash
# Run the full test suite
docker compose run --rm test

# Run a single spec file
docker compose run --rm test bash -lc "bundle exec rails db:create db:schema:load && bundle exec rspec spec/requests/dashboard/orders_spec.rb"
```

Tests focus on behaviour:
- `StatusTransitionService` — valid/invalid transitions, audit trail
- `BulkApproveService` — partial failures
- `FakeCarrierClient` — success/failure simulation
- `SyncTrackingEventsService` — deduplication, missing tracking number
- `TrackingSyncJob` — delegation + no-op for missing orders
- Request specs — authentication, transitions, bulk actions

## Development

```bash
# Start with live Tailwind recompilation
bin/dev

# Reset and reseed the database
bin/rails db:reset db:seed

# Open Rails console
bin/rails console
```
