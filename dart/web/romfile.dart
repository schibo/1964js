library file;

import 'dart:html';
import 'stringutils.dart';
import 'memory.dart';

class RomFile {
  RomFile() {}

  /**
   * Rewrite the ROM in big-endian byte order,
   * which is how the rest of our memory is stored.
   */
  static Uint8Array byteSwap(Uint8Array romFile) {
    print("byte swapping...");
    int fmt = Memory.getUint32(romFile, 0);
    switch (fmt) {
      case 0x37804012:
        if ((romFile.byteLength % 2) !== 0) {
          window.alert("help: support odd byte lengths for this swap");
        }
        int temp, k = 0;
        while (k < romFile.byteLength) {
          temp = romFile[k];
          romFile[k] = romFile[k + 1];
          romFile[k + 1] = temp;
          k += 2;
        }
        break;
      case 0x80371240:
        break;
      default:
        print("Unhandled byte order.");
    }

    String res = StringUtils.dec2hex(fmt);
    int len = romFile.byteLength;
    print("swap done: byte order: 0x$res size=$len");
    return romFile;
  }
}
