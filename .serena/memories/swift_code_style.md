# Swift Code Style and Conventions

## Language Features
- **Swift 5.5+** with async/await for networking
- **SwiftUI** for declarative user interfaces
- **Modern Swift** patterns and best practices

## Naming Conventions
- **Classes/Structs**: PascalCase (e.g., `NetworkManager`, `PCConfig`)
- **Functions/Variables**: camelCase (e.g., `checkStatus`, `baseURL`)
- **Constants**: camelCase or UPPER_CASE for static constants
- **Files**: Match primary type name (e.g., `NetworkManager.swift`)

## Architecture Patterns
- **MVVM-style** with SwiftUI and ObservableObject
- **Clean Architecture** with clear separation of concerns:
  - Views handle UI and user interaction
  - Services handle business logic and networking  
  - Models define data structures
  - Utils provide shared functionality

## Code Organization
- Group related functionality in directories (Views/, Models/, Services/)
- Use extensions to organize code by functionality
- Keep files focused on single responsibility

## SwiftUI Patterns
- Use `@StateObject` for view models
- Use `@State` for local view state
- Use `@Published` properties in ObservableObject classes
- Prefer ViewModifiers for reusable styling

## Networking Patterns
- Use async/await for network operations
- Implement proper error handling with custom error types
- Use URLSession with proper configuration
- HTTPS-only communication with domain validation

## Security Best Practices
- No hardcoded secrets or API keys
- HTTPS-only API communication
- Proper entitlements configuration
- Input validation for user-provided data