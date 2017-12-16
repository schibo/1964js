class C1964jsRsp
  "use strict"

  constructor: ->

#hack global space until we export classes properly
#node.js uses exports; browser uses this (window)
root = exports ? this
root.C1964jsRsp = C1964jsRsp