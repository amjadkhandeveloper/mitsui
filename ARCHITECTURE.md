# Clean Architecture Setup for Mitsui App

This project follows Clean Architecture principles with BLoC/Cubit for state management and Dio for API calls.

## Project Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── constants/                 # App-wide constants
│   │   └── api_constants.dart    # API endpoints and configuration
│   ├── di/                        # Dependency Injection
│   │   └── injection_container.dart
│   ├── error/                     # Error handling
│   │   ├── exceptions.dart       # Custom exceptions
│   │   └── failures.dart         # Failure classes
│   ├── network/                   # Network layer
│   │   ├── dio_client.dart       # Dio client configuration
│   │   └── network_info.dart     # Network connectivity checker
│   ├── routes/                    # App routing
│   │   └── app_routes.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   ├── usecases/                  # Base use case classes
│   │   └── usecase.dart
│   └── utils/                     # Utility classes
│       ├── input_validator.dart
│       └── result.dart           # Result type definitions
│
├── data/                          # Data Layer
│   ├── datasources/              # Data sources (Remote & Local)
│   │   ├── local_data_source.dart
│   │   └── remote_data_source.dart
│   ├── models/                   # Data models (JSON serializable)
│   └── repositories/             # Repository implementations
│       └── repository_impl.dart
│
├── domain/                        # Domain Layer (Business Logic)
│   ├── entities/                 # Domain entities
│   │   └── entity.dart
│   ├── repositories/             # Repository interfaces
│   │   └── repository.dart
│   └── usecases/                 # Use cases (Business logic)
│
└── presentation/                  # Presentation Layer (UI)
    ├── bloc/                     # BLoC/Cubit state management
    │   ├── base_bloc_event.dart
    │   └── base_bloc_state.dart
    ├── screens/                  # App screens/pages
    │   └── home_screen.dart
    └── widgets/                  # Reusable widgets
        ├── error_widget.dart
        └── loading_widget.dart
```

## Architecture Layers

### 1. Domain Layer (Business Logic)
- **Entities**: Pure Dart classes representing business objects
- **Repositories**: Abstract interfaces defining data operations
- **Use Cases**: Single responsibility business logic operations

### 2. Data Layer (Data Sources)
- **Models**: JSON serializable data models
- **Data Sources**: Remote (API) and Local (Cache/DB) data sources
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer (UI)
- **BLoC/Cubit**: State management using flutter_bloc
- **Screens**: UI pages/screens
- **Widgets**: Reusable UI components

## Dependencies

### State Management
- `flutter_bloc`: BLoC pattern implementation
- `equatable`: Value equality for states and events

### Network
- `dio`: HTTP client for API calls
- `pretty_dio_logger`: Request/response logging

### Dependency Injection
- `get_it`: Service locator for DI

### Utilities
- `dartz`: Functional programming (Either type for error handling)
- `json_annotation`: JSON serialization annotations

## How to Add a New Feature

### Step 1: Create Domain Layer
1. Create entity in `domain/entities/`
2. Create repository interface in `domain/repositories/`
3. Create use case in `domain/usecases/`

### Step 2: Create Data Layer
1. Create model in `data/models/` (extend from entity)
2. Create remote data source method in `data/datasources/remote_data_source.dart`
3. Create local data source method in `data/datasources/local_data_source.dart`
4. Implement repository in `data/repositories/repository_impl.dart`

### Step 3: Create Presentation Layer
1. Create Cubit/Bloc in `presentation/bloc/`
2. Create screen in `presentation/screens/`
3. Register Cubit/Bloc in `core/di/injection_container.dart`

### Example Feature Structure:
```
feature_name/
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       └── get_feature_usecase.dart
├── data/
│   ├── models/
│   │   └── feature_model.dart
│   ├── datasources/
│   │   └── feature_remote_data_source.dart
│   └── repositories/
│       └── feature_repository_impl.dart
└── presentation/
    ├── bloc/
    │   └── feature_cubit.dart
    └── screens/
        └── feature_screen.dart
```

## API Configuration

Update the base URL in `core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

## Error Handling

The app uses a consistent error handling pattern:
- **Exceptions**: Thrown in data layer
- **Failures**: Converted from exceptions in repository layer
- **Result Type**: `Either<Failure, T>` for type-safe error handling

## Running the App

1. Install dependencies:
```bash
flutter pub get
```

2. Run code generation (if using injectable):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
flutter run
```

## Next Steps

1. Update `ApiConstants.baseUrl` with your actual API endpoint
2. Implement your first feature following the architecture
3. Add authentication if needed
4. Configure environment variables for different build flavors

