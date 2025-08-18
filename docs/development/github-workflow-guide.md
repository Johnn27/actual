# Actual Budget GitHub Workflow Guide

This guide provides an overview of how the Actual Budget project manages contributions, issues, and pull requests on GitHub.

## Issue Management System

### Issue Types and Labels

Actual Budget uses a comprehensive labeling system to categorize and prioritize issues:

#### Core Issue Types
- **`bug`** - Reported problems or errors in functionality
- **`enhancement`/`feature`** - New feature requests and improvements
- **`feedback`** - User feedback and discussion points
- **`good first issue`** - Beginner-friendly tasks for new contributors
- **`help wanted`** - Issues where maintainer assistance is needed

#### Priority and Status Labels
- **`⚠️ needs info`** - Requires additional information from reporter
- **`needs triage`** - Needs initial review and categorization
- **`needs votes`** - Community input needed for prioritization

#### Component-Specific Labels
- **`user interface`** - Frontend/UI related issues
- **`bank sync`** - Banking integration problems
- **`server`** - Backend/server issues
- **`responsive`** - Mobile/responsive design issues
- **`translations`** - Internationalization/localization
- **`API`** - API-related issues
- **`electron`** - Desktop app specific issues

### Issue Prioritization

The project uses **community voting** through GitHub reactions (👍) to help prioritize feature requests:

1. **High-priority features** - Issues with many upvotes get attention first
2. **Maintainer discretion** - Core team evaluates based on project alignment
3. **Mental health priority** - Maintainer wellbeing is prioritized above all else
4. **No assigned issues** - All issues are open for anyone to work on

### Issue Workflow

1. **Issue Creation** - Users report bugs or request features
2. **Initial Triage** - Maintainers add appropriate labels
3. **Community Input** - Users vote with 👍 reactions
4. **Development** - Contributors pick up unassigned issues
5. **Resolution** - Issues closed via pull requests

## Pull Request Process

### PR Categories and Labels

#### Review Status
- **`:white_check_mark: approved`** - Approved and ready to merge
- **`:mag: ready for review`** - Ready for maintainer review
- **`[WIP]`** - Work in progress (should be in title)
- **`[DO NOT MERGE]`** - Experimental or incomplete

#### PR States
- **`OPEN`** - Active pull request
- **`DRAFT`** - Work in progress, not ready for review

### Contribution Workflow

1. **Issue Discussion** (for large features)
   - Create issue first for significant changes
   - Discuss approach with maintainers
   - Get alignment before implementation

2. **Development**
   - Fork repository
   - Create feature branch
   - Follow existing code conventions
   - Write tests where applicable

3. **Pull Request Creation**
   - Link to related issue
   - Add clear description of changes
   - Include screenshots for UI changes
   - Remove `[WIP]` when ready

4. **Review Process**
   - Automated CodeRabbit reviews for code quality
   - Maintainer review for approval
   - Address feedback and update branch
   - Keep branch updated with master

5. **Release Notes**
   - **Required** for all PRs
   - Use `yarn generate:release-notes` command
   - Create markdown file in `upcoming-release-notes/`
   - Categories: Features, Enhancements, Bugfix, Maintenance
   - Include brief, clear summary

## Code Review System

### Automated Reviews
- **CodeRabbit** provides detailed code analysis
- Checks for code quality, performance, and best practices
- Suggests improvements and catches potential issues

### Human Reviews
- Maintainers provide final approval
- Focus on design, architecture, and project fit
- Multiple reviewers may comment on complex PRs

### Review Criteria
- Code follows project conventions
- Adequate test coverage
- Performance considerations
- Security best practices
- UI/UX consistency

## Development Guidelines

### Design Philosophy
- **Minimalistic UI** - Keep interfaces clean and simple
- **Progressive disclosure** - Don't overwhelm users with options
- **Avoid excessive settings** - Limit configuration complexity
- **Core functionality focus** - Settings screen for essential configs only

### Code Standards
- Follow existing patterns in codebase
- Use TypeScript for type safety
- Write descriptive commit messages
- Maintain backward compatibility

### Testing Requirements
- Add tests for new functionality
- Ensure existing tests pass
- Include integration tests where appropriate
- Test responsive design on mobile

## Repository Structure

### Key Directories
- `packages/` - Monorepo structure with core modules
- `docs/` - Documentation and guides
- `upcoming-release-notes/` - Release note files
- `.github/` - GitHub workflows and templates

### Branch Strategy
- `master` - Main development branch
- Feature branches - Individual features/fixes
- No long-lived development branches

## Community Guidelines

### Maintainer Philosophy
> "The mental health of the maintainers will be prioritized above all else."

### Contribution Expectations
- Be respectful and patient
- Follow issue templates
- Provide detailed reproduction steps for bugs
- Test thoroughly before submitting PRs

### Getting Help
- Check existing issues and documentation first
- Use appropriate issue templates
- Provide complete information for bugs
- Be responsive to maintainer questions

## Quick Reference

### For Bug Reports
1. Search existing issues first
2. Use bug report template
3. Include reproduction steps
4. Provide system information
5. Add relevant labels

### For Feature Requests
1. Check if similar request exists
2. Describe use case clearly
3. Consider impact on existing users
4. Be open to alternative solutions

### For Pull Requests
1. Link to related issue
2. Add release notes
3. Keep commits clean
4. Update documentation if needed
5. Respond to review feedback promptly

---

This workflow emphasizes community collaboration while maintaining project quality and maintainer sustainability. Contributors are encouraged to engage early and often through issues and discussions before implementing significant changes.