-- Migration: 0002_seed_data.sql
-- Seed regulatory data for EU AI Act, Singapore IMDA, Colorado AI Act

-- ============================================
-- REGULATIONS
-- ============================================

INSERT INTO regulations (id, name, jurisdiction, jurisdiction_code, status, effective_date, full_enforcement_date, summary, source_url, penalty_max_amount, penalty_max_percentage, applies_to_agents) VALUES
('eu-ai-act', 'European Union Artificial Intelligence Act', 'European Union', 'EU', 'active', '2024-08-01', '2026-08-02', 'Comprehensive risk-based framework for AI systems including specific provisions for general-purpose AI, high-risk AI systems, and prohibited practices. Establishes transparency, record-keeping, human oversight, and conformity assessment requirements.', 'https://eur-lex.europa.eu/eli/reg/2024/1689/oj', '35000000', '7', 1),

('sg-imda-agentic', 'Singapore IMDA Agentic AI Governance Framework', 'Singapore', 'SG', 'active', '2026-01-15', NULL, 'World''s first governance framework specifically for agentic AI systems. Provides guidelines for monitoring, escalation protocols, sandboxing, human oversight, and accountability throughout AI agent lifecycles. Voluntary but establishes legal accountability baseline.', 'https://www.imda.gov.sg/resources/press-releases-factsheets-and-speeches/press-releases/2026/singapore-launches-worlds-first-agentic-ai-governance-framework', NULL, NULL, 1),

('co-ai-act', 'Colorado Artificial Intelligence Act (SB 24-205)', 'Colorado, United States', 'US-CO', 'active', '2024-05-17', '2026-02-01', 'Requires developers and deployers of high-risk AI systems to use reasonable care to avoid algorithmic discrimination. Mandates impact assessments, documentation of AI decision-making processes, and consumer notification requirements.', 'https://leg.colorado.gov/bills/sb24-205', '20000', NULL, 1);


-- ============================================
-- OBLIGATIONS - EU AI Act
-- ============================================

INSERT INTO obligations (id, regulation_id, article_reference, title, description, category, risk_level, applies_to, enforcement_date, is_mandatory, evidence_requirements) VALUES

-- Record-keeping & Logging
('eu-art12-logging', 'eu-ai-act', 'Article 12', 'Automatic Logging and Record-Keeping', 'High-risk AI systems shall be designed and developed with capabilities enabling the automatic recording of events (logs) over the lifetime of the system. Logging capabilities shall ensure traceability of the AI system functioning, including input data, system decisions, and outputs.', 'record_keeping', 'high', 'provider', '2026-08-02', 1, '["automated_event_logs","input_output_records","decision_trace_logs","log_retention_policy","log_integrity_verification"]'),

('eu-art12-traceability', 'eu-ai-act', 'Article 12(2)', 'Traceability of AI System Functioning', 'Logging capabilities shall ensure a level of traceability appropriate to the intended purpose of the AI system, enabling monitoring of operation and post-market surveillance.', 'record_keeping', 'high', 'provider', '2026-08-02', 1, '["operation_monitoring_logs","post_market_surveillance_data","traceability_documentation"]'),

-- Transparency
('eu-art13-transparency', 'eu-ai-act', 'Article 13', 'Transparency and Provision of Information', 'High-risk AI systems shall be designed and developed in such a way to ensure that their operation is sufficiently transparent to enable deployers to interpret the system output and use it appropriately.', 'transparency', 'high', 'provider', '2026-08-02', 1, '["system_documentation","user_instructions","output_interpretation_guide","intended_purpose_declaration"]'),

('eu-art50-transparency-general', 'eu-ai-act', 'Article 50', 'Transparency Obligations for Certain AI Systems', 'Providers shall ensure that AI systems intended to interact directly with natural persons are designed and developed in such a way that the natural person is informed that they are interacting with an AI system, unless this is obvious.', 'transparency', 'limited', 'provider', '2026-08-02', 1, '["ai_interaction_disclosure","user_notification_mechanism","disclosure_audit_log"]'),

