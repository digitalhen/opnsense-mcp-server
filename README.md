# OPNsense MCP Server

A modular Model Context Protocol (MCP) server that provides **88 module-based tools** giving access to over 2000 OPNsense firewall management methods through a type-safe TypeScript interface.

## Features

- **Modular Architecture** - 88 logical tools (one per module) instead of 2000+ individual tools
- **Complete API Coverage** - Access to 752 core methods and 1271 plugin methods
- **Type-Safe** - Full TypeScript support with [@richard-stovall/opnsense-typescript-client](https://www.npmjs.com/package/@richard-stovall/opnsense-typescript-client) v0.5.3
- **Plugin Support** - Optional support for 64 plugin modules
- **Smart Organization** - Related operations grouped by module for easier discovery

The MCP server acts as a bridge between AI assistants (like Claude Desktop, Claude.ai, Cursor) and your OPNsense firewall, providing secure API access through a modular tool interface.

- **stdio mode** — runs as a local process for Claude Desktop, Claude Code, and Cursor
- **hosted mode** — runs as an HTTP server with OAuth for Claude.ai and other remote MCP clients

<small>Usage in Claude Desktop</small>
![OPNsense MCP Server Network Architecture](https://github.com/user-attachments/assets/c7742683-7f25-437a-9747-250f48472a6a)

<small>Usage in Claude Code</small>
<img width="920" alt="image" src="https://github.com/user-attachments/assets/7833e6c6-45e3-4c98-a234-46a0da8c362d" />

## Installation

### As an MCP Server

This package is designed to be used as an MCP (Model Context Protocol) server with AI assistants like Claude Desktop, Cursor, or other MCP-compatible clients.

### Prerequisites

- Node.js 18 or higher
- An OPNsense firewall with API access enabled
- API key and secret from your OPNsense installation

### Install from npm

```bash
npm install -g @richard-stovall/opnsense-mcp-server
```

## Usage as an MCP Server

### Claude Desktop Configuration

Add the following to your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`  
**Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "opnsense": {
      "command": "npx",
      "args": ["-y", "@richard-stovall/opnsense-mcp-server"],
      "env": {
        "OPNSENSE_URL": "https://192.168.1.1",
        "OPNSENSE_API_KEY": "your-api-key",
        "OPNSENSE_API_SECRET": "your-api-secret",
        "OPNSENSE_VERIFY_SSL": "false"
      }
    }
  }
}
```

#### Alternative Configuration Methods

**Using Command Line Arguments:**

```json
{
  "mcpServers": {
    "opnsense": {
      "command": "node",
      "args": [
        "/path/to/opnsense-mcp-server/index.js",
        "--url",
        "https://YOUR-OPNSENSE-IP",
        "--api-key",
        "YOUR-API-KEY",
        "--api-secret",
        "YOUR-API-SECRET",
        "--no-verify-ssl"
      ]
    }
  }
}
```

**Enable Plugin Tools:**
To include all 64 plugin module tools, add `"--plugins"` to the args or set `"INCLUDE_PLUGINS": "true"` in env.

#### Testing the Setup

Once configured, you can test the connection by asking Claude:

- "What MCP tools are available?"
- "Use core_manage to get the system status"
- "Use firewall_manage to search for all aliases"
- "Use interfaces_manage to list all network interfaces"

#### Troubleshooting Claude Desktop Setup

**Connection Issues:**

1. Verify your OPNsense API is enabled
2. Check that the API key has appropriate permissions
3. Ensure the IP/hostname is accessible from your machine
4. For self-signed certificates, use `--no-verify-ssl` or set `"OPNSENSE_VERIFY_SSL": "false"`

**View Server Logs:**
Check Claude Desktop logs for any error messages from the MCP server.

**Test Manually:**
You can test the server manually before using with Claude Desktop:

```bash
node /path/to/opnsense-mcp-server/index.js \
  --url https://YOUR-OPNSENSE-IP \
  --api-key YOUR-API-KEY \
  --api-secret YOUR-API-SECRET \
  --no-verify-ssl
```

This should output:

```
OPNsense MCP server v0.6.0 (modular) started
Core tools: 24 modules
Plugin tools: 64 modules (disabled)
Total available: 24 modules
```

### Cursor Configuration

Add to your Cursor settings (`.cursor/mcp.json` in your project or `~/.cursor/mcp.json` globally):

```json
{
  "mcpServers": {
    "opnsense": {
      "command": "npx",
      "args": ["-y", "@richard-stovall/opnsense-mcp-server"],
      "env": {
        "OPNSENSE_URL": "https://192.168.1.1",
        "OPNSENSE_API_KEY": "your-api-key",
        "OPNSENSE_API_SECRET": "your-api-secret",
        "OPNSENSE_VERIFY_SSL": "false"
      }
    }
  }
}
```

### Claude.ai (Hosted Mode)

For Claude.ai and other remote MCP clients, you can run the server in **hosted mode** with HTTP transport and OAuth authentication.

#### Prerequisites

- Docker (recommended) or Node.js 18+
- A reverse proxy or tunnel (e.g. Cloudflare Tunnel, ngrok) to expose the server publicly with HTTPS
- An OPNsense API key and secret

#### Quick Start with Docker

```bash
# Clone the repository
git clone https://github.com/Pixelworlds/opnsense-mcp-server.git
cd opnsense-mcp-server

# Create your .env file
cp .env.example .env
# Edit .env with your OPNsense credentials, OAuth password, and public URL
```

Edit `.env`:

```env
OPNSENSE_URL=https://192.168.1.1
OPNSENSE_API_KEY=your-api-key
OPNSENSE_API_SECRET=your-api-secret
OPNSENSE_VERIFY_SSL=false
OAUTH_PASSWORD=your-secret-password
PUBLIC_URL=https://opnsense-mcp.yourdomain.com
PORT=3100
```

```bash
# Start the server
docker compose up -d --build
```

#### Expose via Cloudflare Tunnel

If you use Cloudflare Tunnel, add a public hostname route pointing to `http://opnsense-mcp:3100` (or `http://localhost:3100` if not on the same Docker network).

#### Connect to Claude.ai

1. Go to Claude.ai **Settings > Integrations > Add custom connector**
2. **Name**: OPNsense
3. **URL**: `https://opnsense-mcp.yourdomain.com/mcp`
4. Leave OAuth Client ID/Secret blank (the server handles dynamic client registration)
5. When prompted, enter your `OAUTH_PASSWORD` to authorize

#### Running without Docker

```bash
npm install
npx tsx src/hosted.ts
```

#### How OAuth Works

The hosted mode implements OAuth 2.0 with PKCE for Claude.ai compatibility:

1. Claude.ai discovers endpoints via `/.well-known/oauth-authorization-server`
2. It registers itself as an OAuth client via `/register`
3. You're redirected to a login page where you enter your `OAUTH_PASSWORD`
4. Claude.ai receives an access token and uses it for all MCP requests

### Configuration Options

The server accepts configuration through environment variables:

- `OPNSENSE_URL` - OPNsense host URL (required)
- `OPNSENSE_API_KEY` - API key for authentication (required)
- `OPNSENSE_API_SECRET` - API secret for authentication (required)
- `INCLUDE_PLUGINS` - Set to "true" to enable 64 plugin module tools (optional)
- `OPNSENSE_VERIFY_SSL` - Set to "false" to disable SSL verification (development only)

**Hosted mode only:**

- `OAUTH_PASSWORD` - Password for the OAuth authorization page (required for hosted mode)
- `PUBLIC_URL` - Public URL of the server, e.g. `https://opnsense-mcp.yourdomain.com` (required for hosted mode)
- `PORT` - HTTP server port (default: `3100`)

## How It Works

The modular MCP server provides your AI assistant with 88 module-based tools. Each tool represents an OPNsense module and accepts a `method` parameter to specify the operation.

**Tool Usage Pattern:**

```json
{
  "tool": "firewall_manage",
  "arguments": {
    "method": "aliasSearchItem",
    "params": {
      "searchPhrase": "web"
    }
  }
}
```

**Example prompts:**

- "Use core_manage to check system status"
- "Use firewall_manage to list all firewall aliases"
- "Use interfaces_manage to get network interface information"
- "Use plugin_nginx_manage to check the web server configuration"
- "Use diagnostics_manage to view the ARP table"

The modular approach makes it easy to discover related functionality - all firewall operations are in `firewall_manage`, all VPN operations in their respective modules (`openvpn_manage`, `ipsec_manage`, `wireguard_manage`).

## Available Module Tools

### Core Modules (24 tools)

Each tool provides access to all methods within that module:

| Tool Name            | Description              | Example Methods                                         |
| -------------------- | ------------------------ | ------------------------------------------------------- |
| `core_manage`        | Core system functions    | `backupBackups`, `systemReboot`, `firmwareInfo`         |
| `firewall_manage`    | Firewall rules & aliases | `aliasSearchItem`, `filterAddRule`, `natSearchRule`     |
| `interfaces_manage`  | Network interfaces       | `getInterfaces`, `vlanAddItem`, `setInterface`          |
| `diagnostics_manage` | System diagnostics       | `interfaceGetArp`, `systemActivityGetActivity`          |
| `auth_manage`        | Authentication           | `userSearchUser`, `groupSearchGroup`                    |
| `firmware_manage`    | Firmware updates         | `check`, `update`, `upgrade`, `changelog`               |
| `openvpn_manage`     | OpenVPN                  | `instancesSearch`, `instancesAdd`, `serviceReconfigure` |
| `ipsec_manage`       | IPsec VPN                | `tunnelSearchPhase1`, `connectionStatus`                |
| `wireguard_manage`   | WireGuard VPN            | `serverSearchServer`, `clientSearchClient`              |
| `unbound_manage`     | DNS resolver             | `hostOverrideSearchItem`, `serviceReconfigure`          |
| `dhcpv4_manage`      | DHCP server              | `searchLease`, `addReservation`                         |

### Plugin Modules (64 tools when enabled)

Popular plugin modules:

| Tool Name                  | Description           | Example Methods                             |
| -------------------------- | --------------------- | ------------------------------------------- |
| `plugin_nginx_manage`      | Nginx web server      | `generalGet`, `upstreamSearchUpstream`      |
| `plugin_haproxy_manage`    | HAProxy load balancer | `serverSearchServer`, `statsGet`            |
| `plugin_caddy_manage`      | Caddy web server      | `reverseProxySearchDomain`, `serviceStatus` |
| `plugin_bind_manage`       | BIND DNS              | `domainSearchDomain`, `recordSearchRecord`  |
| `plugin_acmeclient_manage` | Let's Encrypt         | `certificatesSearch`, `certificatesIssue`   |

## Building from Source

If you want to contribute or customize the server:

```bash
# Clone the repository
git clone https://github.com/richard-stovall/opnsense-mcp-server.git
cd opnsense-mcp-server

# Install dependencies with Yarn 4.9.2
yarn install

# Build the project
yarn build

# Run locally
yarn start
```

## Development

### Development Scripts

```bash
yarn generate-tools  # Generate tool definitions
yarn build          # Build the server
yarn build:all      # Generate tools and build
yarn dev            # Run with hot reload
yarn type-check     # Type check without emitting
yarn start          # Start the server
```

### Technology Stack

- **Runtime**: Node.js with tsx for TypeScript execution
- **Package Manager**: Yarn 4.9.2 with Plug'n'Play
- **Build System**: Simple TypeScript compilation to single file
- **Language**: TypeScript 5.3+
- **MCP SDK**: @modelcontextprotocol/sdk
- **API Client**: @richard-stovall/opnsense-typescript-client
- **Validation**: Zod for schema validation
- **Testing**: Jest with TypeScript support

## API Integration

The server uses the [@richard-stovall/opnsense-typescript-client](https://www.npmjs.com/package/@richard-stovall/opnsense-typescript-client) package which provides:

- Complete type safety for all API calls
- Built-in error handling and retries
- Support for all 601 OPNsense API endpoints
- Modern Fetch API based implementation

### Example Tool Implementation

```typescript
const response = await client.system.getStatus();
return {
  content: [
    {
      type: 'text',
      text: JSON.stringify(response.data, null, 2),
    },
  ],
};
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on the [Model Context Protocol](https://modelcontextprotocol.io/) by Anthropic
- Powered by [@richard-stovall/opnsense-typescript-client](https://www.npmjs.com/package/@richard-stovall/opnsense-typescript-client)
- Inspired by the OPNsense community

---

Made with love for the OPNsense community
