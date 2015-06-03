# 1964js
This is the first Nintendo 64 emulator for JavaScript. Visit the <a href="http://1964js.com/blog/index.html">blog</a> on <a href="http://1964js.com">1964js.com</a> to see videos and to download the original Windows version of 1964.

To build 1964js, run ./compile.sh from the root folder. 

Prerequisites:
<ul>
<li>Slim</li>
<li>Sass</li>
<li>CoffeeScript</li>
<li>Java</li>
</ul>

<h1>To setup your Linux environment:</h1>
```
sudo apt-get install ruby
sudo gem install slim
sudo gem install sass
sudo gem install coffeelint
sudo apt-get install nodejs
sudo apt-get install nodejs-legacy
sudo apt-get install npm
sudo npm install -g coffee-script
sudo npm install -g coffeelint
sudo npm install -g java
sudo apt-get install default-jre
```

<h1>To setup your Windows environment (TODO):</h1>
```
install ruby
install slim
install sass
install coffeelint
install coffee-script
install nodejs
install npm
install java (may cause security issues on Windows, be cautious [06-03-2015])
```

The script is known to work on Mac OS X Yosemite and Ubuntu 14.04 64bit. It should work on other platforms that have a Bash shell. We are working on Windows build instructions.

1964js is (kind of) a port of our Nintendo 64 emulator for Windows called 1964. 1964 was written in C and C++ for Windows. You can still grab that <a href="http://1964emu.emulation64.com">here</a>.

This project is still in the early stages. The initial goal of this project was to see how well Google Chrome's V8 JavaScript compiler performs.

Instead of building a traditional dynamic recompiler (JIT compiler) as we did for 1964 on Windows, which translated MIPS directly to x86, 1964js dynamically writes JavaScript to the web page by reversing MIPS code to JavaScript. This JavaScript represents blocks of ROM code. Then, if using Chrome for instance, Google's V8 compiler compiles the JavaScript to native code for us automatically.

For updates, please check <a href="1964js.com">1964js.com</a> and visit the Emutalk forums.

Be sure to check out <a href="http://hulkholden.github.com/n64js/">n64js</a> as well!.

Greets to StrmnNrmn, author of n64js and Daedalus. By pure coincidence, we started JavaScript N64 emulators around the same time!

Super Mario 64 boots. You need to hit enter a couple times after the title screen.
