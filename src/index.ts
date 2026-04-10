/**
 * AI Compliance Monitor - MCP Server & REST API
 * 
 * Structured regulatory intelligence for AI agents operating across jurisdictions.
 * Part of the Dominion Agent Economy Engine.
 * 
 * 4 MCP Tools:
 * - check_obligations: Given agent use case + jurisdiction, return applicable requirements
 * - get_regulation_articles: Structured regulation text with obligation classifications
 * - check_deadline: Enforcement dates, compliance milestones, penalty thresholds
 * - compare_jurisdictions: Side-by-side obligation comparison across regulations
 * 
 * Also serves REST API at /api/* for direct HTTP access.
 */

interface Env {
  DB: D1Database;
}

// ============================================
// MCP Protocol Types
// ============================================

interface MCPRequest {
  jsonrpc: '2.0';
  id?: string | number;
  method: string;
  params?: any;
}

interface MCPResponse {
  jsonrpc: '2.0';
  id?: string | number;
  result?: any;
  error?: { code: number; message: string; data?: any };
}

// ============================================
// Tool Definitions
// ============================================

const TOOLS = [
  {
    name: 'check_obligations',
    description: 'Given an AI agent use case and optional jurisdiction, returns all applicable regulatory obligations with evidence requirements, enforcement dates, and penalty information. Use this to understand what compliance requirements apply to a specific type of AI agent.',
    inputSchema: {
      type: 'object',
      properties: {
        use_case: {
          type: 'string',
          description: 'The AI agent use case to check. Examples: hiring_screening, credit_scoring, customer_service, content_moderation, medical_triage, autonomous_coding, financial_trading',
        },
        jurisdiction_code: {
          type: 'string',
          description: 'Optional jurisdiction code to filter by. Examples: EU, SG, US-CO. Omit to get all jurisdictions.',
        },
      },
      required: ['use_case'],
    },
  },
  {
    name: 'get_regulation_articles',
    description: 'Returns structured, machine-readable regulation details including specific articles, obligation classifications, risk levels, and evidence requirements. Use this to understand the detailed requirements of a specific regulation.',
    inputSchema: {
      type: 'object',
      properties: {
        regulation_id: {
          type: 'string',
          description: 'The regulation identifier. Options: eu-ai-act, sg-imda-agentic, co-ai-act',
        },
        category: {
          type: 'string',
          description: 'Optional filter by obligation category. Options: transparency, record_keeping, human_oversight, risk_assessment, incident_reporting, data_governance, monitoring, audit',
        },
      },
      required: ['regulation_id'],
    },
  },
  {
    name: 'check_deadline',
    description: 'Returns upcoming and recent compliance deadlines with enforcement dates, penalty information, and related obligations. Use this to understand time-sensitive compliance requirements.',
    inputSchema: {
      type: 'object',
      properties: {
        jurisdiction_code: {
          type: 'string',
          description: 'Optional jurisdiction code to filter by. Examples: EU, SG, US-CO',
        },
        include_passed: {
          type: 'boolean',
          description: 'Whether to include deadlines that have already passed. Default: false',
        },
        months_ahead: {
          type: 'number',
          description: 'Number of months ahead to look for upcoming deadlines. Default: 12',
        },
      },
      required: [],
    },
  },
  {
    name: 'compare_jurisdictions',
    description: 'Side-by-side comparison of regulatory obligations across jurisdictions for a given compliance category. Shows equivalent, overlapping, stricter, and weaker mappings between regulations. Use this to understand how requirements differ across borders.',
    inputSchema: {
      type: 'object',
      properties: {
        category: {
          type: 'string',
          description: 'The obligation category to compare. Options: transparency, record_keeping, human_oversight, risk_assessment, incident_reporting, data_governance, monitoring, audit',
        },
        jurisdictions: {
          type: 'array',
          items: { type: 'string' },
          description: 'Optional list of jurisdiction codes to compare. Default: all available. Examples: ["EU", "SG", "US-CO"]',
        },
      },
      required: ['category'],
    },
  },
];

// ============================================
// Tool Handlers
// ============================================

