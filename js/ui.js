/*
1964js - JavaScript/HTML5 port of 1964 - N64 emulator
Copyright (C) 2012 Joel Middendorf

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

function showValue(newValue)
{
	document.getElementById("range").innerHTML=newValue;
    var c = document.getElementById("DebugCanvas");
    var ctx = c.getContext("2d");
  
    if (ImDat2)  
    repaint(ctx,ImDat2,newValue|0);
}

// Read a page's GET URL variables and return them as an associative array.
function getUrlVars()
{
    var vars = [], hash;
    var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
 
    for(var i = 0; i < hashes.length; i++)
    {
        hash = hashes[i].split('=');
        vars.push(hash[0]);
        vars[hash[0]] = hash[1];
    }

    return vars;
}

    var gg = goog; //Google Closure API

function loadRom(emu)
{
    if (emu == null || emu == undefined)
        emu = new _1964jsEmulator();
        
    vars = getUrlVars();
    var romPath;
    for (var i=0; i<vars.length; i++)
        if (vars[i] === "rom")
            romPath = vars[vars[i]];

    if (romPath != undefined && romPath != null) {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', romPath, true);
        xhr.responseType = 'arraybuffer';
        xhr.send();
    }

    if (xhr != undefined)
    xhr.onload = function(e) {
       
       //This zip library seems to only work if there is one file in the root of the zip's filesystem.
       //Compressing with MacOS causes problems.
        var unzipper = new bitjs.archive.Unzipper(this.response, 'js/lib/bitjs/');
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.EXTRACT, function(e) {
                if (e.unarchivedFile)
                {
                    console.log("extracted: " + e.unarchivedFile.filename);
                    var buffer = new Uint8Array(e.unarchivedFile.fileData);
                    romLength = buffer.byteLength;
                    emu.init(buffer);
                }   
                });
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.INFO, function(e) {
                console.log("zip info: " + e.msg);
                });
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.PROGRESS, function(e) {
              //  for (var i in e)
                //    console.log(i +': '+ e[i]);
                });
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.FINISH, function(e) {
                console.log("finish: " + e.msg);
                });
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.ERROR, function(e) {
                console.log("ERROR: " + e.msg);
                });
        
        unzipper.start();
    };
}