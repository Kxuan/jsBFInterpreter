class @DOMGrab

grab = @DOMGrab.grab = (selector)->
  switch typeof selector
    when 'string'
      document.querySelector(selector)
    when 'object'
      if selector instanceof Object
        ret = {}
        for k,v of selector
          if selector.hasOwnProperty(k)
            ret[k] = grab(v)
        ret
      else
        selector
    when 'function'
      grab(selector())
    when 'undefined','boolean','number'
      selector
    else
      throw "selector type (#{selector}) is not support"