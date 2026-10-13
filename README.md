# OmniRoute 3.8.51 — self-hosted AI gateway (one OpenAI-compatible endpoint for 100+ LLM providers). Deploy on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/TEMPLATE_CODE)

OmniRoute is a unified AI router/proxy: connect Claude Code, Codex, Gemini, Copilot, OpenRouter, Ollama and more, then point any client at a single `/v1` endpoint with combos, fallbacks, quotas, cost tracking and a full dashboard.

## Why this template
- **Latest release:** `diegosouzapw/omniroute:3.8.51`, pinned by digest `sha256:8bd462c9f60d8eda79329cfbb6ea7ea723505fe7721beb944f3d43835409e218`.
- **Zero deploy-time config:** every secret (admin password, JWT, API-key encryption key, WS bridge secret, machine salt) is auto-generated.
- **Persistence that actually works:** Railway volume at `/app/data`; a tiny entrypoint fixes the root-owned volume and then drops back to the non-root `node` user (uid 1000) — no `RAILWAY_RUN_UID=0` needed.
- **Secure by default:** HTTPS-only session cookies, `/v1/*` requires an OmniRoute API key, health check on `/healthz`.

## Services
| Service | Source | Notes |
|---|---|---|
| omniroute | this repo (`Dockerfile` → `diegosouzapw/omniroute:3.8.51@sha256:8bd462c9…`) | port 20128, public domain, volume `/app/data`, health `/healthz` |

## Variables
| Variable | Template value | Secret |
|---|---|---|
| PORT | `20128` | |
| HOSTNAME | `0.0.0.0` | |
| DATA_DIR | `/app/data` | |
| NEXT_PUBLIC_BASE_URL | `https://${{RAILWAY_PUBLIC_DOMAIN}}` (OAuth redirects, dashboard links) | |
| BASE_URL | `http://localhost:20128` (internal loopback for sync jobs — upstream docs say keep it loopback) | |
| INITIAL_PASSWORD | `${{secret(24, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")}}` — dashboard admin password | yes |
| JWT_SECRET | `${{secret(64)}}` | yes |
| API_KEY_SECRET | `${{secret(64, "abcdef0123456789")}}` (32-byte hex) | yes |
| OMNIROUTE_WS_BRIDGE_SECRET | `${{secret(48)}}` | yes |
| MACHINE_ID_SALT | `${{secret(32)}}` | yes |
| AUTH_COOKIE_SECURE | `true` | |
| REQUIRE_API_KEY | `true` (create keys in Dashboard → API Keys) | |
| OMNIROUTE_MEMORY_MB | `1024` (raise for big fusion combos) | |
| RAILWAY_DEPLOYMENT_DRAINING_SECONDS | `40` | |

## After deploy
1. Open the public URL and log in with `INITIAL_PASSWORD` (Railway → service → Variables). Change it under Settings → Security.
2. Add providers (OAuth logins or API keys) in the dashboard.
3. Create an API key, then point clients at `https://<your-domain>/v1` (OpenAI-compatible).

## Notes
- Health: `/healthz` (lifecycle, used by Railway), `/livez`, and `/api/monitoring/health` (deep diagnostics).
- Single SQLite database in `/app/data` — run **one replica** only.
- Optional: set `STORAGE_ENCRYPTION_KEY` (`openssl rand -hex 32`) for full DB encryption at rest; back the key up — losing it means losing data.
- Upstream: https://github.com/diegosouzapw/OmniRoute (MIT).