async function handleCheckObligations(db: D1Database, params: any) {
  const { use_case, jurisdiction_code } = params;

  let query = `
    SELECT 
      uco.use_case,
      uco.applicability,
      uco.notes as use_case_notes,
      o.id as obligation_id,
      o.article_reference,
      o.title as obligation_title,
      o.description as obligation_description,
      o.category,
      o.risk_level,
      o.applies_to,
      o.enforcement_date,
      o.is_mandatory,
      o.evidence_requirements,
      r.id as regulation_id,
      r.name as regulation_name,
      r.jurisdiction,
      r.jurisdiction_code,
      r.penalty_max_amount,
      r.penalty_max_percentage
    FROM use_case_obligations uco
    JOIN obligations o ON uco.obligation_id = o.id
    JOIN regulations r ON uco.regulation_id = r.id
    WHERE uco.use_case = ?
  `;
  const bindings: any[] = [use_case];

  if (jurisdiction_code) {
    query += ' AND r.jurisdiction_code = ?';
    bindings.push(jurisdiction_code);
  }

  query += ' ORDER BY o.is_mandatory DESC, r.jurisdiction_code, o.category';

  const results = await db.prepare(query).bind(...bindings).all();

  if (!results.results || results.results.length === 0) {
    // Check if use case exists at all
    const validUseCases = await db.prepare(
      'SELECT DISTINCT use_case FROM use_case_obligations ORDER BY use_case'
    ).all();

    return {
      use_case,
      jurisdiction_filter: jurisdiction_code || 'all',
      obligations_found: 0,
      message: `No obligations found for use case '${use_case}'.`,
      available_use_cases: validUseCases.results?.map((r: any) => r.use_case) || [],
    };
  }

  const obligations = results.results.map((row: any) => ({
    regulation: {
      id: row.regulation_id,
      name: row.regulation_name,
      jurisdiction: row.jurisdiction,
      jurisdiction_code: row.jurisdiction_code,
    },
    obligation: {
      id: row.obligation_id,
      article: row.article_reference,
      title: row.obligation_title,
      description: row.obligation_description,
      category: row.category,
      risk_level: row.risk_level,
      applies_to: row.applies_to,
      is_mandatory: row.is_mandatory === 1,
      enforcement_date: row.enforcement_date,
    },
    applicability: row.applicability,
    use_case_notes: row.use_case_notes,
    evidence_required: row.evidence_requirements ? JSON.parse(row.evidence_requirements) : [],
    penalties: {
      max_amount: row.penalty_max_amount,
      max_percentage_of_turnover: row.penalty_max_percentage,
    },
  }));

  const mandatory = obligations.filter((o: any) => o.obligation.is_mandatory);
  const recommended = obligations.filter((o: any) => !o.obligation.is_mandatory);

  return {
    use_case,
    jurisdiction_filter: jurisdiction_code || 'all',
    obligations_found: obligations.length,
    mandatory_count: mandatory.length,
    recommended_count: recommended.length,
    summary: `Found ${obligations.length} applicable obligations for '${use_case}' agents: ${mandatory.length} mandatory, ${recommended.length} recommended.`,
    mandatory_obligations: mandatory,
    recommended_obligations: recommended,
  };
}

async function handleGetRegulationArticles(db: D1Database, params: any) {
  const { regulation_id, category } = params;

  // Get regulation info
  const regulation = await db.prepare(
    'SELECT * FROM regulations WHERE id = ?'
  ).bind(regulation_id).first();

  if (!regulation) {
    const validRegs = await db.prepare('SELECT id, name FROM regulations').all();
    return {
      error: `Regulation '${regulation_id}' not found.`,
      available_regulations: validRegs.results?.map((r: any) => ({ id: r.id, name: r.name })) || [],
    };
  }

  let query = 'SELECT * FROM obligations WHERE regulation_id = ?';
  const bindings: any[] = [regulation_id];

  if (category) {
    query += ' AND category = ?';
    bindings.push(category);
  }

  query += ' ORDER BY article_reference';

  const obligations = await db.prepare(query).bind(...bindings).all();

  return {
    regulation: {
      id: regulation.id,
      name: regulation.name,
      jurisdiction: regulation.jurisdiction,
      jurisdiction_code: regulation.jurisdiction_code,
      status: regulation.status,
      effective_date: regulation.effective_date,
      full_enforcement_date: regulation.full_enforcement_date,
      summary: regulation.summary,
      source_url: regulation.source_url,
      applies_to_agents: regulation.applies_to_agents === 1,
      penalties: {
        max_amount: regulation.penalty_max_amount,
        max_percentage_of_turnover: regulation.penalty_max_percentage,
      },
    },
    category_filter: category || 'all',
    obligations_count: obligations.results?.length || 0,
    obligations: obligations.results?.map((o: any) => ({
      id: o.id,
      article: o.article_reference,
      title: o.title,
      description: o.description,
      category: o.category,
      risk_level: o.risk_level,
      applies_to: o.applies_to,
      is_mandatory: o.is_mandatory === 1,
      enforcement_date: o.enforcement_date,
      evidence_required: o.evidence_requirements ? JSON.parse(o.evidence_requirements) : [],
    })) || [],
  };
}

