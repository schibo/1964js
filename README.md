# 1964js
This is the first Nintendo 64 emulator for JavaScript. Visit the [blog](http://1964js.com/blog/index.html "1964js blog") on [1964js.com](http://1964js.com "1964js website") to see videos and to download the original Windows version of 1964.

# Building the source

To build 1964js, run ./compile.sh from the root folder on Linux.

Required to build:

* Slim
* Sass
* CoffeeScript
* Java

## To setup your Linux/Mac environment with a Bash shell:
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
Run compile.sh
```

## To setup your Windows environment (TODO):
```
Install MinGW/MSYS/Cygwin/Linux Subsystem For Windows
Install Ruby
Install Slim
Install Sass
Install CoffeeLint
Install CoffeeScript
Install NodeJS
Install NPM
Install Java (causes security issues, be cautious)
Run compile.sh in MinGW/MSYS/Cygwin/Linux Subsystem For Windows
```

The script should work on any platforms that have a Bash shell.

We are working on Windows build instructions.

# About the emulator

1964js is a (kind of) port of our Nintendo 64 emulator for Windows called 1964. 1964 was written in C and C++ for Windows. You can still grab that [here](http://1964emu.emulation64.com "Emulation64 1964 page").

This project is still in the early stages. The initial goal of this project is to see how well modern JavaScript compilers perform.

Instead of building a traditional dynamic recompiler (Just-In-Time/JIT compiler) as we did for 1964 on Windows, which translated MIPS instructions directly to x86 instructions, 1964js dynamically writes JavaScript to the web page by reversing MIPS code to JavaScript. This JavaScript represents blocks of ROM code. Then the web browsers JavaScript compiler compiles the JavaScript to native code for us automatically.

For updates, please check [1964js.com](http://1964js.com "1964js website")!

# Compatibility

Many demos, homebrew, test ROMs, and similar ROMs work fine in 1964js in Chrome.

Super Mario 64 is the only known commercial game to boot. You need to hit enter a couple times after the title screen.

Be sure to check out [n64js](http://hulkholden.github.com/n64js "N64js") as well!

Greets to StrmnNrmn, author of n64js and Daedalus. By pure coincidence, we started JavaScript N64 emulators around the same time!
