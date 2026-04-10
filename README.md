# AI Compliance Monitor

**Structured regulatory intelligence for AI agents operating across jurisdictions.**

The first MCP server purpose-built for AI agent compliance. Check obligations, deadlines, and cross-jurisdiction requirements for the EU AI Act, Singapore IMDA Agentic AI Framework, and Colorado AI Act.

## Why This Exists

AI agents operating across borders face a fragmented regulatory landscape. The EU AI Act requires automatic logging (Article 12). Singapore's IMDA framework mandates escalation protocols. Colorado demands impact assessments. **No existing tool maps agent behavior to specific regulatory requirements across jurisdictions.**

This server provides machine-readable, structured regulatory intelligence that AI agents can query at runtime to understand their compliance obligations.

## MCP Tools

| Tool | Description |
|------|-------------|
| `check_obligations` | Given an agent use case + jurisdiction → applicable requirements |
| `get_regulation_articles` | Structured regulation details with evidence requirements |
| `check_deadline` | Enforcement dates, penalties, compliance milestones |
| `compare_jurisdictions` | Side-by-side obligation comparison across regulations |

## Quick Start

### Connect via MCP

```
Server URL: https://ai-compliance-monitor.sgdata.workers.dev/mcp
```

### REST API

```bash
# Check obligations for a hiring agent
curl "https://ai-compliance-monitor.sgdata.workers.dev/api/obligations?use_case=hiring_screening"

# Get EU AI Act requirements
curl "https://ai-compliance-monitor.sgdata.workers.dev/api/regulations?regulation_id=eu-ai-act"

# Check upcoming deadlines
curl "https://ai-compliance-monitor.sgdata.workers.dev/api/deadlines"

# Compare transparency requirements across jurisdictions
curl "https://ai-compliance-monitor.sgdata.workers.dev/api/compare?category=transparency"

# Service stats
curl "https://ai-compliance-monitor.sgdata.workers.dev/api/stats"
```

## Regulatory Coverage

| Regulation | Jurisdiction | Status | Key Deadline |
|-----------|-------------|--------|-------------|
| EU AI Act | European Union | Active | Aug 2, 2026 (high-risk) |
| IMDA Agentic AI Framework | Singapore | Active (voluntary) | Published Jan 2026 |
| Colorado AI Act (SB 24-205) | Colorado, US | Active | Feb 1, 2026 (enforced) |

### Use Cases Covered
- Hiring/recruitment screening
- Credit scoring
- Customer service agents
- Content moderation
- Medical triage
- Autonomous coding agents
- Financial trading agents

## Deployment (Self-Host)

### Prerequisites
- Cloudflare account with Workers enabled
- Wrangler CLI (`npm install -g wrangler`)
- `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` environment variables

### Deploy

```bash
# Clone the repo
git clone https://github.com/vdineshk/ai-compliance-monitor.git
cd ai-compliance-monitor

# Install dependencies
npm install

# Create D1 database
npx wrangler d1 create ai-compliance-monitor-db
# Copy the database_id from output into wrangler.toml

# Run migrations
npx wrangler d1 migrations apply ai-compliance-monitor-db --remote

# Seed regulatory data
npx wrangler d1 execute ai-compliance-monitor-db --remote --file=./migrations/0002_seed_data.sql

# Deploy
npx wrangler deploy
```

### Dry Run (verify free-tier compliance)
```bash
npx wrangler deploy --dry-run
```

## Data Model

- **Regulations**: Top-level regulatory frameworks (EU AI Act, IMDA, Colorado)
- **Obligations**: Specific requirements within each regulation, classified by category
- **Deadlines**: Enforcement dates with penalty information
- **Obligation Mappings**: Cross-jurisdiction equivalence mappings
- **Use Case Obligations**: Maps agent use cases to applicable obligations

## Part of the Dominion Agent Economy Engine

This server feeds behavioral interaction data to the [Dominion Observatory](https://dominion-observatory.sgdata.workers.dev/mcp), the trust scoring layer for the AI agent economy.

## License

MIT

## Contact

Built by [@vdineshk](https://github.com/vdineshk) | Singapore
