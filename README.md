# Docker MCP Server

A Model Context Protocol (MCP) server that provides Docker container execution capabilities for AI assistants and applications. This server enables isolated execution of commands and file operations within a containerized environment.

## 🚀 Features

- **Secure Command Execution**: Run shell commands in isolated Docker containers
- **File Operations**: Read, write, edit, and search files within containers
- **Process Management**: Track long-running processes with unique IDs
- **Interactive Input**: Send input to running processes
- **Smart Timeouts**: Intelligent process timeout handling based on output activity

## 🏗️ Architecture

This MCP server acts as a bridge between MCP clients (like Claude Code) and a Docker container environment:

```
MCP Client (Claude Code) ↔ MCP Server ↔ Docker Container (Debian + Node.js)
                                              ↓
                                        Host ./tmp directory
```

### Core Components

- **MCP Server** (`src/index.ts`) - TypeScript server using `@modelcontextprotocol/sdk`
- **Docker Container** - Debian-based container with Node.js and development tools
- **File Mount** - Host `./tmp` directory mounted to container `/app` for persistence
- **Process Tracking** - Background process management with unique IDs and monitoring

## 📋 Prerequisites

- [Docker](https://www.docker.com/get-started) installed and running
- [Docker Compose](https://docs.docker.com/compose/install/) for easy container management
- [Node.js](https://nodejs.org/) (v18 or higher) for the MCP server
- [npm](https://www.npmjs.com/) for dependency management

## 🚀 Quick Start

### Option 1: Run with npx (Recommended)

```bash
# Run directly with npx (no installation needed)
npx docker-mcp-server

# Run with custom container name
npx docker-mcp-server --container-name my-container

# Show help and available options
npx docker-mcp-server --help
```

**Prerequisites:** Docker must be installed and running with a container available.

### Option 2: Install Globally

```bash
# Install globally
npm install -g docker-mcp-server

# Run from anywhere
docker-mcp-server --container-name my-container
```

### Option 3: Development Setup

#### 1. Clone and Setup

```bash
git clone <your-repository-url>
cd docker-mcp
npm install
```

#### 2. Start the Environment

```bash
# Reset and start Docker environment
./reset-docker.sh
```

This script will:
- Stop any existing containers
- Clean the `/tmp` directory
- Start the container in the background
- Drop you into an interactive shell

#### 3. Build and Run the MCP Server

```bash
# Build TypeScript
npm run build

# Start the MCP server (uses default container name: mcp-container)
npm start

# Start with a custom container name
npm start -- --container-name my-custom-container

# Or build and start in one command
npm run dev

# Build and start with custom container
npm run dev -- --container-name my-custom-container
```

## 🔧 CLI Usage

The MCP server supports the following command-line options:

```bash
# Show help and available options
node dist/index.js --help

# Start with default container name (mcp-container)
node dist/index.js

# Start with custom container name
node dist/index.js --container-name my-dev-container
node dist/index.js -c my-dev-container

# Show version
node dist/index.js --version
```

### Container Name Configuration

You can configure the Docker container name in several ways:

1. **Default**: Uses `mcp-container` if no option is provided
2. **CLI Argument**: `--container-name` or `-c` flag
3. **Multiple Instances**: Run multiple MCP servers with different containers

```bash
# Terminal 1: Development container
npm run dev -- --container-name dev-container

# Terminal 2: Testing container  
npm run dev -- --container-name test-container

# Terminal 3: Production container
npm run dev -- --container-name prod-container
```

## 🛠️ Development Commands

### Container Management
```bash
# Reset Docker environment (stops containers, cleans /tmp, restarts)
./reset-docker.sh

# Start container in background
docker-compose up -d

# Stop and remove containers
docker-compose down

# Interactive shell into container
docker exec -it mcp-container bash
```

### Build and Run
```bash
# Compile TypeScript to JavaScript in /dist
npm run build

# Run the compiled MCP server
npm start

# Build and start in one command
npm run dev
```

## 🔧 Available MCP Tools

The server provides the following tools for MCP clients:

### 🚀 Command Execution

#### `execute_command`
**Execute shell commands inside a Docker container**

Execute any shell command within the container environment with intelligent process tracking and timeout handling.

**Parameters:**
- `command` (string) - The shell command to execute in the container
- `rationale` (string) - Explanation of why this command is being executed
- `maxWaitTime` (number, optional) - Maximum seconds to wait before returning to agent (default: 20)

**Features:**
- Automatic backgrounding for long-running processes
- Smart timeout based on output activity
- Process ID returned for monitoring
- Real-time output capture

#### `check_process`
**Monitor background processes by ID**

Check the status and output of background processes started by `execute_command`.

**Parameters:**
- `processId` (string) - The process ID returned by a long-running command
- `rationale` (string) - Explanation of why you need to check this process

**Returns:**
- Process status (running/completed)
- Current output (stdout/stderr)
- Exit code (if completed)
- Runtime duration

#### `send_input`
**Send input to running background processes**

Send input data to interactive processes that are waiting for user input.

**Parameters:**
- `processId` (string) - The process ID of the running process
- `input` (string) - The input to send to the process
- `rationale` (string) - Explanation of why you need to send input to this process
- `autoNewline` (boolean, optional) - Whether to automatically add a newline (default: true)

### 📁 File Operations

#### `file_read`
**Read files from container filesystem**

Read file contents with support for large files through offset and limit parameters.

**Parameters:**
- `filePath` (string) - The path to the file to read (relative to /app in container)
- `rationale` (string) - Explanation of why you need to read this file
- `offset` (number, optional) - Starting line number (0-based, default: 0)
- `limit` (number, optional) - Maximum number of lines to read (default: 2000)

**Features:**
- Line-numbered output (cat -n format)
- Support for large files with pagination
- Binary file detection and rejection
- Context-safe reading with limits

#### `file_write`
**Create or overwrite files in container**

Write content to files with safety checks and directory creation.

**Parameters:**
- `filePath` (string) - The path to the file to write (relative to /app in container)
- `content` (string) - The content to write to the file
- `rationale` (string) - Explanation of why you need to write this file

**Safety Features:**
- Automatic directory creation
- Content length reporting
- File existence validation
- Safe content transmission

**Important:** You MUST use `file_read` first before writing to understand the current state and context of the file.

#### `file_edit`
**Perform exact string replacements in files**

Edit files using precise string matching and replacement with backup protection.

**Parameters:**
- `filePath` (string) - The path to the file to edit (relative to /app in container)
- `oldString` (string) - The exact text to replace
- `newString` (string) - The replacement text
- `rationale` (string) - Explanation of why you need to edit this file
- `replaceAll` (boolean, optional) - Whether to replace all occurrences (default: false)

**Safety Features:**
- Automatic backup creation before editing
- Exact string matching requirement
- Base64 encoding for safe text transmission
- Backup restoration on failure

**Important:** You MUST use `file_read` first to get the exact text to match and understand the file's current state.

#### `file_ls`
**List directory contents with filtering**

List files and directories with intelligent filtering and output limits.

**Parameters:**
- `path` (string, optional) - The directory path to list (default: current directory)
- `rationale` (string) - Explanation of why you need to list this directory
- `ignore` (array of strings, optional) - List of glob patterns to ignore

**Features:**
- Built-in ignore patterns (node_modules, .git, dist, etc.)
- Detailed file information (permissions, size, timestamps)
- Output limit (100 entries) with overflow notification
- Smart pattern filtering

#### `file_grep`
**Search file contents with regex support**

Search for patterns in files using powerful grep functionality with result limits.

**Parameters:**
- `pattern` (string) - The search pattern (supports regex)
- `rationale` (string) - Explanation of why you need to search for this pattern
- `path` (string, optional) - The directory to search in (default: current directory)
- `include` (string, optional) - File pattern to include (e.g., '*.js', '*.{ts,tsx}')
- `caseInsensitive` (boolean, optional) - Case insensitive search (default: false)
- `maxResults` (number, optional) - Maximum number of results to return (default: 100)

**Features:**
- Recursive directory search
- File type filtering
- Line number display
- Result count limiting with overflow reporting
- Regex pattern support

## 📊 Process Management

Commands run with intelligent timeout handling:

- **Default timeout**: 20 seconds of inactivity before backgrounding
- **Maximum timeout**: 10 minutes absolute limit  
- **Process tracking**: Background processes get unique IDs for monitoring
- **Smart waiting**: Based on output activity rather than fixed intervals

### Example Process Flow

```bash
# Long-running command gets backgrounded automatically
process_id = execute_command("npm install", "Installing dependencies")

# Check status later
check_process(process_id, "Checking installation progress")

# Send input to interactive processes
send_input(process_id, "y\n", "Confirming prompt")
```

## 🔒 Security Considerations

⚠️ **Important Security Notes**:

- This server provides direct Docker container access to MCP clients
- The container has access to the host's `./tmp` directory
- Commands run with container-level permissions
- Network access is enabled via host networking mode

### Recommended Security Practices

1. **Restrict Container Access**: Limit which users can access the MCP server
2. **Monitor File Operations**: Regularly audit the `./tmp` directory contents
3. **Network Isolation**: Consider using custom networks instead of host mode
4. **Resource Limits**: Add CPU and memory constraints to the container
5. **Audit Logs**: Monitor container command execution and file access

## 🚨 Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check Docker is running
docker info

# Reset environment
./reset-docker.sh
```

**Permission errors:**
```bash
# Ensure tmp directory is writable
chmod 755 ./tmp
```

**MCP server connection issues:**
```bash
# Check server is running
npm run build && npm start

# Verify container is accessible
docker exec -it mcp-container echo "Hello"
```

**Container name errors:**
```bash
# Check if your container exists
docker ps -a

# List all containers to find the correct name
docker ps --format "table {{.Names}}\t{{.Status}}"

# Start with correct container name
npm start -- --container-name your-actual-container-name

# The server will validate the container exists on startup
```

**Multiple container setup:**
```bash
# Start additional containers with different names
docker run -d --name dev-container -v ./tmp:/app node:current-bookworm sleep infinity
docker run -d --name test-container -v ./tmp:/app node:current-bookworm sleep infinity

# Run MCP servers for each
npm run dev -- --container-name dev-container    # Terminal 1
npm run dev -- --container-name test-container   # Terminal 2
```

**Process timeouts:**
- Adjust `maxWaitTime` parameter in `execute_command`
- Use `check_process` to monitor long-running operations
- Consider breaking complex operations into smaller steps

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly with the container environment
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Add comprehensive error handling
- Include rationale parameters for all tool operations
- Test with both quick and long-running commands
- Document any new MCP tools or capabilities

## 📦 Publishing to npm

To publish this package to npm for global use:

### Prerequisites
1. Create an npm account at [npmjs.com](https://www.npmjs.com/)
2. Login to npm: `npm login`
3. Update `package.json` with your details:
   - `author`: Your name and email
   - `repository`: Your GitHub repository URL
   - `homepage`: Your project homepage
   - `bugs`: Your issues URL

### Publishing Steps

```bash
# 1. Update version (patch/minor/major)
npm version patch

# 2. Build the project
npm run build

# 3. Test the package locally
npm pack
npm install -g ./docker-mcp-server-1.0.1.tgz

# 4. Test npx functionality
npx docker-mcp-server --help

# 5. Publish to npm
npm publish

# 6. Verify installation works
npx docker-mcp-server@latest --help
```

### Post-Publishing
- Your package will be available at: `https://www.npmjs.com/package/docker-mcp-server`
- Users can run it with: `npx docker-mcp-server`
- Global installation: `npm install -g docker-mcp-server`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

- 🐛 **Bug Reports**: Please open an issue with detailed reproduction steps
- 💡 **Feature Requests**: Open an issue with your use case and proposed solution
- 📖 **Documentation**: Check the `CLAUDE.md` file for AI assistant specific guidance
- 💬 **Questions**: Open a discussion for general questions and help

---

**Built for the Model Context Protocol ecosystem** 🤖