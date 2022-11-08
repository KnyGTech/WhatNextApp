import 'package:event/event.dart';
import 'package:flutter/rendering.dart';

class ShowsScrollingEvent extends Event<ShowsScrollingEventArgs> {}

class ShowsScrollingEventArgs extends EventArgs {
  final ScrollDirection direction;

  ShowsScrollingEventArgs(this.direction);
}
