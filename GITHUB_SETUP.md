# 🚀 Publishing VSCode Rebel to GitHub

## Quick Setup Guide

Follow these steps to publish your VSCode Rebel repository to GitHub:

### 1. Create GitHub Repository

**Option A: Using GitHub CLI (Recommended)**
```bash
# Install GitHub CLI if not already installed
# Ubuntu/Debian: sudo apt install gh
# macOS: brew install gh
# Windows: winget install GitHub.cli

# Login to GitHub
gh auth login

# Create and push repository
gh repo create vscode-rebel --public --description "🚀 Declarative extension manager for VS Code forks (code-server, Gitpod) that can't access Microsoft's marketplace"

# Set remote and push
git remote add origin https://github.com/yourusername/vscode-rebel.git
git branch -M main
git push -u origin main
```

**Option B: Using GitHub Web Interface**
1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Fill in the details:
   - **Repository name**: `vscode-rebel`
   - **Description**: `🚀 Declarative extension manager for VS Code forks (code-server, Gitpod) that can't access Microsoft's marketplace`
   - **Visibility**: Public
   - **Don't initialize** with README (we already have one)
5. Click "Create repository"

### 2. Connect Local Repository to GitHub

```bash
# Add remote origin (replace yourusername with your GitHub username)
git remote add origin https://github.com/yourusername/vscode-rebel.git

# Verify remote
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

### 3. Configure Repository Settings

**Topics/Tags (for discoverability):**
- `vscode`
- `code-server`
- `gitpod`
- `extension-manager`
- `open-vsx`
- `bash`
- `automation`
- `declarative`
- `marketplace`

**Add these via GitHub web interface:**
1. Go to your repository page
2. Click the gear icon ⚙️ next to "About"
3. Add topics in the "Topics" section
4. Add website: `https://open-vsx.org`

### 4. Enable GitHub Features

**GitHub Pages (Optional - for documentation site):**
1. Go to repository Settings
2. Scroll to "Pages" section
3. Source: "Deploy from a branch"
4. Branch: `main` / `docs` (if you add a docs folder)

**Issues Template:**
```bash
mkdir -p .github/ISSUE_TEMPLATE
```

Create `.github/ISSUE_TEMPLATE/bug_report.md`:
```markdown
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**Environment**
- OS: [e.g., Ubuntu 20.04]
- VS Code Fork: [e.g., code-server 4.0.0]
- Shell: [e.g., bash 5.0]

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Logs**
If applicable, add logs to help explain your problem.

**Additional context**
Add any other context about the problem here.
```

### 5. Add GitHub Actions (Optional)

Create `.github/workflows/test.yml`:
```yaml
name: Test VSCode Rebel

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install dependencies
      run: |
        sudo apt update
        sudo apt install -y curl yq jq
    
    - name: Make script executable
      run: chmod +x manage_extensions.sh
    
    - name: Test help command
      run: ./manage_extensions.sh --help
    
    - name: Validate YAML
      run: yq eval extensions.yaml
    
    - name: Shell check
      run: shellcheck manage_extensions.sh
```

### 6. Create First Release

```bash
# Create a tag for the first release
git tag -a v1.0.0 -m "🚀 Initial release of VSCode Rebel

Features:
- Declarative extension management
- Automatic updates via Open VSX API
- URL-based installation
- Extension cleanup
- Cross-platform support"

# Push the tag
git push origin v1.0.0
```

**Or use GitHub CLI:**
```bash
gh release create v1.0.0 --title "🚀 VSCode Rebel v1.0.0" --notes "Initial release with declarative extension management for VS Code forks"
```

### 7. Repository Structure

Your final repository structure should look like:
```
vscode-rebel/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── bug_report.md
│   └── workflows/
│       └── test.yml
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── extensions.yaml
├── manage_extensions.sh
└── GITHUB_SETUP.md (this file)
```

### 8. Promote Your Repository

**Share on social media:**
- Twitter: "🚀 Just released VSCode Rebel - a declarative extension manager for code-server and other VS Code forks! No more Microsoft marketplace restrictions! #VSCode #CodeServer #OpenSource"
- Reddit: r/vscode, r/selfhosted, r/programming
- Dev.to: Write a blog post about the solution
- Hacker News: Submit your repository

**Add to awesome lists:**
- [Awesome VS Code](https://github.com/viatsko/awesome-vscode)
- [Awesome Code Server](https://github.com/coder/awesome-code-server)
- [Awesome Self Hosted](https://github.com/awesome-selfhosted/awesome-selfhosted)

### 9. Maintenance

**Regular updates:**
- Keep dependencies updated
- Monitor Open VSX API changes
- Update extension list examples
- Respond to issues and PRs promptly

**Community building:**
- Create GitHub Discussions
- Write documentation
- Create video tutorials
- Help users in issues

## 🎉 You're Ready!

Your VSCode Rebel repository is now ready to help developers worldwide break free from Microsoft's marketplace restrictions!

**Next steps:**
1. Share with the community
2. Monitor for issues and feedback
3. Plan new features based on user needs
4. Keep the documentation updated

Happy coding! 🚀