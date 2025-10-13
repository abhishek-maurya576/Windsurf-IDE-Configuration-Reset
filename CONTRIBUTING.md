# Contributing to Windsurf IDE Reset Utility

First off, thank you for considering contributing to this project! 🎉

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs **actual behavior**
- **PowerShell version** (`$PSVersionTable.PSVersion`)
- **Windows version**
- **Error messages** or screenshots if applicable

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description** of the feature
- **Use case** - why would this be useful?
- **Possible implementation** if you have ideas

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the coding standards below
4. **Test thoroughly** on your local machine
5. **Commit** with clear, descriptive messages:
   ```bash
   git commit -m "Add feature: description of what you added"
   ```
6. **Push** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```
7. **Open a Pull Request** with a clear description of changes

## Coding Standards

### PowerShell Style Guide

- Use **4 spaces** for indentation (no tabs)
- Use **PascalCase** for function names
- Use **camelCase** for variable names
- Add **comments** for complex logic
- Include **error handling** with try-catch blocks
- Use **Write-Host** with appropriate colors for user feedback

### Example:

```powershell
# Good
$userName = "John"
function Get-UserData {
    try {
        # Implementation
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Avoid
$username = "John"  # Inconsistent casing
function getuserdata {  # No proper casing
    # No error handling
}
```

## Testing

Before submitting a PR:

1. Test on a **clean Windows installation** if possible
2. Verify the script works with **PowerShell 5.1** and **7.x**
3. Ensure **backup functionality** works correctly
4. Test **error scenarios** (missing files, no permissions, etc.)
5. Verify **no data loss** occurs

## Documentation

- Update **README.md** if you change functionality
- Add **inline comments** for complex code
- Update **CHANGELOG** section in README for version changes

## Code of Conduct

### Our Standards

- Be **respectful** and **inclusive**
- Accept **constructive criticism**
- Focus on what's **best for the community**
- Show **empathy** towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Publishing others' private information
- Other unprofessional conduct

## Questions?

Feel free to reach out:
- Open an **issue** for questions
- Contact on **YouTube**: [@bforbca](https://youtube.com/@bforbca)
- GitHub: [@abhishek-maurya576](https://github.com/abhishek-maurya576)

---

**Thank you for contributing!** 🙏
