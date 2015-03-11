window.BrainfuckInterpreter = class BrainfuckInterpreter
  instance:
    ip: 0
    dp: 0
    code: ''
    memory: []
    loopstack: []
  inFn: prompt
  outFn: console.info
  operator: {}

  operation:
    forward: ()->
      @instance.dp++
    backward: ()->
      @instance.dp--

    increase: ()->
      @instance.memory[@instance.dp] ?= 0
      if @instance.memory[@instance.dp] == 0xff
        @instance.memory[@instance.dp] = 0
      else
        @instance.memory[@instance.dp]++

    decrease: ()->
      @instance.memory[@instance.dp] ?= 0
      if @instance.memory[@instance.dp] == 0
        @instance.memory[@instance.dp] = 0xff
      else
        @instance.memory[@instance.dp]--

    output: () ->
      @outFn String.fromCharCode(@instance.memory[@instance.dp])
    input: () ->
      @instance.memory[@instance.dp] = @inFn().charCodeAt(0)

    enter: () ->
      if @instance.memory[@instance.dp] == 0
        @instance.ip = @findNextLeaveCode()
      else
        @instance.loopstack.push @instance.ip
    leave: () ->
      if @instance.loopstack.length == 0
        throw "Error: The brackets do not match!"
      else
        @instance.ip = @instance.loopstack.pop() - 1 #IP will be increase by 1 by step()

  findNextLeaveCode: ()->
    count = 0
    for index in [@instance.ip + 1 .. @instance.code.length]
      char = @instance.code[index]
      if char == ']'
        if count == 0 then return index else --count
      else if char == '['
        ++count
    throw "Error: The brackets do not match!"

  constructor: () ->
    @operator =
      '>': @operation.forward.bind @
      '<': @operation.backward.bind @
      '+': @operation.increase.bind @
      '-': @operation.decrease.bind @
      '.': @operation.output.bind @
      ',': @operation.input.bind @
      '[': @operation.enter.bind @
      ']': @operation.leave.bind @

  reset: ()->
    @instance =
      ip: 0
      dp: 0
      code: ''
      memory: []
      loopstack: []

  writeCode: (code)->
    @reset()
    @instance.code = code

  setOutFn: (fn)->
    @outFn = fn
  setInFn: (fn) ->
    @inFn = fn

  step: ()->
    op = @instance.code[@instance.ip]
    operator = @operator[op]
    operator() if operator
    ++@instance.ip >= @instance.code.length
