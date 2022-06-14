import 'package:event/event.dart';

class NewShowAddedEvent extends Event<NewShowAddedEventArgs> {}

class NewShowAddedEventArgs extends EventArgs {
  final int groupId;

  NewShowAddedEventArgs(this.groupId);
}
