#!/bin/sh

export version1964="0.3.13"
minified="1964js-$version1964.min.js"

echo Compiling index.html
slimrb index.slim --pretty index.html
if test $? -ne 0
then
    echo Compilation aborted. Please fix slim errors first.
    exit $?
else
    echo done.
fi

echo Compiling debug.html
slimrb index.slim --pretty debug.html
if test $? -ne 0
then
    echo Compilation aborted. Please fix slim errors first.
    exit $?
else
    echo done.
fi

mkdir obj/
mkdir css/

sass sass/style.sass:css/style.css

echo Running CoffeeLint...
coffeelint -f coffeelint.json coffee/*.coffee
if test $? -ne 0
then
    echo Compilation aborted. Please fix CoffeeLint errors first.
    exit $?
else
    echo done.
fi

echo Compiling coffee files ...
coffee -c -o obj/ coffee/ 
if test $? -ne 0
then
    echo Minification aborted. Please fix CoffeeScript errors first.
    exit $?
else
    echo done.
    echo minifying io.js as io.min.js ...
    java -jar closure-compiler-v20180402.jar --compilation_level SIMPLE_OPTIMIZATIONS --language_in=ES6_STRICT --js lib/bitjs/io.js --js_output_file lib/bitjs/io.min.js
    echo done.

    echo minifying archive js as archive.min.js ...
    java -jar closure-compiler-v20180402.jar --compilation_level SIMPLE_OPTIMIZATIONS --language_in=ES6_STRICT --js lib/bitjs/archive-modded-to-point-to-minified.js --js_output_file lib/bitjs/archive.min.js
    echo done.

    echo minifying unzip.js as unzip.min.js ...
    java -jar closure-compiler-v20180402.jar --compilation_level SIMPLE_OPTIMIZATIONS --language_in=ES6_STRICT --js lib/bitjs/unzip-modded-to-point-to-minified.js --js_output_file lib/bitjs/unzip.min.js
    echo done.

    echo minifying as $minified ...
	#java -jar closure-compiler-v20180402.jar --compilation_level SIMPLE_OPTIMIZATIONS --language_in=ES6_STRICT --js obj/constants.js --js lib/BigInt-modded-forES6.js --js lib/closure/goog/base.js --js obj/1964.js --js lib/mainLoop.js --js obj/helpers.js --js obj/opcodeMap.js --js obj/boot.js --js lib/closure/goog/math/long.js --js obj/pif.js --js obj/keyboard.js --js obj/memory.js --js obj/gen.js --js obj/audio.js --js obj/dma.js --js obj/interrupts.js --js lib/glMatrix-0.9.5.min.js --js lib/webgl-utils.js --js obj/renderer.js --js obj/videoHLE.js --js obj/gfxHelpers.js --js obj/webGL.js --js lib/bitjs/io.min.js --js lib/bitjs/archive.min.js --js obj/ui.js --js_output_file lib/$minified

	java -jar closure-compiler-v20180402.jar --compilation_level SIMPLE_OPTIMIZATIONS --language_in=ES6_STRICT --js obj/constants.js --js lib/BigInt-modded-forES6.js --js lib/closure/goog/base.js --js obj/1964.js --js lib/mainLoop.js --js obj/helpers.js --js obj/opcodeMap.js --js obj/boot.js --js lib/closure/goog/math/long.js --js obj/pif.js --js obj/keyboard.js --js obj/memory.js --js obj/gen.js --js obj/audio.js --js obj/dma.js --js obj/interrupts.js --js lib/glMatrix-0.9.5.min.js --js lib/webgl-utils.js --js obj/renderer.js --js obj/videoHLE.js --js obj/gfxHelpers.js --js obj/webGL.js --js lib/bitjs/io.js --js lib/bitjs/archive-modded-to-point-to-minified.js --js obj/ui.js --js_output_file lib/$minified


    echo done.
fi