async function handleCheckDeadline(db: D1Database, params: any) {
  const { jurisdiction_code, include_passed, months_ahead } = params;
  const monthsToLook = months_ahead || 12;
  const now = new Date();
  const futureDate = new Date();
  futureDate.setMonth(futureDate.getMonth() + monthsToLook);

  let query = `
    SELECT 
      d.*,
      r.name as regulation_name,
      r.jurisdiction,
      r.jurisdiction_code,
      o.title as obligation_title,
      o.category as obligation_category
    FROM deadlines d
    JOIN regulations r ON d.regulation_id = r.id
    LEFT JOIN obligations o ON d.obligation_id = o.id
  `;

  const conditions: string[] = [];
  const bindings: any[] = [];

  if (!include_passed) {
    conditions.push("d.deadline_date >= date('now')");
  }

  if (jurisdiction_code) {
    conditions.push('r.jurisdiction_code = ?');
    bindings.push(jurisdiction_code);
  }

  if (conditions.length > 0) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  query += ' ORDER BY d.deadline_date ASC';

  const results = await db.prepare(query).bind(...bindings).all();

  const deadlines = results.results?.map((d: any) => {
    const deadlineDate = new Date(d.deadline_date);
    const daysUntil = Math.ceil((deadlineDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24));

    return {
      id: d.id,
      title: d.title,
      description: d.description,
      deadline_date: d.deadline_date,
      days_until: daysUntil,
      status: daysUntil < 0 ? 'passed' : daysUntil <= 30 ? 'imminent' : daysUntil <= 90 ? 'approaching' : 'upcoming',
      deadline_type: d.deadline_type,
      penalty_for_miss: d.penalty_for_miss,
      regulation: {
        id: d.regulation_id,
        name: d.regulation_name,
        jurisdiction: d.jurisdiction,
        jurisdiction_code: d.jurisdiction_code,
      },
      related_obligation: d.obligation_title ? {
        title: d.obligation_title,
        category: d.obligation_category,
      } : null,
    };
  }) || [];

  const imminent = deadlines.filter((d: any) => d.status === 'imminent');
  const approaching = deadlines.filter((d: any) => d.status === 'approaching');

  return {
    jurisdiction_filter: jurisdiction_code || 'all',
    include_passed: include_passed || false,
    months_ahead: monthsToLook,
    deadlines_found: deadlines.length,
    imminent_count: imminent.length,
    approaching_count: approaching.length,
    alert: imminent.length > 0
      ? `⚠️ ${imminent.length} deadline(s) within 30 days requiring immediate attention.`
      : approaching.length > 0
      ? `📋 ${approaching.length} deadline(s) within 90 days.`
      : '✅ No imminent deadlines.',
    deadlines,
  };
}

