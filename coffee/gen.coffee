C1964jsEmulator::flushDynaCache = ->
  "use strict"
  pc = undefined
  if @writeToDom is false
    for pc of @code
      delete @code[pc]
      #eval('code.'+ pc + '= function (r){alert("yo")}; delete code.' + pc + ';');
      alert "crap"  if @code[pc]
    delete @code

    @code = {}
  else
    while @kk
      @kk -= 1
      @deleteFunction @kk
  return

#must not use strict here.
C1964jsEmulator::deleteFunction = (k) ->

  #log('cleanup');
  fnName = undefined
  splitResult = undefined
  s = document.getElementsByTagName("script")[k]
  splitResult = s.text.split("_")
  splitResult = splitResult[1].split("(")
  fnName = "_" + splitResult[0]
  s.parentNode.removeChild s

  #allow deletion of this function
  eval fnName + "= function (r, s, t, v){}; delete " + fnName + ";"
  window[fnName] = null
  alert "blah"  if window[fnName]
  return