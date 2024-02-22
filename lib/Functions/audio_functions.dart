import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:retaskd/data.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

void endPlayer() {
  player.closeAudioSession();
  shownTop.value = 'none';
  menuController.reverse();
  isPaused.value = false;
  pt.reset();
  pt.stop();
}

void refreshRecordings() {
  recNames.clear();
  if (!kIsWeb) {
    recordings.value = Directory(pf['recDirectory']).listSync();
  }
  for (var i = 0; i < recordings.value.length; i++) {
    recNames.add(path.basename(recordings.value[i].path));
  }
}

Future<void> toggle() async {
  if (rec.isRecording) {
    await rec.stopRecorder();
    rec.closeAudioSession();
    shownTop.value = 'none';
    menuController.reverse();
    dt.reset();
    dt.stop();
  } else {
    await rec.openAudioSession();
    final status = await Permission.microphone.request();
    if (status == PermissionStatus.granted) {
      Map<String, String> codec = {
        'm4a': 'aacMP4',
      };
      await rec.startRecorder(
        codec: Codec.values.asNameMap()[codec[pf['codec']]] ?? Codec.defaultCodec,
        toFile: '${pf['recDirectory']}${DateFormat('dd-MM---kk-mm-ss').format(DateTime.now())}.${pf['codec']}',
      );
      shownTop.value = 'recording';
      dt.start();
    }
  }
  refreshRecordings();
}

void togglePlayer() {
  if (player.isPaused) {
    player.resumePlayer();
    isPaused.value = false;
    pt.start();
  } else {
    player.pausePlayer();
    isPaused.value = true;
    pt.stop();
  }
}

Future<void> playFile(int index) async {
  await player.openAudioSession().then(
    (value) {
      pt.reset();
      pt.start();
      shownTop.value = 'playing';
      value!.startPlayer(
        fromURI: recordings.value[index].path,
        whenFinished: () {
          shownTop.value = 'none';
          menuController.reverse();
          isPaused.value = false;
          pt.reset();
          pt.stop();
        },
      );
    },
  );
}
