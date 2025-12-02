# GitHub Copilot Instructions for spotify_albumer

## Project Overview

This is a Flutter application that integrates with Spotify API to manage and view album collections. The project follows modern Flutter best practices and clean architecture principles.

## Code Style and Conventions

### General Dart/Flutter Guidelines

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use `dart format` for consistent code formatting
- Enable and respect all lint rules defined in `analysis_options.yaml`
- Prefer `const` constructors whenever possible for better performance
- Use trailing commas for better formatting and diffs

### Naming Conventions

- **Files**: Use snake_case (e.g., `playlist_service.dart`)
- **Classes**: Use PascalCase (e.g., `PlaylistRepository`)
- **Variables/Functions**: Use camelCase (e.g., `getUserPlaylists`)
- **Constants**: Use lowerCamelCase (e.g., `const maxRetries = 3`)
- **Private members**: Prefix with underscore (e.g., `_privateMethod`)

### Architecture Patterns

- Follow **feature-first** folder structure (see `lib/features/`)
- Use **Riverpod** as the primary state management and dependency injection solution
- Organize code following Riverpod best practices:
  - **Providers**: Define providers using code generation (`@riverpod` annotation)
  - **Widgets**: Consume providers using `ConsumerWidget` or `Consumer`
  - **Models**: Use immutable data classes (consider `freezed` for sealed unions)
  - **Repositories**: Expose as providers for dependency injection
  - **Services**: Define as providers for HTTP clients, storage, etc.
- Place providers close to where they're used (feature-first)
- Use `AsyncValue` to handle loading/error/data states consistently
- Prefer `ref.watch` in build methods, `ref.read` in callbacks
- Use `ref.listen` for side effects (navigation, showing dialogs, etc.)
- Keep business logic in providers, not in widgets
- Prefer composition over inheritance

### State Management

- **Primary**: Use **Riverpod** for all state management and dependency injection
- **Code generation**: Prefer `@riverpod` annotations over manual provider definitions
- **AsyncValue**: Always use `AsyncValue<T>` for asynchronous operations
  ```dart
  @riverpod
  Future<User> user(Ref ref, String id) async {
    // Automatically wrapped in AsyncValue
    return repository.fetchUser(id);
  }
  ```
- **State immutability**: Keep all state immutable (use `freezed` or `built_value` for complex models)
- **Error handling**: Handle errors using `AsyncValue.when` or pattern matching
- **Auto-dispose**: Let Riverpod auto-dispose providers when no longer needed
- **Family modifiers**: Use `.family` for parameterized providers
- **Notifiers**: Use `Notifier`/`AsyncNotifier` for complex mutable state
- **Alternative libraries**: Consider using complementary packages when beneficial:
  - `flutter_hooks` with `hooks_riverpod` for local widget state
  - `freezed` for immutable models and sealed unions
  - `state_notifier` for complex state machines (if not using Notifier classes)
- Avoid unnecessary rebuilds by using `select` to watch specific properties

### Async Programming

- Always handle errors in async operations using `AsyncValue` from Riverpod
- Use `async`/`await` for better readability over raw Futures
- **Prefer Riverpod providers** over `FutureBuilder`/`StreamBuilder` for reactive UI
- Use `@riverpod` for async data fetching - it automatically handles caching and updates
- For streams, use `@riverpod` with `Stream<T>` return type
- Avoid blocking the main thread with heavy computations
- Use `ref.invalidate()` to trigger refetch when needed
- Use `ref.refresh()` for pull-to-refresh functionality

### Widget Best Practices

- Extract reusable widgets into separate files under `lib/shared/widgets/`
- Keep widget build methods short and readable
- Use `const` constructors for stateless widgets when possible
- **Prefer `ConsumerWidget`** over `StatefulWidget` for Riverpod integration
- Use `Consumer` for surgical rebuilds when only part of the widget needs to listen
- Use `HookConsumerWidget` when combining hooks with Riverpod
- Avoid using `StatefulWidget` - use Riverpod providers for state instead
- Use meaningful widget names that describe their purpose
- Keep UI logic minimal - delegate to providers

### Error Handling