async function handleCompareJurisdictions(db: D1Database, params: any) {
  const { category, jurisdictions } = params;

  let query = `
    SELECT 
      o.*,
      r.name as regulation_name,
      r.jurisdiction,
      r.jurisdiction_code,
      r.penalty_max_amount,
      r.penalty_max_percentage
    FROM obligations o
    JOIN regulations r ON o.regulation_id = r.id
    WHERE o.category = ?
  `;
  const bindings: any[] = [category];

  if (jurisdictions && jurisdictions.length > 0) {
    const placeholders = jurisdictions.map(() => '?').join(',');
    query += ` AND r.jurisdiction_code IN (${placeholders})`;
    bindings.push(...jurisdictions);
  }

  query += ' ORDER BY r.jurisdiction_code, o.article_reference';

  const results = await db.prepare(query).bind(...bindings).all();

  // Get mappings for these obligations
  const obligationIds = results.results?.map((r: any) => r.id) || [];
  let mappings: any[] = [];

  if (obligationIds.length > 0) {
    const idPlaceholders = obligationIds.map(() => '?').join(',');
    const mappingResults = await db.prepare(`
      SELECT * FROM obligation_mappings 
      WHERE obligation_id_a IN (${idPlaceholders}) 
         OR obligation_id_b IN (${idPlaceholders})
    `).bind(...obligationIds, ...obligationIds).all();
    mappings = mappingResults.results || [];
  }

  // Group by jurisdiction
  const byJurisdiction: Record<string, any[]> = {};
  for (const row of (results.results || []) as any[]) {
    const key = row.jurisdiction_code;
    if (!byJurisdiction[key]) byJurisdiction[key] = [];
    byJurisdiction[key].push({
      id: row.id,
      article: row.article_reference,
      title: row.title,
      description: row.description,
      is_mandatory: row.is_mandatory === 1,
      risk_level: row.risk_level,
      applies_to: row.applies_to,
      enforcement_date: row.enforcement_date,
      evidence_required: row.evidence_requirements ? JSON.parse(row.evidence_requirements) : [],
      penalties: {
        max_amount: row.penalty_max_amount,
        max_percentage_of_turnover: row.penalty_max_percentage,
      },
    });
  }

  return {
    category,
    jurisdictions_compared: Object.keys(byJurisdiction),
    comparison: byJurisdiction,
    cross_jurisdiction_mappings: mappings.map((m: any) => ({
      obligation_a: m.obligation_id_a,
      obligation_b: m.obligation_id_b,
      relationship: m.mapping_type,
      notes: m.notes,
    })),
    summary: `Compared '${category}' obligations across ${Object.keys(byJurisdiction).length} jurisdiction(s). Found ${mappings.length} cross-jurisdiction mapping(s).`,
  };
}

// ============================================
// Observatory Telemetry (Flywheel 1 integration)
// ============================================

const OBSERVATORY_URL = 'https://dominion-observatory.sgdata.workers.dev/mcp';
const SERVER_ID = 'ai-compliance-monitor';

async function reportToObservatory(
  toolName: string,
  success: boolean,
  responseTimeMs: number,
  metadata?: Record<string, any>
) {
  try {
    await fetch(OBSERVATORY_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: `telemetry-${Date.now()}`,
        method: 'tools/call',
        params: {
          name: 'report_interaction',
          arguments: {
            server_id: SERVER_ID,
            tool_name: toolName,
            success,
            response_time_ms: responseTimeMs,
            metadata: JSON.stringify({
              source: 'ai-compliance-monitor',
              version: '1.0.0',
              ...metadata,
            }),
          },
        },
      }),
    });
  } catch {
    // Non-blocking: Observatory telemetry failure should never break the service
  }
}

async function registerWithObservatory() {
  try {
    await fetch(OBSERVATORY_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'register-acm',
        method: 'tools/call',
        params: {
          name: 'register_server',
          arguments: {
            server_id: SERVER_ID,
            name: 'AI Compliance Monitor',
            description: 'Structured regulatory intelligence for AI agents across jurisdictions',
            url: 'https://ai-compliance-monitor.sgdata.workers.dev/mcp',
            category: 'compliance',
          },
        },
      }),
    });
  } catch {
    // Non-blocking
  }
}

// ============================================
// MCP Protocol Handler
// ============================================

