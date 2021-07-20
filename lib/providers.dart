import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:towersofhanoi/controllers/disks_brain.dart';
import 'constants_enums.dart';
import 'models/disk.dart';


final errorMessageProvider = StateProvider<String>((_) => "");
final infoMessageProvider = StateProvider<String>((_) => "");
final statusProvider = StateProvider<Status>((_) => Status.starting);
final disksBrainProvider = StateNotifierProvider<DisksBrain, List<Disk>>((_) {
  return DisksBrain();
});

