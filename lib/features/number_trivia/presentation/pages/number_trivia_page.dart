import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import '../../../../di/injection_container.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Number Trivia"),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                if (state is OnLoading) {
                  return const LoadingDisplay();
                } else if (state is OnComplete) {
                  return TriviaDisplay(trivia: state.trivia);
                } else if (state is OnError) {
                  return MessageDisplay(message: state.errorMessage);
                }
                return const MessageDisplay(message: "Start Searching!");
              },
            ),
            const SizedBox(height: 20),
            TriviaControl()
          ],
        ),
      ),
    );
  }
}
