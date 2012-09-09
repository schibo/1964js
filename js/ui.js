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
        vars[hash[0]] = unescape(hash[1]);
    }

    return vars;
}

function initTryCatch(buffer) {
  try {
    i1964js.init(buffer);
  } catch(e) {
    if (i1964js != undefined && i1964js != null) {
      i1964js.terminate = true;
      throw e;
    }
  }
}

function uncompressAndRun(romPath, response) {
    if (romPath.split('.').pop().toLowerCase() !== "zip") {
       var buffer = new Uint8Array(response);
        romLength = buffer.byteLength;
        initTryCatch(buffer);
    } else {
        //This zip library seems to only work if there is one file in the root of the zip's filesystem.
        //Compressing with MacOS causes problems.
        var unzipper = new bitjs.archive.Unzipper(response, 'js/lib/bitjs/');
        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.EXTRACT, function(e) {
            if (e.unarchivedFile) {
                console.log("extracted: " + e.unarchivedFile.filename);
                var buffer = new Uint8Array(e.unarchivedFile.fileData);
                romLength = buffer.byteLength;
                initTryCatch(buffer);
            }   
        });

        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.INFO, function(e) {
            console.log("zip info: " + e.msg);
        });

        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.PROGRESS, function(e) {
            //for (var i in e)
            //    console.log(i +': '+ e[i]);
        });

        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.FINISH, function(e) {
            console.log("finish: " + e.msg);
        });

        unzipper.addEventListener(bitjs.archive.UnarchiveEvent.Type.ERROR, function(e) {
            console.log("ERROR: " + e.msg);
        });

        unzipper.start();
    }
}

function start1964(settings) {

    if (i1964js == null || i1964js == undefined)
        i1964js = new C1964jsEmulator(settings);
        
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

        xhr.onload = function(e) {
            uncompressAndRun(romPath, e.target.response, i1964js);
        };
    }
}

    document.getElementById('user_panel').className = 'show';

  var reader;
  var progress = document.querySelector('.percent');
  var alertMessage = "";
    // Check for the various File API support.

    if (!window.File)
         alertMessage += ' window.File';
    else if (!window.FileReader)
         alertMessage += ' window.FileReader';
    else if (!window.FileList)
         alertMessage += ' window.FileList';
    else if (!window.Blob)
        alertMessge += ' window.Blob';

    if (alertMessage.length > 0)
        log('Unsupported in this browser: ' + alertMessage);

  function abortRead() {
    reader.abort();
  }

  document.getElementById("user_panel").onmousemove = function() {
      document.getElementById("user_panel").className = 'show';
  }

  document.getElementById("user_panel").ontouchend=function(event) { 
    document.getElementById("user_panel").className = 'show';
    event.cancelBubble = true;
    if (event.stopPropagation)
      event.stopPropagation();  
  }

  document.getElementById("user_panel").onmouseup = function(event) {
    //don't fade out if one of the child divs makes caused this event.
    //if ((event.relatedTarget || event.toElement) == this.parentNode)
    event.cancelBubble = true;
    if (event.stopPropagation)
      event.stopPropagation();  
  }

  document.onmouseup = function(event) {
    //don't fade out if one of the child divs makes caused this event.
    //if ((event.relatedTarget || event.toElement) == this.parentNode)
    document.getElementById('user_panel').className='';  
  }

  document.ontouchend=function(event) { 
    document.getElementById('user_panel').className='';  
  }

  function toggleUi() {
    var el = document.getElementById('user_panel');
    
    if (el.className === '') {
      el.className = 'show_fast';
    } else {
      el.className = '';
    }     
  }

  function errorHandler(evt) {
    switch(evt.target.error.code) {
      case evt.target.error.NOT_FOUND_ERR:
        alert('File Not Found!');
        break;
      case evt.target.error.NOT_READABLE_ERR:
        alert('File is not readable');
        break;
      case evt.target.error.ABORT_ERR:
        break; // noop
      default:
        alert('An error occurred reading this file.');
    };
  }

  function updateProgress(evt) {
    // evt is a ProgressEvent.
    if (evt.lengthComputable) {
      var percentLoaded = Math.round((evt.loaded / evt.total) * 100);
      // Increase the progress bar length.
      if (percentLoaded < 100) {
        if (progress != undefined) {
            progress.style.width = percentLoaded + '%';
            progress.textContent = percentLoaded + '%';
        }
      }
    }
  }

  var i1964js; 

function handleFileSelect(evt) {
    var fileName = evt.target.files[0].name;    
    var progressBar = document.getElementById('progress_bar');

    // Reset progress indicator on new file selection.
    if (progress != undefined) {
        progress.style.width = '0%';
        progress.textContent = '0%';
    }

    reader = new FileReader();
    reader.onerror = errorHandler;
    reader.onprogress = updateProgress;
    reader.onabort = function(e) {
      alert('File read cancelled');
    };
    reader.onloadstart = function(e) {
        if (progressBar != undefined)
            document.getElementById('progress_bar').className = 'loading';
    };
    reader.onload = function(e) {
      // Ensure that the progress bar displays 100% at the end.
      if (progress != undefined) {
        progress.style.width = '100%';
        progress.textContent = '100%';
    }

    if (progressBar != undefined)
        setTimeout("document.getElementById('progress_bar').className='';document.getElementById('user_panel').className='';", 1000);
      //todo: add zip support (from index.html)

      uncompressAndRun(fileName, reader.result, i1964js);
    }

    // Read in the file as an array buffer.
    reader.readAsArrayBuffer(evt.target.files[0]);
  }

  document.getElementById('files').addEventListener('change', handleFileSelect, false);