-- Human Oversight
('eu-art14-human-oversight', 'eu-ai-act', 'Article 14', 'Human Oversight', 'High-risk AI systems shall be designed and developed in such a way that they can be effectively overseen by natural persons during the period in which the AI system is in use, including with appropriate human-machine interface tools.', 'human_oversight', 'high', 'provider', '2026-08-02', 1, '["human_oversight_mechanism","override_capability","escalation_procedures","oversight_activity_logs"]'),

-- Risk Assessment
('eu-art9-risk-management', 'eu-ai-act', 'Article 9', 'Risk Management System', 'A risk management system shall be established, implemented, documented, and maintained for high-risk AI systems. It shall be a continuous iterative process planned and run throughout the entire lifecycle.', 'risk_assessment', 'high', 'provider', '2026-08-02', 1, '["risk_management_plan","risk_identification_records","risk_mitigation_measures","residual_risk_assessment","lifecycle_risk_reviews"]'),

-- Data Governance
('eu-art10-data-governance', 'eu-ai-act', 'Article 10', 'Data and Data Governance', 'Training, validation and testing data sets shall be subject to appropriate data governance and management practices. Data governance shall address relevant design choices, data collection processes, data preparation, formulation of relevant assumptions, assessment of availability and suitability.', 'data_governance', 'high', 'provider', '2026-08-02', 1, '["data_governance_policy","training_data_documentation","data_quality_assessment","bias_detection_records"]'),

-- Incident Reporting
('eu-art62-incident-reporting', 'eu-ai-act', 'Article 62', 'Reporting of Serious Incidents', 'Providers of high-risk AI systems placed on the Union market shall report any serious incident to the market surveillance authorities of the Member States where that incident occurred.', 'incident_reporting', 'high', 'provider', '2026-08-02', 1, '["incident_detection_mechanism","incident_report_templates","authority_notification_records","corrective_action_documentation"]'),

-- Monitoring
('eu-art72-post-market', 'eu-ai-act', 'Article 72', 'Post-Market Monitoring by Providers', 'Providers shall establish and document a post-market monitoring system proportionate to the nature of the AI technologies and risks of the high-risk AI system.', 'monitoring', 'high', 'provider', '2026-08-02', 1, '["monitoring_plan","performance_metrics","drift_detection","user_feedback_collection","monitoring_reports"]'),

-- Conformity Assessment
('eu-art43-conformity', 'eu-ai-act', 'Article 43', 'Conformity Assessment', 'Providers of high-risk AI systems shall ensure conformity assessment is carried out before placing on the market or putting into service.', 'audit', 'high', 'provider', '2026-08-02', 1, '["conformity_assessment_report","technical_documentation","quality_management_system","eu_declaration_of_conformity"]');


-- ============================================
-- OBLIGATIONS - Singapore IMDA Agentic AI
-- ============================================

INSERT INTO obligations (id, regulation_id, article_reference, title, description, category, risk_level, applies_to, enforcement_date, is_mandatory, evidence_requirements) VALUES

('sg-monitoring', 'sg-imda-agentic', 'Section 3.1', 'Continuous Agent Monitoring', 'Operators of agentic AI systems should implement continuous monitoring of agent behavior, including tracking of actions taken, decisions made, tools accessed, and data processed. Monitoring should be proportionate to the autonomy level and risk profile of the agent.', 'monitoring', NULL, 'operator', NULL, 0, '["agent_action_logs","tool_access_records","decision_audit_trail","behavioral_anomaly_detection","monitoring_dashboard"]'),

('sg-escalation', 'sg-imda-agentic', 'Section 3.2', 'Escalation Protocols', 'Operators should define clear escalation protocols for when agentic AI systems encounter situations outside their intended operating parameters, including automatic escalation to human operators and graceful degradation procedures.', 'human_oversight', NULL, 'operator', NULL, 0, '["escalation_policy_document","trigger_condition_definitions","human_operator_notification_system","graceful_degradation_procedures"]'),

