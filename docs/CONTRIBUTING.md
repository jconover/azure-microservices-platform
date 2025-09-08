# Contributing Guide

## Code of Conduct

We are committed to providing a friendly, safe, and welcoming environment for all contributors.

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or request features
- Include detailed information and steps to reproduce
- Add appropriate labels

### Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

#### 1. Local Development
```bash
# Clone repository
git clone <repo-url>
cd azure-microservices-platform

# Create branch
git checkout -b feature/your-feature

# Make changes
# Test locally
# Commit changes
git add .
git commit -m "Description of changes"
```

#### 2. Testing
- Run Terraform validate: `terraform validate`
- Run Ansible lint: `ansible-lint`
- Test Kubernetes manifests: `kubectl apply --dry-run=client -f <manifest>`

#### 3. Documentation
- Update README.md if adding new features
- Document any new configurations
- Update architecture diagrams if needed

### Commit Guidelines
- Use clear, descriptive commit messages
- Follow conventional commits format:
  - `feat:` New feature
  - `fix:` Bug fix
  - `docs:` Documentation changes
  - `style:` Code style changes
  - `refactor:` Code refactoring
  - `test:` Test additions or changes
  - `chore:` Maintenance tasks

### Code Standards

#### Terraform
- Use consistent formatting (`terraform fmt`)
- Include descriptions for all variables
- Use modules for reusability
- Tag all resources appropriately

#### Kubernetes
- Use namespaces for isolation
- Include resource limits and requests
- Add health checks
- Use ConfigMaps and Secrets appropriately

#### Ansible
- Use roles for reusability
- Include proper error handling
- Document all variables
- Use vault for sensitive data

## Review Process

1. All PRs require at least one review
2. CI/CD checks must pass
3. Documentation must be updated
4. Changes must be tested in dev environment

## Release Process

1. Create release branch from main
2. Update version numbers
3. Update CHANGELOG.md
4. Create GitHub release
5. Tag release

## Getting Help

- Check existing documentation
- Search closed issues
- Ask in discussions
- Contact maintainers

Thank you for contributing!
