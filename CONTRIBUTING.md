# Contributing to VSCode Rebel

Thank you for your interest in contributing to VSCode Rebel! This document provides guidelines and information for contributors.

## 🎯 Getting Started

1. **Fork the Repository**
   ```bash
   git clone https://github.com/yourusername/vscode-rebel.git
   cd vscode-rebel
   ```

2. **Set Up Development Environment**
   ```bash
   chmod +x manage_extensions.sh
   ```

3. **Test Your Setup**
   ```bash
   ./manage_extensions.sh --help
   ```

## 📋 How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

**Bug Report Template:**
- **OS/Platform**: (e.g., Ubuntu 20.04, macOS 12.0)
- **VS Code Fork**: (e.g., code-server 4.0.0)
- **Shell**: (e.g., bash 5.0)
- **Error Message**: (full error output)
- **Steps to Reproduce**: (detailed steps)
- **Expected Behavior**: (what should happen)
- **Actual Behavior**: (what actually happens)

### Suggesting Features

Feature requests are welcome! Please:
1. Check existing issues for similar requests
2. Clearly describe the feature and its benefits
3. Provide use cases and examples
4. Consider implementation complexity

### Code Contributions

1. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

3. **Test Thoroughly**
   - Test on multiple platforms if possible
   - Test edge cases and error conditions
   - Ensure backward compatibility

4. **Commit Your Changes**
   ```bash
   git commit -m "feat: add amazing new feature"
   ```

5. **Push and Create Pull Request**
   ```bash
   git push origin feature/your-feature-name
   ```

## 🔧 Development Guidelines

### Code Style

- **Shell Script Standards**: Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- **Functions**: Use descriptive names and add comments
- **Variables**: Use meaningful names and proper quoting
- **Error Handling**: Always check return codes and handle errors gracefully

### Testing

- Test on different platforms (Linux, macOS, WSL)
- Test with different VS Code forks (code-server, Gitpod)
- Test error conditions and network failures
- Test with different shell environments

### Documentation

- Update README.md for new features
- Add inline comments for complex logic
- Update help text for new options
- Include usage examples

## 🐛 Debugging

### Enable Debug Mode

```bash
set -x
./manage_extensions.sh
```

### Common Issues

1. **Permission Errors**
   - Check file permissions: `ls -la`
   - Verify extension directory access

2. **Network Issues**
   - Test API connectivity: `curl -s https://open-vsx.org/api/ms-python/python`
   - Check firewall settings

3. **YAML Parsing**
   - Validate YAML syntax
   - Check `yq` installation

### Logging

Add debug output to functions:

```bash
echo "DEBUG: Processing extension $ext_id" >&2
```

## 📦 Release Process

1. **Version Bump**
   - Update version in README badges
   - Update changelog

2. **Testing**
   - Full regression testing
   - Cross-platform verification

3. **Documentation**
   - Update README.md
   - Update help text
   - Update examples

4. **Release**
   - Create GitHub release
   - Tag version
   - Update package managers

## 🤝 Community

### Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and grow
- Report inappropriate behavior

### Communication

- Use GitHub Issues for bugs and features
- Use GitHub Discussions for questions
- Be clear and concise in communication
- Provide examples when possible

## 📋 Pull Request Checklist

Before submitting a pull request:

- [ ] Code follows project style guidelines
- [ ] Self-review of code changes
- [ ] Comments added for complex logic
- [ ] Documentation updated if needed
- [ ] Tests added/updated as appropriate
- [ ] Manual testing completed
- [ ] No breaking changes (or clearly documented)
- [ ] Commit messages are descriptive

## 🙏 Recognition

Contributors will be:
- Listed in the README.md
- Mentioned in release notes
- Given credit in commit messages

## 📧 Questions?

If you have questions about contributing:
1. Check existing documentation
2. Search closed issues
3. Create a new issue with the "question" label
4. Join our community discussions

Thank you for helping make VSCode Rebel better for everyone! 🚀