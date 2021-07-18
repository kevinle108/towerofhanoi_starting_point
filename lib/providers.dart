import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants_enums.dart';


final errorMessageProvider = StateProvider<String>((_) => "");
final infoMessageProvider = StateProvider<String>((_) => "");
final statusProvider = StateProvider<Status>((_) => Status.starting);

