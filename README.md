# TrustPass Tech Test

This project implements a simple payment flow integration with a partner provider. It includes secure purchase creation, partner callback handling, and status checking.

---

## 📋 Table of Contents

- [Overview](#overview)
- [API Endpoints](#api-endpoints)
- [Assumptions](#assumptions)
- [Security Considerations](#security-considerations)
- [Setup Instructions](#setup-instructions)
- [Running the Test Suite](#running-the-test-suite)
- [Technologies Used](#technologies-used)

---

## Overview

This application simulates a client purchasing flow via a third-party partner, including:

- Creating a purchase (`/api/v1/purchases`)
- Receiving a redirect callback from the partner (`/api/v1/customer/returns`)
- Checking purchase status (`/api/v1/purchases/check`)

All data is persisted and validated with full test coverage.

---

## API Endpoints

### 1. Create Purchase

**POST** `/api/v1/purchases`

Creates a new purchase and retrieves an access token from the partner.  
Returns an auto-submitting HTML form to securely redirect the client to their `return_url`.

#### Request Body (JSON)
```json
{
  "purchase": {
    "ref_trade_id": "UUID",
    "ref_user_id": "user@example.com",
    "od_currency": "KRW",
    "od_price": "100.00",
    "return_url": "https://client-app.com/return"
  }
}
```
Response: 
- HTML form <form> with hidden inputs for access_token and od_id, which posts to return_url.

### 2. Handle Partner Return
`POST /api/v1/customer/returns`

This is the callback endpoint the partner app hits after the payment is completed.

Request Params (x-www-form-urlencoded or query params):
- ref_trade_id

- od_status

Behavior:
If od_status == "10" → marks purchase as paid

Otherwise → marks as failed

Notifies: http://testpayments.com/api/purchase/:id

Redirects to the original return_url

### 3. Check Purchase Status
POST /api/v1/purchases/check

Checks the current status of a purchase.

Request Body (JSON)
```json
{
  "ref_trade_id": "UUID"
}
```
Response:
```json
{
  "data": {
    "ref_trade_id": "UUID",
    "status": "paid"
  }
}
```

## Assumptions
- The only valid currency is KRW

- The only successful od_status code from the partner is "10"

- All partner responses are mocked using WebMock (no real HTTP calls)

- return_url is assumed to be a trusted client domain

## Security Considerations
The initial token + od_id response is returned using a secure POST HTML form, not query params.
This prevents leaking sensitive data via browser history, referrers, or logs.

## Setup Instructions
```
# 1. Clone the repo
git clone https://github.com/AndreiMGagiu/TrustPass.git
cd trust_pass

# 2. Install dependencies
bundle install

# 3. Set up the database
bin/rails db:create db:migrate

# 4. Run the app
bin/rails server
```

## Running the Test Suite
```
bundle exec rspec
```

## Technologies Used
- Ruby on Rails 8

- RSpec for testing

- FactoryBot for test data

- WebMock for partner API mocking

- HTTParty for outbound HTTP requests
