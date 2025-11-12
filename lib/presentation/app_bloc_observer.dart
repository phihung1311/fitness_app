import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/utils/logger.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logDebug('[Bloc Event] ${bloc.runtimeType}: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logDebug('[Bloc Change] ${bloc.runtimeType}: $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    logDebug('[Bloc Error] ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}
