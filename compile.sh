#!/bin/sh
rm -rf bin/
mkdir bin/
mkdir bin/js/
mkdir bin/js/lib/
mkdir bin/js/lib/bitjs/

java -jar compiler.jar --js js/lib/BigInt.js --js js/lib/closure/goog/base.js  --js js/lib/Stats.js --js js/polyFills.js --js js/1964.js --js js/helpers.js --js js/opcodeMap.js --js js/boot.js --js js/lib/closure/goog/math/long.js --js js/constants.js --js js/pif.js --js js/memory.js --js js/dma.js --js js/interrupts.js --js js/lib/glMatrix-0.9.5.min.js --js js/lib/webgl-utils.js --js js/gfxHelpers.js --js js/videoHLE.js --js js/webGL.js --js js/tests.js --js js/lib/bitjs/io.js --js js/lib/bitjs/archive.js --js js/ui.js --js_output_file bin/js/1964js-0.0.3.min.js

#move files into place
cp 1964js.html bin/
cp js/lib/bitjs/io.js bin/js/lib/bitjs/
cp js/lib/bitjs/archive.js bin/js/lib/bitjs/
cp js/lib/bitjs/unzip.js bin/js/lib/bitjs/
cp -R unofficial_roms bin/
