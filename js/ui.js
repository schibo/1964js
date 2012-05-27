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

function loadRom()
{
    vars = getUrlVars();
    var romPath;
    for (var i=0; i<vars.length; i++)
        if (vars[i] === "rom")
            romPath = vars[vars[i]];

    var xhr = new XMLHttpRequest();
    xhr.open('GET', romPath, true);
    xhr.responseType = 'arraybuffer';
    xhr.send();

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
                    init(buffer);
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
    
  function fatal(message)
  {
        console.log(message);
        console.log(dec2hex(r[0]) + ' ' + dec2hex(r[1]));
        console.log(dec2hex(r[2]) + ' ' + dec2hex(r[3]));
        console.log(dec2hex(r[4]) + ' ' + dec2hex(r[5]));
        console.log(dec2hex(r[6]) + ' ' + dec2hex(r[7]));
        console.log(dec2hex(r[8]) + ' ' + dec2hex(r[9]));
        console.log(dec2hex(r[10]) + ' ' + dec2hex(r[11]));
        console.log(dec2hex(r[12]) + ' ' + dec2hex(r[13]));
        console.log(dec2hex(r[14]) + ' ' + dec2hex(r[15]));
        console.log(dec2hex(r[16]) + ' ' + dec2hex(r[17]));
        console.log(dec2hex(r[18]) + ' ' + dec2hex(r[19]));
        console.log(dec2hex(r[20]) + ' ' + dec2hex(r[21]));
        console.log(dec2hex(r[22]) + ' ' + dec2hex(r[23]));
        console.log(dec2hex(r[24]) + ' ' + dec2hex(r[25]));
        console.log(dec2hex(r[26]) + ' ' + dec2hex(r[27]));
        console.log(dec2hex(r[28]) + ' ' + dec2hex(r[29]));
        console.log(dec2hex(r[30]) + ' ' + dec2hex(r[31]));
  }