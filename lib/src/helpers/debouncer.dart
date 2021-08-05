///
/// @author https://github.com/Klerith
/// @credits https://stackoverflow.com/a/52922130/7834829
///
import 'dart:async' show Timer;

class Debouncer<T> {
  final Duration duration;
  void Function(T value)? onValue;

  Debouncer({
    required this.duration,
    this.onValue,
  });

  T? _value;
  Timer? _timer;

  T get value => _value!;

  set value(T val) {
    _value = val;
    _timer?.cancel();
    _timer = Timer(duration, () => onValue!(_value!));
  }
}
