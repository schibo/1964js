#!/bin/sh

minified="1964js-0.0.3.min.js"

java -jar compiler.jar --js js/lib/BigInt.js --js js/lib/closure/goog/base.js  --js js/lib/Stats.js --js js/1964.js --js js/helpers.js --js js/opcodeMap.js --js js/boot.js --js js/lib/closure/goog/math/long.js --js js/constants.js --js js/pif.js --js js/memory.js --js js/dma.js --js js/interrupts.js --js js/lib/glMatrix-0.9.5.min.js --js js/lib/webgl-utils.js --js js/renderer.js --js js/videoHLE.js --js js/gfxHelpers.js --js js/webGL.js --js js/lib/bitjs/io.js --js js/lib/bitjs/archive.js --js js/ui.js --js_output_file js/$minified