async function handleMCPRequest(request: MCPRequest, db: D1Database): Promise<MCPResponse> {
  const { method, params, id } = request;

  switch (method) {
    case 'initialize':
      return {
        jsonrpc: '2.0',
        id,
        result: {
          protocolVersion: '2024-11-05',
          capabilities: { tools: { listChanged: false } },
          serverInfo: {
            name: 'ai-compliance-monitor',
            version: '1.0.0',
            description: 'Structured regulatory intelligence for AI agents. Check compliance obligations, deadlines, and cross-jurisdiction requirements for EU AI Act, Singapore IMDA Agentic AI Framework, and Colorado AI Act.',
          },
        },
      };

    case 'notifications/initialized':
      return { jsonrpc: '2.0', id, result: {} };

    case 'tools/list':
      return { jsonrpc: '2.0', id, result: { tools: TOOLS } };

    case 'tools/call': {
      const toolName = params?.name;
      const toolArgs = params?.arguments || {};
      const startTime = Date.now();

      // Track usage
      await db.prepare(
        'INSERT INTO api_usage (tool_name, jurisdiction_code) VALUES (?, ?)'
      ).bind(toolName, toolArgs.jurisdiction_code || toolArgs.jurisdictions?.[0] || null).run();

      let result: any;

      try {
        switch (toolName) {
          case 'check_obligations':
            result = await handleCheckObligations(db, toolArgs);
            break;
          case 'get_regulation_articles':
            result = await handleGetRegulationArticles(db, toolArgs);
            break;
          case 'check_deadline':
            result = await handleCheckDeadline(db, toolArgs);
            break;
          case 'compare_jurisdictions':
            result = await handleCompareJurisdictions(db, toolArgs);
            break;
          default:
            // Report failure to Observatory
            reportToObservatory(toolName || 'unknown', false, Date.now() - startTime, { error: 'unknown_tool' });
            return {
              jsonrpc: '2.0',
              id,
              error: { code: -32601, message: `Unknown tool: ${toolName}` },
            };
        }
      } catch (error: any) {
        // Report failure to Observatory
        reportToObservatory(toolName || 'unknown', false, Date.now() - startTime, { error: error.message });
        return {
          jsonrpc: '2.0',
          id,
          error: { code: -32603, message: `Tool execution error: ${error.message}` },
        };
      }

      // Report success to Observatory (non-blocking)
      const responseTimeMs = Date.now() - startTime;
      reportToObservatory(toolName, true, responseTimeMs, {
        jurisdiction: toolArgs.jurisdiction_code || toolArgs.jurisdictions?.[0] || null,
        use_case: toolArgs.use_case || null,
      });

      return {
        jsonrpc: '2.0',
        id,
        result: {
          content: [
            {
              type: 'text',
              text: JSON.stringify(result, null, 2),
            },
          ],
        },
      };
    }

    case 'ping':
      return { jsonrpc: '2.0', id, result: {} };

    default:
      return {
        jsonrpc: '2.0',
        id,
        error: { code: -32601, message: `Method not found: ${method}` },
      };
  }
}

// ============================================
// REST API Handler
// ============================================

async function handleRESTRequest(request: Request, db: D1Database, path: string): Promise<Response> {
  const url = new URL(request.url);
  const params = Object.fromEntries(url.searchParams);

  // Track REST API usage
  const toolName = path.split('/').pop() || 'unknown';
  await db.prepare(
    'INSERT INTO api_usage (tool_name, jurisdiction_code) VALUES (?, ?)'
  ).bind(`rest:${toolName}`, params.jurisdiction_code || null).run();

  let result: any;

  try {
    switch (path) {
      case '/api/obligations':
        if (!params.use_case) {
          return new Response(JSON.stringify({ error: 'use_case parameter required' }), {
            status: 400,
            headers: { 'Content-Type': 'application/json' },
          });
        }
        result = await handleCheckObligations(db, params);
        break;

      case '/api/regulations':
        if (!params.regulation_id) {
          // List all regulations
          const regs = await db.prepare('SELECT * FROM regulations').all();
          result = { regulations: regs.results };
        } else {
          result = await handleGetRegulationArticles(db, params);
        }
        break;

      case '/api/deadlines':
        result = await handleCheckDeadline(db, {
          ...params,
          include_passed: params.include_passed === 'true',
          months_ahead: params.months_ahead ? parseInt(params.months_ahead) : undefined,
        });
        break;

      case '/api/compare':
        if (!params.category) {
          return new Response(JSON.stringify({ error: 'category parameter required' }), {
            status: 400,
            headers: { 'Content-Type': 'application/json' },
          });
        }
        result = await handleCompareJurisdictions(db, {
          ...params,
          jurisdictions: params.jurisdictions ? params.jurisdictions.split(',') : undefined,
        });
        break;

      case '/api/stats':
        const stats = await db.prepare(`
          SELECT 
            (SELECT COUNT(*) FROM regulations) as regulation_count,
            (SELECT COUNT(*) FROM obligations) as obligation_count,
            (SELECT COUNT(*) FROM deadlines) as deadline_count,
            (SELECT COUNT(*) FROM obligation_mappings) as mapping_count,
            (SELECT COUNT(DISTINCT use_case) FROM use_case_obligations) as use_case_count,
            (SELECT COUNT(*) FROM api_usage) as total_api_calls
        `).first();
        result = {
          service: 'AI Compliance Monitor',
          version: '1.0.0',
          data_coverage: stats,
          jurisdictions: ['EU', 'SG', 'US-CO'],
          last_updated: new Date().toISOString(),
        };
        break;

      default:
        return new Response(JSON.stringify({
          error: 'Not found',
          available_endpoints: [
            'GET /api/obligations?use_case=<use_case>&jurisdiction_code=<code>',
            'GET /api/regulations?regulation_id=<id>&category=<category>',
            'GET /api/deadlines?jurisdiction_code=<code>&include_passed=<bool>&months_ahead=<n>',
            'GET /api/compare?category=<category>&jurisdictions=<code1,code2>',
            'GET /api/stats',
          ],
        }), {
          status: 404,
          headers: { 'Content-Type': 'application/json' },
        });
    }
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }

  return new Response(JSON.stringify(result, null, 2), {
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'X-Service': 'ai-compliance-monitor',
    },
  });
}

