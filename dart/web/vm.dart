library vm;

import 'dart:html';

/**
 * Abstract base class for code generation. 1964js is a VM that
 * dynamically generates code for the target platform. Since Dart can
 * target JavaScript or the Dart VM, 1964js will also support these targets.
 */
abstract class VM {
  Object _code;

  VM() {}

  /**
   * Clears all the generated code
   */
  void eraseAllCode();

  /**
   * Write generated code to the root of the DOM or into a new Object.
   * Chrome is currently running faster when generated scripts are written to
   * the root of the DOM.
   */
  void reset(bool writeToDom) {
    if (writeToDom === true) {
      if (_code !== window) {
        eraseAllCode();
        _code = window;
      }
    } else {
      if (_code === window || _code === null) {
        eraseAllCode();
      }
      _code = new Object();
    }
  }
}
