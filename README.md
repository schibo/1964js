# 1964js
This is the first N64 emulator for JavaScript. Visit the <a href="http://1964js.com/blog/index.html">blog</a> on <a href="http://1964js.com">1964js.com</a> to see videos and to download the original Windows version of 1964.

To build 1964js, run ./compile.sh from the root folder. 

Prerequisites:
<ul>
<li>Slim</li>
<li>Sass</li>
<li>CoffeeScript</li>
<li>Java</li>
</ul>

The script is known to work on MacOS X Yosemite. It hasn't been tested on other platforms but it shouldn't be difficult to make it work on other platforms.

1964js is (kind of) a port of our N64 emulator for Windows called 1964. 1964 was written in C and C++ for Windows. You can still grab that here.

This project is still in the early stages. The initial goal of this project was to see how well Google Chrome's V8 JavaScript compiler performs.
Instead of building a traditional dynarec (JIT compiler) as we did for 1964 for Windows which translated MIPS directly to x86, 1964js dynamically writes JavaScript to the web page by reversing MIPS code to JavaScript. This JavaScript represents blocks of rom code. Then, if using Chrome for instance, Google's V8 compiler compiles the JavaScript to native code for us automatically.
For updates, please check <a href="1964js.com">1964js.com</a> and visit the Emutalk forums.
Be sure to check out <a href="http://hulkholden.github.com/n64js/">n64js</a> as well!. Greets to StrmnNrmn, author of n64js and Daedalus. By pure coincidence, we started JavaScript N64 emulators around the same time. 

Super Mario 64 works. You need to hit enter a couple times after the title screen.