('sg-sandboxing', 'sg-imda-agentic', 'Section 3.3', 'Sandboxing and Containment', 'Agentic AI systems should operate within defined boundaries and containment mechanisms. Operators should implement sandboxing for testing and validation before production deployment, with clear boundaries on agent authority and resource access.', 'risk_assessment', NULL, 'operator', NULL, 0, '["sandbox_environment_documentation","boundary_definitions","authority_limits","resource_access_controls","pre_production_test_results"]'),

('sg-accountability', 'sg-imda-agentic', 'Section 4.1', 'Accountability Framework', 'Clear accountability structures should be established for agentic AI systems, defining who is responsible for agent actions, decisions, and outcomes at each stage of the agent lifecycle.', 'transparency', NULL, 'all', NULL, 0, '["accountability_matrix","role_responsibility_definitions","liability_allocation","governance_structure_documentation"]'),

('sg-lifecycle', 'sg-imda-agentic', 'Section 4.2', 'Lifecycle Governance', 'Governance controls should span the entire agent lifecycle from design through deployment, operation, and decommissioning. This includes version control, change management, and retirement procedures.', 'audit', NULL, 'all', NULL, 0, '["lifecycle_governance_plan","version_control_records","change_management_logs","decommissioning_procedures"]'),

('sg-transparency-agent', 'sg-imda-agentic', 'Section 5.1', 'Agent Identity and Transparency', 'Agentic AI systems should clearly identify themselves as AI agents when interacting with humans or other systems. Operators should maintain transparency about agent capabilities, limitations, and the scope of agent authority.', 'transparency', NULL, 'operator', NULL, 0, '["agent_identity_disclosure","capability_documentation","limitation_declarations","authority_scope_definitions"]'),

('sg-data-handling', 'sg-imda-agentic', 'Section 5.2', 'Agent Data Handling', 'Agentic AI systems that access, process, or transmit data should do so in compliance with applicable data protection requirements. Operators should implement data minimization, purpose limitation, and access controls for agent data operations.', 'data_governance', NULL, 'operator', NULL, 0, '["data_handling_policy","data_minimization_evidence","purpose_limitation_controls","access_control_logs"]'),

('sg-incident-response', 'sg-imda-agentic', 'Section 6.1', 'Incident Response for Agent Failures', 'Operators should establish incident response procedures specific to agentic AI system failures, including containment, investigation, remediation, and reporting processes.', 'incident_reporting', NULL, 'operator', NULL, 0, '["incident_response_plan","containment_procedures","investigation_protocols","remediation_records","post_incident_reports"]');


-- ============================================
-- OBLIGATIONS - Colorado AI Act
-- ============================================

INSERT INTO obligations (id, regulation_id, article_reference, title, description, category, risk_level, applies_to, enforcement_date, is_mandatory, evidence_requirements) VALUES

('co-impact-assessment', 'co-ai-act', 'Section 6-1-1703', 'Impact Assessment for High-Risk AI', 'Deployers of high-risk AI systems must complete an impact assessment before deploying and annually thereafter. Assessment must document the purpose, intended benefits, potential risks of algorithmic discrimination, data used, and outputs produced.', 'risk_assessment', 'high', 'deployer', '2026-02-01', 1, '["impact_assessment_document","annual_review_records","risk_of_discrimination_analysis","data_documentation","output_analysis"]'),

('co-reasonable-care', 'co-ai-act', 'Section 6-1-1702', 'Duty of Reasonable Care', 'Developers and deployers of high-risk AI systems must use reasonable care to protect consumers from known or reasonably foreseeable risks of algorithmic discrimination.', 'risk_assessment', 'high', 'all', '2026-02-01', 1, '["discrimination_testing_results","bias_mitigation_measures","risk_monitoring_records","corrective_actions_taken"]'),