- Always catch and handle exceptions appropriately
- Provide meaningful error messages to users
- Log errors for debugging purposes
- Use custom exception classes for domain-specific errors
- Handle network failures gracefully with retry mechanisms

### Testing

- Write unit tests for business logic and utilities
- Write widget tests for UI components
- Write integration tests for critical user flows
- Aim for high test coverage on business logic
- Mock external dependencies in tests
- Keep tests simple, readable, and maintainable

### Comments and Documentation

- Write self-documenting code with clear names
- Add doc comments (`///`) for public APIs
- Explain "why" rather than "what" in comments
- Keep comments up-to-date with code changes
- Document complex algorithms or business rules

### Performance

- Use `const` constructors to reduce widget rebuilds
- Avoid unnecessary rebuilds with proper use of keys
- Use `ListView.builder` for long lists
- Cache expensive computations
- Profile the app regularly to identify performance bottlenecks
- Optimize images and assets

### Dependencies

- Keep dependencies up-to-date
- Prefer well-maintained, popular packages
- Avoid adding unnecessary dependencies
- Check package pub.dev scores before adding
- Pin dependency versions for stability
- **Core dependencies for this project**:
  - `flutter_riverpod` / `hooks_riverpod` - State management
  - `riverpod_annotation` / `riverpod_generator` - Code generation
  - `freezed` / `freezed_annotation` - Immutable models
  - `json_serializable` - JSON serialization
  - Consider `dio` for advanced HTTP needs over `http`

## Project-Specific Guidelines

### Spotify API Integration

- Store API credentials securely (never commit secrets)
- Handle authentication tokens properly
- Implement token refresh mechanisms
- Respect API rate limits
- Cache responses when appropriate

### Feature Development

- Create new features under `lib/features/`
- Each feature should be self-contained with its own providers
- Typical feature structure:
  ```
  lib/features/feature_name/
    ├── data/           # Data models, DTOs
    ├── domain/         # Business logic, entities
    ├── presentation/   # Widgets, pages
    └── providers/      # Riverpod providers (or colocated with files)
  ```
- Place providers close to where they're used (colocation is encouraged)
- Share common code via `lib/shared/`
- Share common providers via `lib/shared/providers/`
- Follow existing feature structure as a template
- Each feature can export its public API through a barrel file

### Assets and Resources

- Place images in appropriate folders under `assets/`
- Update `pubspec.yaml` when adding new assets
- Use SVG for icons when possible
- Optimize image sizes for mobile

### Security

- Never commit API keys, secrets, or tokens
- Use `flutter_secure_storage` for sensitive data
- Validate and sanitize user inputs
- Follow OWASP mobile security guidelines

## Code Review Checklist

Before submitting code:

- [ ] Code follows style guide and conventions
- [ ] All lint warnings are resolved
- [ ] Unit tests are written and passing
- [ ] No debug print statements or commented code
- [ ] Error handling is implemented
- [ ] Documentation is updated if needed
- [ ] Performance implications are considered
- [ ] Security best practices are followed

## Useful Commands

```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run code generation (Riverpod, Freezed, etc.)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and auto-generate
dart run build_runner watch --delete-conflicting-outputs

# Run tests
flutter test

# Run with specific flavor
flutter run --flavor dev

# Clean build
flutter clean && flutter pub get
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Architecture Guidelines](https://riverpod.dev/docs/concepts/about_code_generation)
- [Spotify API Documentation](https://developer.spotify.com/documentation/web-api)
- [Flutter Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Freezed Package](https://pub.dev/packages/freezed)

## Notes for Copilot

- Prioritize code readability and maintainability
- **Always suggest Riverpod-based solutions** for state management and DI
- Prefer code generation (`@riverpod`) over manual provider definitions
- Use `AsyncValue` for all async operations - show pattern matching examples
- Suggest idiomatic Dart/Flutter/Riverpod solutions
- Consider mobile-specific constraints (battery, network, memory)
- Generate null-safe code
- Provide examples from official Riverpod documentation when relevant
- Suggest performance optimizations (provider scoping, `select`, etc.)
- When suggesting alternatives to Riverpod, justify why and for what specific use case
- Remind about running `build_runner` when adding/modifying generated code
- Repeat the "review the code and improve it", three times.