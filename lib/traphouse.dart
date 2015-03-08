library traphouse;

import "package:heck/entities.dart";

import "dart:math";
import "dart:convert";
import "dart:html";

import 'package:pixi_dart/pixi.dart';

part "traphouse/vector.dart";
part "traphouse/bounds.dart";

part "traphouse/controls.dart";

part "traphouse/entity.dart";

part "traphouse/map.dart";

part "traphouse/tile.dart";

num timedSin(num rate) => sin((new DateTime.now().millisecondsSinceEpoch*rate)/200);
num timedCos(num rate) => sin((new DateTime.now().millisecondsSinceEpoch*rate)/200);
Random random = new Random();