('co-consumer-notification', 'co-ai-act', 'Section 6-1-1704', 'Consumer Notification Requirements', 'Deployers must notify consumers when a high-risk AI system makes or is a substantial factor in making a consequential decision concerning the consumer. Notification must include description of the AI system, contact information, and right to appeal.', 'transparency', 'high', 'deployer', '2026-02-01', 1, '["notification_templates","notification_delivery_records","appeal_process_documentation","consumer_communication_logs"]'),

('co-developer-documentation', 'co-ai-act', 'Section 6-1-1702(2)', 'Developer Documentation Requirements', 'Developers must make available to deployers documentation describing the high-risk AI system capabilities, known limitations, intended uses, and results of testing for algorithmic discrimination.', 'transparency', 'high', 'provider', '2026-02-01', 1, '["system_capability_documentation","limitation_disclosures","intended_use_statements","discrimination_testing_reports"]'),

('co-record-retention', 'co-ai-act', 'Section 6-1-1706', 'Record Retention', 'Developers and deployers must retain records demonstrating compliance, including impact assessments, risk management documentation, and consumer notifications for a period of at least three years.', 'record_keeping', 'high', 'all', '2026-02-01', 1, '["document_retention_policy","archived_impact_assessments","archived_risk_documents","archived_notifications","retention_compliance_audit"]');


-- ============================================
-- DEADLINES
-- ============================================

INSERT INTO deadlines (id, regulation_id, obligation_id, title, description, deadline_date, deadline_type, penalty_for_miss, status) VALUES

-- EU AI Act deadlines
('eu-deadline-prohibited', 'eu-ai-act', NULL, 'EU AI Act - Prohibited AI Practices', 'Ban on prohibited AI practices takes effect (social scoring, real-time biometric identification in public spaces, emotion recognition in workplaces/schools).', '2025-02-02', 'enforcement', 'Up to EUR 35 million or 7% of global annual turnover', 'passed'),

('eu-deadline-gpai', 'eu-ai-act', NULL, 'EU AI Act - GPAI Model Obligations', 'General-purpose AI model providers must comply with transparency and documentation requirements.', '2025-08-02', 'enforcement', 'Up to EUR 15 million or 3% of global annual turnover', 'passed'),

('eu-deadline-high-risk', 'eu-ai-act', 'eu-art12-logging', 'EU AI Act - High-Risk AI System Requirements', 'Full enforcement of obligations for high-risk AI systems including logging, transparency, human oversight, risk management, data governance, and conformity assessment.', '2026-08-02', 'enforcement', 'Up to EUR 15 million or 3% of global annual turnover', 'upcoming'),

('eu-deadline-registration', 'eu-ai-act', NULL, 'EU AI Act - EU Database Registration', 'High-risk AI systems must be registered in the EU database before being placed on the market.', '2026-08-02', 'registration', 'Up to EUR 15 million or 3% of global annual turnover', 'upcoming'),

-- Colorado AI Act deadlines
('co-deadline-enforcement', 'co-ai-act', NULL, 'Colorado AI Act - Full Enforcement', 'All provisions of the Colorado AI Act take effect. Deployers and developers must comply with impact assessment, reasonable care, notification, and documentation requirements.', '2026-02-01', 'enforcement', 'Enforcement by Colorado Attorney General, up to $20,000 per violation', 'passed'),

('co-deadline-annual-assessment', 'co-ai-act', 'co-impact-assessment', 'Colorado AI Act - Annual Impact Assessment Due', 'Deployers must complete annual impact assessment reviews for all deployed high-risk AI systems.', '2027-02-01', 'assessment', 'Enforcement by Colorado Attorney General', 'upcoming'),

-- Singapore IMDA deadlines (voluntary but tracked)
('sg-deadline-framework', 'sg-imda-agentic', NULL, 'Singapore IMDA - Agentic AI Framework Published', 'World''s first agentic AI governance framework published. Voluntary adoption encouraged with expectation of industry alignment.', '2026-01-15', 'enforcement', 'No direct penalty - establishes accountability baseline for legal proceedings', 'passed');


