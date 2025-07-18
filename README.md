# 🚀 VSCode Rebel - Extension Manager for Code-Server & VSCode Forks

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![OpenVSX](https://img.shields.io/badge/Registry-OpenVSX-orange.svg)](https://open-vsx.org/)

> **Breaking Free from Microsoft's Marketplace Restrictions**  
> A declarative extension management solution for code-server, Gitpod, and other VS Code forks that can't access the official Microsoft marketplace.

## 🎯 Why VSCode Rebel?

Microsoft has blocked access to their extension marketplace for VS Code forks like code-server, forcing developers to manually manage extensions or go without their favorite tools. **VSCode Rebel** solves this by:

- 🔄 **Declarative Management**: Define your extensions in YAML, let the script handle the rest
- 🌐 **Open VSX Integration**: Automatically fetches latest versions from the open-source registry
- 🧹 **Clean Environment**: Removes unwanted extensions automatically
- 📦 **URL Installation**: Install extensions directly from Open VSX URLs
- 🚀 **Always Current**: Keeps extensions updated to their latest versions

## 🛠️ Features

- **Zero-maintenance extension management** - Set it and forget it
- **Automatic updates** - Always uses the latest available versions
- **Cleanup automation** - Removes extensions not in your desired list
- **URL-based installation** - Add extensions directly from Open VSX URLs
- **Cross-platform compatibility** - Works on Linux, macOS, and Windows (WSL)
- **Robust error handling** - Gracefully handles network issues and missing extensions
- **API-based version detection** - Reliable version checking using Open VSX REST API

## 📋 Prerequisites

- **Bash shell** (4.0+ recommended)
- **curl** - for downloading extensions and API calls
- **yq** - for YAML parsing (automatically installed if missing)
- **code-server** or compatible VS Code fork
- **jq** (optional) - for better JSON parsing

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/vscode-rebel.git
   cd vscode-rebel
   ```

2. **Make the script executable:**
   ```bash
   chmod +x manage_extensions.sh
   ```

3. **Edit your extensions list:**
   ```bash
   nano extensions.yaml
   ```

4. **Run the manager:**
   ```bash
   ./manage_extensions.sh
   ```

## 📝 Configuration

### Extension List (`extensions.yaml`)

Define your desired extensions using a simple YAML format:

```yaml
extensions:
  - id: Anthropic.claude-code
    version: latest
  - id: ms-python.python
    version: latest
  - id: esbenp.prettier-vscode
    version: latest
  - id: bradlc.vscode-tailwindcss
    version: latest
  # Add more extensions as needed
```

**Pro Tip:** Use `version: latest` for automatic updates, or specify a version like `version: 1.0.0` for pinned versions.

### Script Configuration

Edit the configuration section in `manage_extensions.sh`:

```bash
# --- Configuration ---
CODE_SERVER_PATH="/usr/lib/code-server/lib/vscode/bin/remote-cli/code-server"
EXTENSIONS_DIR="/root/.local/share/code-server/extensions"
TEMP_DIR="/tmp/code-server-ext-updates"
YAML_FILES_PATTERN="*.yaml"
```

## 🎮 Usage

### Basic Usage

```bash
# Process all extensions from YAML files
./manage_extensions.sh

# Show help
./manage_extensions.sh --help
```

### URL Mode

Install extensions directly from Open VSX URLs:

```bash
./manage_extensions.sh "https://open-vsx.org/api/publisher/extension/version/file/publisher.extension-version.vsix"
```

**Example:**
```bash
./manage_extensions.sh "https://open-vsx.org/api/Anthropic/claude-code/1.0.29/file/Anthropic.claude-code-1.0.29.vsix"
```

This will:
1. Extract the extension ID and version from the URL
2. Add it to your `extensions.yaml` file
3. Download and install the extension

### Automation

Set up a cron job to keep extensions updated:

```bash
# Edit crontab
crontab -e

# Add this line to check for updates daily at 2 AM
0 2 * * * /path/to/vscode-rebel/manage_extensions.sh > /tmp/extension-updates.log 2>&1
```

## 🔧 Advanced Usage

### Custom YAML Files

The script processes all `*.yaml` files in the current directory. You can organize extensions by project:

```
project-a-extensions.yaml
project-b-extensions.yaml
shared-extensions.yaml
```

### Environment Variables

Override default paths using environment variables:

```bash
export CODE_SERVER_PATH="/custom/path/to/code-server"
export EXTENSIONS_DIR="/custom/extensions/directory"
./manage_extensions.sh
```

### Debugging

Enable verbose output for troubleshooting:

```bash
set -x
./manage_extensions.sh
```

## 🌟 How It Works

1. **Reads Configuration**: Parses all `*.yaml` files for desired extensions
2. **Scans Installed**: Checks currently installed extensions in your VS Code fork
3. **Fetches Latest Versions**: Uses Open VSX REST API to get current versions
4. **Performs Updates**: Downloads and installs outdated extensions
5. **Cleanup**: Removes extensions not in your desired list
6. **Reports Results**: Shows what was updated, installed, or removed

## 🔍 Troubleshooting

### Common Issues

**Extensions not installing:**
- Check if the extension exists on [Open VSX](https://open-vsx.org/)
- Verify your `CODE_SERVER_PATH` is correct
- Ensure you have write permissions to the extensions directory

**YAML parsing errors:**
- Install `yq`: `apt install yq` or `brew install yq`
- Verify YAML syntax using an online validator

**Network issues:**
- Check internet connectivity
- Verify Open VSX is accessible: `curl -s https://open-vsx.org/api/ms-python/python`

### Getting Help

1. Check the [Issues](https://github.com/yourusername/vscode-rebel/issues) page
2. Enable debug mode: `set -x` before running the script
3. Share logs when reporting issues

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit your changes: `git commit -m 'Add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/yourusername/vscode-rebel.git
cd vscode-rebel
chmod +x manage_extensions.sh

# Test your changes
./manage_extensions.sh --help
```

## 📊 Compatibility

| Platform | Status | Notes |
|----------|--------|-------|
| Linux | ✅ Tested | Primary development platform |
| macOS | ✅ Compatible | Requires Homebrew for dependencies |
| Windows WSL | ✅ Compatible | Use WSL2 for best performance |
| code-server | ✅ Tested | Primary target platform |
| Gitpod | ✅ Compatible | Works with Gitpod workspaces |
| Theia | ⚠️ Experimental | May require path adjustments |

## 📈 Roadmap

- [ ] **GUI Interface** - Web-based management dashboard
- [ ] **Extension Profiles** - Different extension sets for different projects
- [ ] **Backup/Restore** - Export and import extension configurations
- [ ] **Team Sharing** - Share extension configurations across teams
- [ ] **Docker Integration** - Pre-built containers with popular extension sets
- [ ] **Metrics Dashboard** - Track extension usage and updates

## 🙏 Acknowledgments

- [Open VSX Registry](https://open-vsx.org/) - The open-source extension registry
- [code-server](https://github.com/cdr/code-server) - VS Code in the browser
- [Gitpod](https://gitpod.io/) - Cloud development environments
- The VS Code community for creating amazing extensions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- [Open VSX Registry](https://open-vsx.org/)
- [code-server Documentation](https://coder.com/docs/code-server)
- [VS Code Extension API](https://code.visualstudio.com/api)

---

**Made with ❤️ by developers, for developers who refuse to be limited by corporate restrictions.**

> *"If you can't access the marketplace, become the marketplace."*