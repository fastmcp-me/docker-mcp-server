# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Build and Run
- `npm run build` - Compile TypeScript to JavaScript in `/dist`
- `npm start` - Run the compiled MCP server (uses default container: mcp-container)
- `npm start -- --container-name <name>` - Run with custom container name
- `npm run dev` - Build and start in one command
- `npm run dev -- --container-name <name>` - Build and start with custom container

### Docker Environment
- `./reset-docker.sh` - Reset Docker environment (stops containers, cleans `/tmp`, restarts)
- `docker-compose up -d` - Start the Docker container in background
- `docker-compose down` - Stop and remove containers
- `docker exec -it mcp-container bash` - Interactive shell into container

## High-Level Architecture

This is an **MCP (Model Context Protocol) Server** that provides Docker container execution capabilities. The server acts as a bridge between MCP clients and a Docker container environment.

### Core Components

1. **MCP Server** (`src/index.ts`) - Main TypeScript server using `@modelcontextprotocol/sdk`
2. **Docker Container** - Debian-based container with Node.js and Playwright pre-installed
3. **File Mount** - Host `./tmp` directory mounted to container `/app` for persistent storage
4. **Process Management** - Tracks background processes with unique IDs and timeouts

### Container Environment
- **Base Image**: `node:current-bookworm` (Debian with current Node.js)
- **Additional Tools**: git, xdg-utils, Playwright with dependencies
- **Working Directory**: `/app` (mounted from host `./tmp`)
- **Container Name**: `mcp-container`

## MCP Tools Available

### Command Execution
- **`execute_command`** - Execute shell commands in Docker container with process tracking
- **`check_process`** - Monitor background processes by ID
- **`send_input`** - Send input to running processes

### File Operations  
- **`file_read`** - Read files from container filesystem with line offset/limit support
- **`file_write`** - Create/overwrite files in container (requires prior read)
- **`file_edit`** - Exact string replacement edits (requires prior read)
- **`file_ls`** - List directory contents with ignore patterns
- **`file_grep`** - Search file contents with regex support

## Process Management System

Commands run with intelligent timeout handling:
- **Default timeout**: 20 seconds of inactivity before backgrounding
- **Maximum timeout**: 10 minutes absolute limit
- **Process tracking**: Background processes get unique IDs for monitoring
- **Smart waiting**: Based on output activity rather than fixed intervals

## Key Implementation Details

### TypeScript Configuration
- Target: ES2022 with ESNext modules
- Output: `./dist` directory
- Source maps and declarations enabled
- Strict type checking

### Docker Setup Process
1. Container builds from `Dockerfile.debian`
2. Mounts host `./tmp` to container `/app` 
3. Container runs `sleep infinity` for persistent availability
4. Commands executed via `docker exec` into persistent container

### File Tool Safety
- All file operations require rationale parameter for traceability
- Write/edit operations require reading file first to understand context
- Base64 encoding used for safe text replacement in edit operations
- Automatic backup creation during edit operations

## Examples Directory Structure

The `/examples` directory contains various AI model implementations of games (primarily Minesweeper), useful for understanding different AI coding approaches and testing the MCP server capabilities.

## Working with this Codebase

1. **Start Development**: Run `./reset-docker.sh` to ensure clean environment
2. **Build Changes**: Use `npm run dev` for quick build and run
3. **Test Tools**: Use any MCP client to test the available tools
4. **File Operations**: Always read files before editing to understand current state
5. **Process Monitoring**: Use process IDs returned by long-running commands to check status

## Container Lifecycle

The Docker container is designed to be persistent and reusable:
- Starts with `sleep infinity` to stay running
- Retains state between command executions  
- Mount point preserves files on host filesystem
- Container can be reset completely with `reset-docker.sh`