-- ============================================
-- USE CASE OBLIGATIONS MAPPING
-- ============================================

INSERT INTO use_case_obligations (id, use_case, regulation_id, obligation_id, applicability, notes) VALUES

-- Hiring/Recruitment AI Agents
('uc-hiring-eu-logging', 'hiring_screening', 'eu-ai-act', 'eu-art12-logging', 'mandatory', 'Employment/recruitment AI classified as high-risk under Annex III, point 4'),
('uc-hiring-eu-transparency', 'hiring_screening', 'eu-ai-act', 'eu-art13-transparency', 'mandatory', 'Candidates must understand how AI system processes their application'),
('uc-hiring-eu-oversight', 'hiring_screening', 'eu-ai-act', 'eu-art14-human-oversight', 'mandatory', 'Human must be able to override AI screening decisions'),
('uc-hiring-co-impact', 'hiring_screening', 'co-ai-act', 'co-impact-assessment', 'mandatory', 'Employment decisions are consequential decisions under the Act'),
('uc-hiring-co-notification', 'hiring_screening', 'co-ai-act', 'co-consumer-notification', 'mandatory', 'Candidates must be notified of AI involvement in hiring decision'),
('uc-hiring-sg-monitoring', 'hiring_screening', 'sg-imda-agentic', 'sg-monitoring', 'recommended', 'Continuous monitoring recommended for high-autonomy hiring agents'),

-- Credit Scoring AI Agents
('uc-credit-eu-logging', 'credit_scoring', 'eu-ai-act', 'eu-art12-logging', 'mandatory', 'Creditworthiness assessment classified as high-risk under Annex III, point 5b'),
('uc-credit-eu-risk', 'credit_scoring', 'eu-ai-act', 'eu-art9-risk-management', 'mandatory', 'Risk management system required for credit scoring AI'),
('uc-credit-co-impact', 'credit_scoring', 'co-ai-act', 'co-impact-assessment', 'mandatory', 'Credit decisions are consequential decisions under the Act'),
('uc-credit-co-care', 'credit_scoring', 'co-ai-act', 'co-reasonable-care', 'mandatory', 'Must test for algorithmic discrimination in credit scoring'),

-- Customer Service AI Agents
('uc-cs-eu-transparency', 'customer_service', 'eu-ai-act', 'eu-art50-transparency-general', 'mandatory', 'Must disclose AI nature when interacting with consumers'),
('uc-cs-sg-transparency', 'customer_service', 'sg-imda-agentic', 'sg-transparency-agent', 'recommended', 'Agent should identify itself as AI'),
('uc-cs-sg-escalation', 'customer_service', 'sg-imda-agentic', 'sg-escalation', 'recommended', 'Should escalate to human when outside operating parameters'),

-- Content Moderation AI Agents
('uc-content-eu-transparency', 'content_moderation', 'eu-ai-act', 'eu-art13-transparency', 'mandatory', 'Moderation decisions should be explainable'),
('uc-content-eu-oversight', 'content_moderation', 'eu-ai-act', 'eu-art14-human-oversight', 'mandatory', 'Human review pathway required for moderation appeals'),
('uc-content-sg-monitoring', 'content_moderation', 'sg-imda-agentic', 'sg-monitoring', 'recommended', 'Monitor for bias in moderation decisions'),

-- Medical Triage AI Agents
('uc-medical-eu-logging', 'medical_triage', 'eu-ai-act', 'eu-art12-logging', 'mandatory', 'Medical devices with AI classified as high-risk'),
('uc-medical-eu-risk', 'medical_triage', 'eu-ai-act', 'eu-art9-risk-management', 'mandatory', 'Comprehensive risk management required'),
('uc-medical-eu-oversight', 'medical_triage', 'eu-ai-act', 'eu-art14-human-oversight', 'mandatory', 'Medical professional oversight required'),
('uc-medical-sg-escalation', 'medical_triage', 'sg-imda-agentic', 'sg-escalation', 'recommended', 'Immediate escalation to medical professional for critical conditions'),

