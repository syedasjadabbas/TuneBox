# Architecture Overview

TuneBox follows a modular Flutter architecture designed for maintainability and feature growth.

## High-Level Layers

- **Presentation Layer (`lib/pages`, `lib/component`)**
  - Screen-level widgets and reusable UI components.
  - Keeps UI concerns separated from state and data orchestration logic.

- **State Layer (`lib/controller`)**
  - Provider-backed controllers manage app state transitions.
  - Centralizes playback, playlist, and UI interaction logic.

- **Data Integration Layer**
  - REST API and backend services (Supabase/Firebase integrations) are consumed through dedicated data flows.
  - Error-safe requests with fallback handling protect user experience during network issues.

## Scalability Patterns

- Reusable component composition to reduce repeated UI logic
- Controller-driven state updates for predictable rendering
- Feature-oriented separation to keep additions localized and low-risk
- Service integration boundaries that allow backend evolution without major UI rewrites
