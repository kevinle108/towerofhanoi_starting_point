import 'package:flutter/material.dart';
import 'package:towersofhanoi/providers.dart';
import '../widgets/animation_area.dart';
import '../controllers/disks_brain.dart';
import '../constants_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TowerOfHanoi extends StatefulWidget {
  @override
  _TowerOfHanoiState createState() => _TowerOfHanoiState();
}

class _TowerOfHanoiState extends State<TowerOfHanoi>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  late DisksBrain disksBrain;
  int? fromRodIndex;

  void setInfoMsg(String newMsg) {
    context.read(infoMessageProvider).state = newMsg;
  }

  void setErrMsg(String newMsg) {
    context.read(errorMessageProvider).state = newMsg;
  }

  void setStatus(Status newStatus) {
    context.read(statusProvider).state = newStatus;
  }

  Status getStatus() {
    return context.read(statusProvider).state;
  }

  bool canDecrement() {
    return (getStatus() == Status.starting || getStatus() == Status.startingMaximumDisks) && disksBrain.diskCount > 1;
  }

  void decrementDisks() {
    setState(() {
      disksBrain.decrementDisks();
      if (disksBrain.disks.length == kMinimumDisks) {
        setStatus(Status.startingMinimumDisks);
      } else {
        setStatus(Status.starting);
      }
    });
  }

  bool canIncrement() {
    return (getStatus() == Status.starting || getStatus() == Status.startingMinimumDisks) && disksBrain.diskCount < 9;
  }

  void incrementDisks() {
    setState(() {
      disksBrain.incrementDisks();
      if (disksBrain.disks.length == kMaximumDisks) {
        setStatus(Status.startingMaximumDisks);
      } else {
        setStatus(Status.starting);
      }
    });
  }

  bool canPlay() {
    Status status = getStatus();
    return status == Status.starting
        || status == Status.startingMaximumDisks
        || status == Status.startingMinimumDisks;
  }

  void play() {
    setState(() {
      setInfoMsg(kToMoveADisk);
      setStatus(Status.starting);
    });
  }

  bool canSolve() {
    return canPlay();
  }

  Future solve() async {
    setStatus(Status.solving);
    setInfoMsg(kSolving);
    disksBrain.reset();
    await moveDisks(disksBrain.diskCount, 0, 2);
    setStatus(Status.solved);
    setInfoMsg(kSolved);
  }

  bool canReset() {
    return getStatus() == Status.playing || getStatus() == Status.solved;
  }

  void reset() {
    setState(() {
      disksBrain.reset();
      setStatus(Status.starting);
      setErrMsg('');
      setInfoMsg('');
    });
  }

  Future onTap(int rodIndex) async {
    if (getStatus() != Status.playing) return;
    setErrMsg('');
    if (fromRodIndex == null) {
      fromRodIndex = rodIndex;
      setInfoMsg('Moving the disk at rod ${String.fromCharCode(rodIndex + 65)} ...');
    } else {
      setInfoMsg('Moving the disk at rod ${String.fromCharCode(fromRodIndex! + 65)}' +
              ' to rod ${String.fromCharCode(rodIndex + 65)}');
      setStatus(Status.moving);
      await moveDisk(fromRodIndex!, rodIndex);
      fromRodIndex = null;
      if (disksBrain.solved()) {
        setInfoMsg(kGotIt);
        setStatus(Status.solved);
      } else {
        setInfoMsg(kToMoveADisk);
        setStatus(Status.playing);
      }
    }
    setState(() {});
  }

  Future moveDisk(int fromRodIndex, int toRodIndex) async {
    if (disksBrain.moveTopDisk(fromRodIndex, toRodIndex)) {
      controller.reset();
      await controller.forward();
    } else {
      setErrMsg(kInvalidMove);
    }
  }

  Future moveDisks(int numDisks, int fromRodIndex, int toRodIndex) async {
    if (numDisks > 1) {
      await moveDisks(
          numDisks - 1, fromRodIndex, 3 - fromRodIndex - toRodIndex);
      await moveDisk(fromRodIndex, toRodIndex);
      await moveDisks(numDisks - 1, 3 - fromRodIndex - toRodIndex, toRodIndex);
    } else {
      await moveDisk(fromRodIndex, toRodIndex);
    }
  }

  @override
  void initState() {
    super.initState();

    disksBrain = DisksBrain(diskCount: 4);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );
    animation.addListener(() {
      disksBrain.move(animation.value);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tower of Hanoi'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Text(errorMsg, style: TextStyle(fontSize: 16, color: Colors.red)),
          // Text(infoMsg, style: TextStyle(fontSize: 16)),
          Consumer(builder: (context, ref, child) {
            return Text(ref(errorMessageProvider).state, style: TextStyle(fontSize: 16, color: Colors.red));
          }),
          Consumer(builder: (context, ref, child) {
            return Text(ref(infoMessageProvider).state, style: TextStyle(fontSize: 16));
          }),
          AnimationArea(disksBrain: disksBrain, onTap: onTap),
          SizedBox(
              height: 30,
              child: Container(
                color: Colors.black54,
              )),
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                  onPressed: canDecrement() ? () => decrementDisks() : null,
                  child: Icon(Icons.remove)),
              ElevatedButton(
                  onPressed: canIncrement() ? () => incrementDisks() : null,
                  child: Icon(Icons.add)),
              ElevatedButton(
                  onPressed: canPlay() ? () => play() : null,
                  child: Text('Play')),
              ElevatedButton(
                  onPressed: canSolve() ? () => solve() : null,
                  child: Text('Solve')),
              ElevatedButton(
                  onPressed: canReset() ? () => reset() : null,
                  child: Text('Reset')),
            ],
          ),
        ],
      ),
    );
  }
}