// ============================================
// SSE Transport for MCP
// ============================================

function createSSEResponse(data: any): string {
  return `data: ${JSON.stringify(data)}\n\n`;
}

// ============================================
// Main Worker Handler
// ============================================

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Health check
    if (path === '/' || path === '/health') {
      // Auto-register with Observatory (non-blocking, idempotent)
      registerWithObservatory();
      return new Response(JSON.stringify({
        service: 'AI Compliance Monitor',
        status: 'operational',
        version: '1.0.0',
        description: 'Structured regulatory intelligence for AI agents operating across jurisdictions.',
        mcp_endpoint: '/mcp',
        rest_api: '/api',
        coverage: {
          regulations: 3,
          jurisdictions: ['EU', 'SG', 'US-CO'],
          use_cases: ['hiring_screening', 'credit_scoring', 'customer_service', 'content_moderation', 'medical_triage', 'autonomous_coding', 'financial_trading'],
        },
        links: {
          mcp_server: `${url.origin}/mcp`,
          api_docs: `${url.origin}/api`,
          github: 'https://github.com/vdineshk/ai-compliance-monitor',
        },
      }, null, 2), {
        headers: { 'Content-Type': 'application/json', ...corsHeaders },
      });
    }

    // REST API
    if (path.startsWith('/api')) {
      return handleRESTRequest(request, env.DB, path);
    }

    // MCP endpoint (JSON-RPC over HTTP POST)
    if (path === '/mcp' || path === '/mcp/') {
      if (request.method === 'GET') {
        // Return server info for GET requests (directory listing compatibility)
        return new Response(JSON.stringify({
          name: 'ai-compliance-monitor',
          version: '1.0.0',
          description: 'Structured regulatory intelligence for AI agents. Check compliance obligations, deadlines, and cross-jurisdiction requirements for EU AI Act, Singapore IMDA Agentic AI Framework, and Colorado AI Act.',
          tools: TOOLS.map(t => ({ name: t.name, description: t.description })),
          protocol: 'MCP/1.0',
          transport: 'streamable-http',
        }, null, 2), {
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        });
      }

      if (request.method !== 'POST') {
        return new Response('Method not allowed', { status: 405 });
      }

      try {
        const body = await request.json() as MCPRequest | MCPRequest[];
        
        // Handle batch requests
        if (Array.isArray(body)) {
          const responses = await Promise.all(
            body.map(req => handleMCPRequest(req, env.DB))
          );
          return new Response(JSON.stringify(responses), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders },
          });
        }

        const response = await handleMCPRequest(body, env.DB);
        return new Response(JSON.stringify(response), {
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        });
      } catch (error: any) {
        return new Response(JSON.stringify({
          jsonrpc: '2.0',
          error: { code: -32700, message: `Parse error: ${error.message}` },
        }), {
          status: 400,
          headers: { 'Content-Type': 'application/json', ...corsHeaders },
        });
      }
    }

    // SSE endpoint for MCP streaming transport
    if (path === '/sse' || path === '/mcp/sse') {
      const { readable, writable } = new TransformStream();
      const writer = writable.getWriter();
      const encoder = new TextEncoder();

      // Send initial connection event
      writer.write(encoder.encode(createSSEResponse({
        type: 'connection',
        status: 'connected',
        server: 'ai-compliance-monitor',
        version: '1.0.0',
      })));

      return new Response(readable, {
        headers: {
          'Content-Type': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Connection': 'keep-alive',
          ...corsHeaders,
        },
      });
    }

    return new Response('Not found', { status: 404 });
  },
} satisfies ExportedHandler<Env>;
