/**
 * 1964 (WebApp version)
 * An N64 emulator Copyright (C) Joel Middendorf
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

library system;

import 'dart:html';
import 'dma.dart';
import 'interrupts.dart';
import 'memory.dart';
import 'pif.dart';
import 'settings.dart';
import 'tlb.dart';
import 'webgl.dart';
import 'vm.dart';
import 'jsvm.dart';
import 'romfile.dart';

class System {
  Int32Array r, h, vAddr, cp0, cp1Con, cp1_i;
  ArrayBuffer _cp1Buffer;
  Float32Array cp1_f;
  Float64Array cp1_f64;
  int LLbit;
  List<TLB> tlb;
  Object _code;

  Memory memory;
  Interrupts interrupts;
  Pif pif;
  DMA dma;
  WebGL webGL;

  // app config
  int _isLittleEndian;
  int _isBigEndian;
  Settings _appSettings;
  VM vm;

  /**
   * Construct the N64 system.
   * System components are allocated here.
   */
  System() :
    r = new Int32Array(35),
    h = new Int32Array(35),
    vAddr = new Int32Array(32),
    cp0 = new Int32Array(32),
    _cp1Buffer = new ArrayBuffer(32*4),
    cp1Con = new Int32Array(32),
    tlb = new List(32),
    _appSettings = new Settings(),
    vm = new JavaScriptVM()
  {
    cp1_i = new Int32Array.fromBuffer(_cp1Buffer);
    cp1_f = new Float32Array.fromBuffer(_cp1Buffer);
    cp1_f64 = new Float64Array.fromBuffer(_cp1Buffer);
    memory = new Memory(this);
    interrupts = new Interrupts(this, cp0);
    pif = new Pif(memory.pifUint8Array);
    dma = new DMA(memory, interrupts, pif);
    webGL = new WebGL(_appSettings.wireframe);
  }

  /**
   * Initialize registers and memory to their initial state
   * simulating the completion of PIF ROM execution. This does
   * not zero-initialize memory. Also, reset app components.
   */
  void softReset() {
    // Initialize the low values of MIPS registers.
    r.setElements([0, 0, 0xd1731be9, 0xd1731be9, 0x001be9,
         0xf45231e5, 0xa4001f0c, 0xa4001f08, 0x070, 0, 0x040, 0xA4000040,
         0xd1330bc3, 0xd1330bc3, 0x025613a26, 0x02ea04317, 0, 0, 0, 0, 0, 0, 0,
         0x06, 0, 0xd73f2993, 0, 0, 0, 0xa4001ff0, 0, 0xa4001554, 0, 0, 0]);

    // Sign-extend the low values in r to store the high values in h.
    int i = 0;
    while (i < 35) {
      h[i] = r[i] >> 31;
      i += 1;
    }

    LLbit = 0;
    _initTLB();

    // Reset app settings
    vm.reset(_appSettings.writeToDom);
  }

  /**
   * Initialize the Translation Lookaside Buffer (TLB).
   * TLB maps virtual memory addresses to physical memory addresses.
   */
  void _initTLB() {
    int i=0;
    for (; i < 32; i++) {
      tlb[i] = new TLB();
    }
  }

  /**
   * Start
   */
  void start() {
    softReset();
    _readFile();
  }

  /**
   * Load and play the rom.
   */
  void _readFile() {
    print('read file');
    String url = "unofficial_roms/rotate.v64";
    HttpRequest request = new HttpRequest();

    /**
     * If the next two lines are reversed, Firefox fails (as of version 16.0.2).
     */
    request.open("GET", url, true);
    request.responseType = "arraybuffer";

    request.on
      ..load.add( (event) {
        if (request.status !== 200) {
          String statusText = request.statusText;
          String errorCode = request.status.toString();
          window.alert('HTTP Error $errorCode: ($statusText)\n\n$url');
          return;
        }

        _endianTest();
        memory.rom = RomFile.byteSwap(new Uint8Array.fromBuffer(request.response));
      })

      ..error.add( (event) {
        print('$event');
      });

    request.send();
  }

  /**
   * Find out if the user's device is little-endian or big-endian
   */
  void _endianTest() {
    ArrayBuffer ii = new ArrayBuffer(2);
    Uint8Array iiSetView = new Uint8Array.fromBuffer(ii);
    Uint16Array iiView = new Uint16Array.fromBuffer(ii);
    iiSetView[0] = 0xff;
    iiSetView[1] = 0x11;
    if (iiView[0] === 0x11FF) {
      print("You are on a little-endian system");
      _isLittleEndian = 1;
      _isBigEndian = 0;
    } else {
      print("You are on a big-endian system");
      _isLittleEndian = 0;
      _isBigEndian = 1;
    }
  }
}
