Okay, I've revised the PRD to better emphasize the support for frontend data visualization and graphing, particularly within the API endpoint descriptions for reporting.

Here's the updated PRD:

---

# Product Requirements Document (PRD) - Backend (FastAPI/Supabase)
## QR-Based Digital Expense Tracking Application - Backend Development Task List

*   **Version:** 1.0.0
*   **Project Phase:** October 2024 - June 2025
*   **Project Scope:** Graduation Project (Istanbul Aydin University)

---

## 1. Introduction

This document details all functional and technical tasks **to be performed** during the backend development (Business Logic, Data Management, AI Analyses, and API Services) of the "QR-Based Digital Expense Tracking Application" mobile app. The project aims to enable users to digitally track their expenses via QR codes, offer AI-powered financial insights, and adopt an eco-friendly approach. A key function of the backend is to provide data structured optimally for frontend visualizations, such as graphs and charts, to represent financial data. This document focuses on the Backend layer, encompassing FastAPI, Supabase (utilizing the Python `supabase` client), and local AI components (Ollama with `tinyllama`). The primary language for the application and this document is English.

---

## 2. Project Goals and Objectives (Backend Perspective)

(This section outlines the overall project objectives from the Backend layer's responsibilities and does not detail specific development tasks.)

*   To process incoming QR code data and transform it into structured financial data.
*   To securely and efficiently store and manage user expense data using Supabase with its Python client.
*   To analyze spending data through AI models (local Ollama with `tinyllama`) to generate meaningful insights and recommendations.
*   To provide reliable and performant API endpoints built with FastAPI, supplying all necessary data for the frontend application, including data structured specifically for financial visualizations (graphs, charts).
*   To ensure the security and privacy of user data through Supabase's Row Level Security (RLS) and best practices.
*   To implement robust logging for monitoring and debugging.

---

## 3. Target Audience

(This section specifies the project's intended audience and does not detail specific development tasks.)

Individuals seeking better financial management, particularly young professionals and students. Environmentally conscious consumers.

---

## 4. Database Schema (Supabase - PostgreSQL)

All tables will use UUIDs for their primary keys (`id`). Row Level Security (RLS) will be enforced on all relevant tables to ensure users can only access and manage their own data. Timestamps (`created_at`, `updated_at`) will be used for record tracking. The schema is designed to support efficient querying for data aggregation required for visualizations.

### 4.1. `users` Table (Primarily managed by Supabase Auth)
*   `id` (UUID, Primary Key, references `auth.users.id`) - Automatically populated by Supabase Auth.
*   `email` (TEXT, Unique) - From `auth.users.email`.
*   `first_name` (TEXT, NOT NULL)
*   `last_name` (TEXT, NOT NULL)
*   `created_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   `updated_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)

### 4.2. `categories` Table
*   `id` (UUID, Primary Key, default: `gen_random_uuid()`)
*   `user_id` (UUID, Foreign Key references `users.id`, NULLABLE)
*   `name` (TEXT, NOT NULL)
*   `created_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   `updated_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   **Constraint:** UNIQUE (`user_id`, `name`)

### 4.3. `receipts` Table
*   `id` (UUID, Primary Key, default: `gen_random_uuid()`)
*   `user_id` (UUID, Foreign Key references `users.id`, NOT NULL)
*   `raw_qr_data` (TEXT, NULLABLE)
*   `merchant_name` (TEXT, NULLABLE)
*   `transaction_date` (TIMESTAMP WITH TIME ZONE, NOT NULL, default: `now()`)
*   `total_amount` (NUMERIC(10, 2), NULLABLE)
*   `currency` (TEXT, NULLABLE, e.g., "TRY", "USD", "EUR")
*   `source` (TEXT, NOT NULL, e.g., 'qr_scan', 'manual_entry')
*   `parsed_receipt_data` (JSONB, NULLABLE)
*   `created_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   `updated_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   **RLS Policy:** Users can only access/manage their own receipts.

### 4.4. `expenses` Table
*   `id` (UUID, Primary Key, default: `gen_random_uuid()`)
*   `receipt_id` (UUID, Foreign Key references `receipts.id` ON DELETE CASCADE, NOT NULL)
*   `user_id` (UUID, Foreign Key references `users.id`, NOT NULL)
*   `category_id` (UUID, Foreign Key references `categories.id`, NULLABLE)
*   `description` (TEXT, NOT NULL)
*   `amount` (NUMERIC(10, 2), NOT NULL)
*   `quantity` (INTEGER, default: 1, NULLABLE)
*   `expense_date` (TIMESTAMP WITH TIME ZONE, NOT NULL, default: `now()`)
*   `notes` (TEXT, NULLABLE)
*   `created_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   `updated_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   **RLS Policy:** Users can only access/manage their own expenses.

### 4.5. `loyalty_status` Table
*   `id` (UUID, Primary Key, default: `gen_random_uuid()`)
*   `user_id` (UUID, Foreign Key references `users.id` ON DELETE CASCADE, NOT NULL, UNIQUE)
*   `points` (INTEGER, NOT NULL, default: 0)
*   `level` (TEXT, NULLABLE)
*   `last_updated` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   **RLS Policy:** Users can only access their own loyalty status.

### 4.6. `ai_suggestions` Table
*   `id` (UUID, Primary Key, default: `gen_random_uuid()`)
*   `user_id` (UUID, Foreign Key references `users.id` ON DELETE CASCADE, NOT NULL)
*   `prompt_context_summary` (JSONB, NULLABLE)
*   `suggestion_text_en` (TEXT, NOT NULL)
*   `suggestion_type` (TEXT, NULLABLE)
*   `user_feedback` (TEXT, NULLABLE)
*   `created_at` (TIMESTAMP WITH TIME ZONE, default: `now()`)
*   **RLS Policy:** Users can only access their own suggestions.

---

## 5. Backend Development Tasks (FastAPI/Supabase)

This section lists all business logic, AI integration, database operations (using Supabase Python client), and API endpoint development tasks to be implemented using FastAPI.

### 5.1. Core Backend Infrastructure and Configuration
*   [ ] **Task:** Select and set up FastAPI as the Python backend framework.
*   [ ] **Task:** Integrate necessary Python libraries: `fastapi`, `uvicorn`, `supabase`, `pydantic`, `python-jose`, `httpx`, logging libraries.
*   [ ] **Task:** Establish environment variable management (`.env` file).
*   [ ] **Task:** Implement comprehensive error handling and logging.
*   [ ] **Task:** Configure security policies (CORS, security headers).

### 5.2. Database Management (Supabase - PostgreSQL via Python Client)
*   [ ] **Task:** Configure Supabase project.
*   [ ] **Task:** Implement database schema using SQL (as defined in Section 4).
*   [ ] **Task:** Define table relationships in SQL (Foreign Keys, Constraints, Cascades).
*   [ ] **Task:** Configure Supabase Row Level Security (RLS) policies via SQL.
*   [ ] **Task:** Create necessary database indexes for performance via SQL (on `user_id`, dates, foreign keys for efficient aggregation and filtering).
*   [ ] **Task:** Set up Supabase Python client (`supabase`) for data operations in FastAPI.

### 5.3. Authentication and Authorization Services
*   [ ] **Task:** Implement User Registration (Sign-up) API Endpoint.
*   [ ] **Task:** Implement User Login API Endpoint.
*   [ ] **Task:** Implement Password Reset/Forgot Password API Endpoint.
*   [ ] **Task:** Implement Two-Factor Authentication (2FA) (Investigate Supabase Auth).
*   [ ] **Task:** Develop JWT token validation and user authorization middleware.

### 5.4. Data Processing, Parsing, and Cleaning Services
*   [ ] **Task:** Develop QR code data parsing functions.
*   [ ] **Task:** Implement data extraction logic from parsed receipt data.
*   [ ] **Task:** Develop data cleaning and formatting logic.
*   [ ] **Task:** Implement logic for processing and saving manually entered expense data (auto-creating `receipts` record).
*   [ ] **Task:** Implement automatic expense categorization (AI-assisted with `tinyllama`).

### 5.5. Expense and Receipt Management API Endpoints (FastAPI)
*   [ ] **Task:** `POST /api/receipts/scan`: Accepts QR data, parses, creates `receipts` and `expenses`.
*   [ ] **Task:** `POST /api/expenses`: Accepts manual expense data, creates `receipts` and `expenses`.
*   [ ] **Task:** `GET /api/receipts`: Lists receipts. Support pagination, filtering (date range, merchant, amount), and sorting (date, amount).
*   [ ] **Task:** `GET /api/receipts/{receipt_id}`: Retrieves a specific receipt and its expenses.
*   [ ] **Task:** `GET /api/expenses`: Lists expenses. Support pagination, filtering (date range, category, merchant, amount), and sorting (date, amount).
*   [ ] **Task:** `GET /api/expenses/{expense_id}`: Retrieves a specific expense.
*   [ ] **Task:** `PUT /api/expenses/{expense_id}`: Updates an expense.
*   [ ] **Task:** `DELETE /api/expenses/{expense_id}`: Deletes an expense.
*   [ ] **Task:** `GET /api/categories`: Lists predefined and user's custom categories.
*   [ ] **Task:** `POST /api/categories`: Allows user to add a custom category.
*   [ ] **Task:** `PUT /api/categories/{category_id}`: Allows user to update their custom category.
*   [ ] **Task:** `DELETE /api/categories/{category_id}`: Allows user to delete their custom category.

### 5.6. AI and Analysis Engine Services (Local Ollama with `tinyllama`)
*   [ ] **Task:** Develop services for analyzing spending data for personalized savings suggestions.
*   [ ] **Task:** `GET /api/suggestions/savings`: API for personalized savings suggestions.
*   [ ] **Task:** Develop logic for budget planning suggestions.
*   [ ] **Task:** `GET /api/suggestions/budget`: API for budget planning suggestions.
*   [ ] **Task:** `GET /api/analytics/summary`: Provides a comprehensive summary of spending analytics, potentially feeding simple charts.
*   [ ] **Task:** Develop algorithms for daily/weekly spending pattern analysis.
*   [ ] **Task:** Develop logic to track product expiration dates from receipt data (if available).
*   [ ] **Task:** Develop logic for identifying recurring expenses/products.
*   [ ] **Task:** Develop logic for tracking price changes for specific products.

### 5.7. Financial Reporting and Visualization Data Services
*   [ ] **Task:** `GET /api/reports/spending-distribution`:
    *   **Details:** Prepares data for spending distribution charts (e.g., by category, by merchant). Accepts filters (date range, specific categories).
    *   **Output Structure Example (for pie/bar charts):** `[{"label": "Food", "value": 350.00, "percentage": 35.0, "color": "#FF6384"}, {"label": "Transport", "value": 150.00, "percentage": 15.0, "color": "#36A2EB"}, ...]`
*   [ ] **Task:** `GET /api/reports/spending-trends`:
    *   **Details:** Prepares time-series data for spending trends (e.g., total spending per day/week/month). Accepts filters (date range, overall or specific categories/merchants) and aggregation period (daily, weekly, monthly).
    *   **Output Structure Example (for line charts):** `{"labels": ["Jan", "Feb", "Mar"], "datasets": [{"label": "Total Spending", "data": [500.00, 450.00, 600.00], "borderColor": "#FFCE56"}]}` or `[{"period": "2023-01", "total_spending": 500.00}, {"period": "2023-02", "total_spending": 450.00}, ...]`
*   [ ] **Task:** `GET /api/reports/category-spending-over-time`:
    *   **Details:** Prepares data to show spending for one or more categories over a time period. Accepts filters (date range, list of category IDs) and aggregation period.
    *   **Output Structure Example (for multi-line or stacked bar charts):** `{"labels": ["Jan", "Feb", "Mar"], "datasets": [{"label": "Food", "data":}, {"label": "Utilities", "data":}]}`
*   [ ] **Task:** `GET /api/reports/budget-vs-actual` (If budgeting feature is implemented):
    *   **Details:** Prepares data to compare budgeted amounts vs. actual spending per category for a given period.
    *   **Output Structure Example (for grouped bar charts):** `[{"category": "Food", "budgeted": 400.00, "actual": 350.00}, {"category": "Transport", "budgeted": 200.00, "actual": 150.00}, ...]`
*   [ ] **Task:** Ensure all reporting endpoints accept relevant filter parameters (date range, category IDs, merchant names, etc.) to customize the data returned for visualization.

### 5.8. Loyalty Program Services
*   [ ] **Task:** Implement business logic for loyalty point calculation.
*   [ ] **Task:** `GET /api/loyalty/status`: Returns user's loyalty points and level.

### 5.9. Infrastructure, Security, and Operational Tasks (Backend)
*   [ ] **Task:** Ensure HTTPS is enforced for all API endpoints.
*   [ ] **Task:** Securely manage sensitive data.
*   [ ] **Task:** Implement API-level authorization checks.
*   [ ] **Task:** Set up scheduled tasks for periodic jobs.
*   [ ] **Task:** Backend logic for push notification service integration.
*   [ ] **Task:** Deploy backend services.

### 5.10. Testing Tasks (Backend)
*   [ ] **Task:** Write unit tests for business logic (`pytest`).
*   [ ] **Task:** Write integration tests for API endpoints (`pytest` with `TestClient`). Specifically test data aggregation logic for reporting endpoints.
*   [ ] **Task:** Test database query correctness and RLS policies.
*   [ ] **Task:** Test AI model integration and suggestion quality.
*   [ ] **Task:** Perform security testing.
*   [ ] **Task:** Perform basic performance/load testing.

---

## 6. Non-Functional Requirements (Backend Perspective)

*   **Performance:** API response times low, especially for reporting endpoints. Data processing and aggregation efficient.
*   **Security:** User data and APIs protected.
*   **Reliability:** Services stable, low error rates.
*   **Scalability:** Cloud infrastructure allows scaling.
*   **Maintainability:** Code clean, documented.
*   **Logging:** Comprehensive logging.

---

## 7. Constraints and Dependencies (Backend Perspective)

*   Dependency on Supabase and its limits.
*   Dependency on local Ollama with `tinyllama`.
*   AI suggestion quality.
*   Capabilities of Python libraries.
*   Complexity of QR code formats.
*   User's local Ollama setup.

---

## 8. Success Criteria (Backend Perspective)

*   All FastAPI API endpoints function correctly, meeting frontend requirements, including providing data in suitable formats for visualization.
*   Database schema and RLS in Supabase are correctly implemented.
*   `supabase` Python client successfully used.
*   AI integration with `tinyllama` provides relevant suggestions.
*   Reporting endpoints deliver accurate aggregated data for charts.
*   Backend services are stable and performant.
*   Security and authorization mechanisms are correctly implemented.
*   Comprehensive logging is in place.

---

## 9. Open Issues and Out-of-Scope Features (Backend Perspective - for this version)

*   **Open:** Strategy for AI improvement.
*   **Open:** Advanced parsing for diverse QR formats.
*   **Out of Scope (Post-MVP):** Highly interactive, drill-down dashboard functionalities requiring complex real-time backend processing (initial focus is on providing pre-aggregated data sets for common chart types).
*   **Out of Scope (Post-MVP):** Advanced financial analysis models.
*   **Out of Scope (Post-MVP):** Real-time collaborative budgeting.
*   **Out of Scope (Post-MVP):** Multi-language AI suggestions.

---

## 10. Project Timeline and Phases (Backend Development Perspective)

(This section provides a high-level timeline for the Backend development phase. Completed phases/tasks to be marked `[x]`.)

*   [ ] **Phase 1: Foundation & Core Setup**
    *   [ ] Task Group 5.1, 5.2, 5.3
*   [ ] **Phase 2: Core Feature Implementation**
    *   [ ] Task Group 5.4, 5.5
*   [ ] **Phase 3: AI, Reporting & Advanced Features**
    *   [ ] Task Group 5.6, 5.7 (Focus on data structures for graphs), 5.8
*   [ ] **Phase 4: Operations & Testing**
    *   [ ] Task Group 5.9, 5.10 (Include testing of reporting data accuracy for graphs)
*   [ ] **Phase 5: Deployment & Documentation**
    *   [ ] Finalize deployment, API documentation (detailing reporting endpoint outputs for frontend).

---

This document serves as a working guide for the Backend development tasks of the "QR-Based Digital Expense Tracking Application" project. Each completed task should be marked as `[x]`.