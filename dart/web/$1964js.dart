library index;

import 'dart:html';
import 'system.dart';
import 'settings.dart';

System _core;

/**
 * [start] instantiates a new emulator core
 * and reads the file.
 */
void main() {
  //show the user panel
  query("#user_panel")
    ..$dom_className = "show";

  query("#text")
    ..text = "Click me!"
    ..on.click.add(start);
}

/**
 * [start] instantiates a new emulator core
 * and reads the file.
 */
void start(Event event) {
  _core = new System();
  _core.start();
}