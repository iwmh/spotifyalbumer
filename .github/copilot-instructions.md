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

**Important:** Always use `fvm` to run `flutter` and `dart` commands to ensure the correct SDK version is used.

```bash
# Format code
fvm dart format .

# Analyze code
fvm flutter analyze

# Run code generation (Riverpod, Freezed, etc.)
fvm dart run build_runner build --delete-conflicting-outputs

# Watch for changes and auto-generate
fvm dart run build_runner watch --delete-conflicting-outputs

# Run tests
fvm flutter test

# Run with specific flavor
fvm flutter run --flavor dev

# Clean build
fvm flutter clean && fvm flutter pub get
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

- **Always use `fvm` to run `flutter` and `dart` commands** (e.g., `fvm flutter run`, `fvm dart format .`) to ensure the correct SDK version is used.
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
- After code modifications, ensure no Linter warnings, Analyzer issues, or build errors remain across the entire codebase.

## Human-Computer Interaction (HCI) & UX Guidance (IdF Encyclopedia-Inspired)

Use the Interaction Design Foundation (IdF) Encyclopedia of Human-Computer Interaction (2nd ed.) as a **conceptual reference** for HCI principles when designing UI, navigation, interaction patterns, information architecture, and microcopy.

Important constraints:
- Do **not** claim to have read “all entries” of any external site.
- Do **not** bulk-scrape, mirror, or reproduce copyrighted text.
- If a specific entry’s details are needed, ask the user to provide a short excerpt or point to the exact section/topic; then summarize in your own words.
- When online browsing is available, consult only the **minimum** number of relevant pages needed for the task and paraphrase; never copy passages verbatim.

When implementing or reviewing UX in this app, apply this checklist:
- **User goals & tasks**: Identify primary user goals (e.g., browse albums, save favorites, view details) and ensure flows are task-first.
- **Information architecture**: Keep navigation predictable; group features by user intent; use clear labels.
- **Mental models & mapping**: Make controls and outcomes feel obvious; align terminology with Spotify concepts.
- **Feedback & system status**: Always show loading/progress, success confirmations, and actionable errors.
- **Error prevention & recovery**: Validate early, provide safe defaults, allow undo where feasible, and make failure states recoverable.
- **Consistency**: Keep layout, icons, terminology, and interactions consistent across features.
- **Recognition over recall**: Prefer visible choices, sensible defaults, and progressive disclosure.
- **Cognitive load**: Reduce steps and decision points; avoid dense screens; keep copy short.
- **Accessibility & inclusive design**: Support dynamic text, contrast, screen readers/semantics, large tap targets; avoid color-only meaning.
- **Performance & perceived performance**: Use skeletons/placeholders, optimistic UI only when safe, and fast first paint.

Practical deliverables for any UX-affecting change:
- Provide a short rationale using HCI concepts (paraphrased), not quotes.
- Call out tradeoffs and the simplest acceptable implementation.
- If introducing a new flow, propose a minimal usability check (e.g., 3-step scenario test) and add TODOs for future improvements only if requested.

## UX Guidance (About Face / Cooper et al.-Inspired)

Use the ideas from *About Face* (Alan Cooper and co-authors, e.g., Robert Reimann, David Cronin, Christopher Noessel) as a **conceptual reference** for interaction design and goal-directed design.

Important constraints:
- Do **not** claim to have read the entire book.
- Do **not** reproduce book text, tables, or long passages.
- If the user asks for a specific method or definition from the book, ask for a short excerpt or a chapter/section reference; then summarize in your own words.

When designing new UI or flows, apply these goal-directed design checks:
- **Define user goals first**: Start from what the user is trying to accomplish (e.g., “find an album”, “save it”, “revisit later”), not from features.
- **Personas & scenarios (lightweight)**: If requirements are fuzzy, propose 1–2 simple personas and a short scenario to drive decisions; keep it minimal.
- **Strong conceptual model**: Keep objects/actions consistent with user expectations (Spotify concepts, library/collection mental model).
- **Progressive disclosure**: Show common actions up front; hide advanced actions until needed.
- **Modeless interaction (when reasonable)**: Avoid forcing users into modes that change meaning of actions; prefer clear state and reversible actions.
- **Forgiveness**: Prefer undo, confirm destructive actions, and make errors recoverable.
- **Good defaults**: Choose sensible defaults to reduce decision load.
- **Direct manipulation & clear affordances**: Make tappable elements look tappable; keep gestures discoverable.

Practical deliverables for any UX-affecting change:
- State the primary user goal and the “happy path” in 2–3 steps.
- List key edge cases (offline, rate limit, auth expired) and what the UI does.
- Keep UI minimal and consistent with existing app patterns and components.