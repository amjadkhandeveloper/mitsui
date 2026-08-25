import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Shorthand for repository return types: Left = [Failure], Right = success value.
typedef Result<T> = Either<Failure, T>;
typedef FutureResult<T> = Future<Either<Failure, T>>;