-- Autonomous Coding/Development AI Agents
('uc-coding-sg-sandboxing', 'autonomous_coding', 'sg-imda-agentic', 'sg-sandboxing', 'recommended', 'Code-generating agents should operate in sandboxed environments'),
('uc-coding-sg-monitoring', 'autonomous_coding', 'sg-imda-agentic', 'sg-monitoring', 'recommended', 'Monitor for unauthorized resource access or data exfiltration'),
('uc-coding-sg-lifecycle', 'autonomous_coding', 'sg-imda-agentic', 'sg-lifecycle', 'recommended', 'Version control and change management for agent-generated code'),

-- Financial Trading AI Agents
('uc-trading-eu-logging', 'financial_trading', 'eu-ai-act', 'eu-art12-logging', 'mandatory', 'Financial AI systems require comprehensive audit trails'),
('uc-trading-eu-risk', 'financial_trading', 'eu-ai-act', 'eu-art9-risk-management', 'mandatory', 'Continuous risk management for trading algorithms'),
('uc-trading-eu-oversight', 'financial_trading', 'eu-ai-act', 'eu-art14-human-oversight', 'mandatory', 'Human must be able to halt trading agent operations'),
('uc-trading-sg-monitoring', 'financial_trading', 'sg-imda-agentic', 'sg-monitoring', 'recommended', 'Real-time monitoring of trading agent behavior'),
('uc-trading-sg-escalation', 'financial_trading', 'sg-imda-agentic', 'sg-escalation', 'recommended', 'Automatic escalation for anomalous trading patterns');


-- ============================================
-- CROSS-JURISDICTION OBLIGATION MAPPINGS
-- ============================================

INSERT INTO obligation_mappings (id, obligation_id_a, obligation_id_b, mapping_type, notes) VALUES

-- Logging/Record-keeping equivalences
('map-logging-eu-co', 'eu-art12-logging', 'co-record-retention', 'overlapping', 'Both require record-keeping but EU is more prescriptive about automatic logging; Colorado focuses on retention period (3 years)'),
('map-logging-eu-sg', 'eu-art12-logging', 'sg-monitoring', 'overlapping', 'EU requires automatic event logging; Singapore recommends continuous monitoring which implies logging'),

-- Transparency equivalences
('map-transparency-eu-co', 'eu-art13-transparency', 'co-developer-documentation', 'overlapping', 'Both require documentation of system capabilities and limitations; EU more comprehensive'),
('map-transparency-eu-sg', 'eu-art50-transparency-general', 'sg-transparency-agent', 'equivalent', 'Both require AI systems to identify themselves when interacting with humans'),
('map-notification-eu-co', 'eu-art50-transparency-general', 'co-consumer-notification', 'overlapping', 'EU requires AI disclosure; Colorado requires notification of AI involvement in consequential decisions'),

-- Human Oversight equivalences
('map-oversight-eu-sg', 'eu-art14-human-oversight', 'sg-escalation', 'overlapping', 'EU requires human oversight mechanism; Singapore requires escalation protocols - both ensure human can intervene'),

-- Risk Assessment equivalences
('map-risk-eu-co', 'eu-art9-risk-management', 'co-impact-assessment', 'overlapping', 'EU requires continuous risk management system; Colorado requires impact assessment before deployment and annually'),
('map-risk-eu-sg', 'eu-art9-risk-management', 'sg-sandboxing', 'overlapping', 'EU risk management includes testing; Singapore recommends sandboxing for validation'),

-- Incident Reporting equivalences
('map-incident-eu-sg', 'eu-art62-incident-reporting', 'sg-incident-response', 'overlapping', 'EU mandates reporting serious incidents to authorities; Singapore recommends incident response procedures');
