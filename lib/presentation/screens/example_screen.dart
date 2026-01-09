import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/example_cubit.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Screen'),
      ),
      body: BlocProvider(
        create: (context) => ExampleCubit()..fetchData(),
        child: BlocBuilder<ExampleCubit, ExampleState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const LoadingWidget(message: 'Loading data...');
            }

            if (state.error != null) {
              return ErrorDisplayWidget(
                message: state.error!,
                onRetry: () => context.read<ExampleCubit>().fetchData(),
              );
            }

            if (state.data != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.data!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<ExampleCubit>().fetchData(),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('No data available'),
            );
          },
        ),
      ),
    );
  }
}
