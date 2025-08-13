import 'dotenv/config';
import fetch from 'node-fetch';

// -----------------------------------------------------------------------------
// handshake.ts
//
// Implements a lightweight inter-repo handshake protocol. Each sibling service
// exposes a `/handshake` endpoint returning its name, version, and capabilities.
// Serafina pings these endpoints at startup to confirm connectivity and log
// their advertised features. Future extensions may cache these capabilities for
// dynamic routing.
// -----------------------------------------------------------------------------

interface HandshakeResponse {
  name: string; // repo or service identifier
  version: string; // semantic version string
  capabilities?: string[]; // optional advertised features
}

export async function performHandshake(): Promise<void> {
  const endpoints = (process.env.HANDSHAKE_ENDPOINTS || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  for (const url of endpoints) {
    try {
      const res = await fetch(`${url.replace(/\/$/, '')}/handshake`, {
        headers: { 'Accept': 'application/json' }
      });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = (await res.json()) as HandshakeResponse;
      console.log(
        `[handshake] ${data.name}@${data.version} -> ${
          data.capabilities?.join(', ') || 'no capabilities'
        }`
      );
    } catch (err) {
      console.warn(`[handshake] failed for ${url}`, err);
    }
  }
}

