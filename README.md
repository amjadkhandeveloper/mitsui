# Mitsui App

Flutter application built with Clean Architecture, BLoC/Cubit state management, and Dio for API calls.

## Architecture

This project follows Clean Architecture principles with three main layers:

- **Domain Layer**: Business logic, entities, and use cases
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: UI, BLoC/Cubit, and widgets

For detailed architecture documentation, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Getting Started

### Prerequisites

- Flutter SDK (>=3.3.3)
- Dart SDK

### Installation

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Update API base URL in `lib/core/constants/api_constants.dart`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core functionality
├── data/           # Data layer
├── domain/         # Domain layer
└── presentation/   # Presentation layer
```

## Features

- ✅ Clean Architecture setup
- ✅ BLoC/Cubit state management
- ✅ Dio HTTP client with interceptors
- ✅ Dependency Injection with GetIt
- ✅ Error handling with Either pattern
- ✅ Network connectivity checking
- ✅ Reusable widgets (Loading, Error)
- ✅ Theme configuration

## Adding a New Feature

1. Create domain entities and use cases
2. Implement data sources and models
3. Create repository implementation
4. Build BLoC/Cubit for state management
5. Create UI screens and widgets
6. Register dependencies in `injection_container.dart`

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed instructions.

## Dependencies

- `flutter_bloc`: State management
- `dio`: HTTP client
- `get_it`: Dependency injection
- `equatable`: Value equality
- `dartz`: Functional programming utilities

## License

This project is for Mitsui customer use.
