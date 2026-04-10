-- Migration: 0001_create_tables.sql
-- AI Compliance Monitor - Core schema

-- Regulations table: top-level regulatory frameworks
CREATE TABLE IF NOT EXISTS regulations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  jurisdiction TEXT NOT NULL,
  jurisdiction_code TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active', -- active, draft, proposed, repealed
  effective_date TEXT,
  full_enforcement_date TEXT,
  summary TEXT NOT NULL,
  source_url TEXT,
  penalty_max_amount TEXT,
  penalty_max_percentage TEXT,
  applies_to_agents INTEGER NOT NULL DEFAULT 0, -- 1 if specifically covers AI agents
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Obligations table: specific requirements within each regulation
CREATE TABLE IF NOT EXISTS obligations (
  id TEXT PRIMARY KEY,
  regulation_id TEXT NOT NULL,
  article_reference TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL, -- transparency, record_keeping, human_oversight, risk_assessment, incident_reporting, data_governance, monitoring, audit
  risk_level TEXT, -- unacceptable, high, limited, minimal (EU AI Act specific)
  applies_to TEXT NOT NULL, -- provider, deployer, operator, all
  enforcement_date TEXT,
  is_mandatory INTEGER NOT NULL DEFAULT 1,
  evidence_requirements TEXT, -- JSON array of what constitutes compliance evidence
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (regulation_id) REFERENCES regulations(id)
);

-- Deadlines table: key compliance milestones
CREATE TABLE IF NOT EXISTS deadlines (
  id TEXT PRIMARY KEY,
  regulation_id TEXT NOT NULL,
  obligation_id TEXT,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  deadline_date TEXT NOT NULL,
  deadline_type TEXT NOT NULL, -- enforcement, reporting, registration, assessment
  penalty_for_miss TEXT,
  status TEXT NOT NULL DEFAULT 'upcoming', -- upcoming, active, passed
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (regulation_id) REFERENCES regulations(id),
  FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

-- Cross-jurisdiction mapping: links equivalent obligations across regulations
CREATE TABLE IF NOT EXISTS obligation_mappings (
  id TEXT PRIMARY KEY,
  obligation_id_a TEXT NOT NULL,
  obligation_id_b TEXT NOT NULL,
  mapping_type TEXT NOT NULL, -- equivalent, overlapping, stricter, weaker
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (obligation_id_a) REFERENCES obligations(id),
  FOREIGN KEY (obligation_id_b) REFERENCES obligations(id)
);

-- Use case classifications: maps agent use cases to applicable obligations
CREATE TABLE IF NOT EXISTS use_case_obligations (
  id TEXT PRIMARY KEY,
  use_case TEXT NOT NULL, -- e.g., 'hiring_screening', 'credit_scoring', 'content_moderation', 'customer_service', 'medical_triage'
  regulation_id TEXT NOT NULL,
  obligation_id TEXT NOT NULL,
  applicability TEXT NOT NULL, -- mandatory, conditional, recommended
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (regulation_id) REFERENCES regulations(id),
  FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

-- API usage tracking for future metering
CREATE TABLE IF NOT EXISTS api_usage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  api_key TEXT,
  tool_name TEXT NOT NULL,
  jurisdiction_code TEXT,
  request_timestamp TEXT NOT NULL DEFAULT (datetime('now')),
  response_time_ms INTEGER
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_obligations_regulation ON obligations(regulation_id);
CREATE INDEX IF NOT EXISTS idx_obligations_category ON obligations(category);
CREATE INDEX IF NOT EXISTS idx_deadlines_date ON deadlines(deadline_date);
CREATE INDEX IF NOT EXISTS idx_deadlines_regulation ON deadlines(regulation_id);
CREATE INDEX IF NOT EXISTS idx_use_case_obligations_use_case ON use_case_obligations(use_case);
CREATE INDEX IF NOT EXISTS idx_api_usage_timestamp ON api_usage(request_timestamp);
CREATE INDEX IF NOT EXISTS idx_api_usage_tool ON api_usage(tool_name);
