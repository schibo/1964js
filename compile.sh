#!/bin/sh

minified="1964js-0.0.14.min.js"

haml index.haml index.html $@

mkdir obj/
mkdir css/

sass sass/style.sass:css/style.css

echo Running CoffeeLint...
coffeelint -f coffeelint.json coffee/*.coffee
if test $? -ne 0
then
    echo Compilation aborted. Please fix CoffeeLint errors first.
else
    echo done.
    echo Compiling coffee files ...
    coffee -c -o obj/ coffee/ 
    if test $? -ne 0
    then
        echo Minification aborted. Please fix CoffeeScript errors first.
    else
        echo done.
        echo minifying io.js as io.min.js ...
        java -jar compiler.jar --js lib/bitjs/io.js --js_output_file lib/bitjs/io.min.js
        echo done.

        echo minifying archive js as archive.min.js ...
        java -jar compiler.jar --js lib/bitjs/archive-modded-to-point-to-minified.js --js_output_file lib/bitjs/archive.min.js
        echo done.

        echo minifying unzip.js as unzip.min.js ...
        java -jar compiler.jar --js lib/bitjs/unzip-modded-to-point-to-minified.js --js_output_file lib/bitjs/unzip.min.js
        echo done.

        echo minifying as $minified ...
        java -jar compiler.jar --version --js obj/constants.js --js lib/BigInt.js --js lib/closure/goog/base.js --js obj/1964.js --js obj/helpers.js --js obj/opcodeMap.js --js obj/boot.js --js lib/closure/goog/math/long.js --js obj/pif.js --js obj/memory.js --js obj/dma.js --js obj/interrupts.js --js lib/glMatrix-0.9.5.min.js --js lib/webgl-utils.js --js obj/renderer.js --js obj/videoHLE.js --js obj/gfxHelpers.js --js obj/webGL.js --js lib/bitjs/io.min.js --js lib/bitjs/archive.min.js --js obj/ui.js --js_output_file lib/$minified
        echo done.
    fi
fi
