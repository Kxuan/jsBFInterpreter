class BrainfuckInterpreterInstance
  forward = ()->
    @dp++
    true
  backward = ()->
    @dp--
    true

  increase = ()->
    @memory[@dp] ?= 0
    if @memory[@dp] == 0xff
      @memory[@dp] = 0
    else
      @memory[@dp]++
    true

  decrease = ()->
    @memory[@dp] ?= 0
    if @memory[@dp] == 0
      @memory[@dp] = 0xff
    else
      @memory[@dp]--
    true

  output = () ->
    @output_cache.push @memory[@dp]
  input = () ->
    if @input_cache.length == 0
      @status = 'wait_input'
      false
    else
      @memory[@dp] = @input_cache.shift()
      true

  enter = () ->
    if @memory[@dp] == 0
      @ip = @jump_cache[@ip]
    true
  leave = () ->
    if @memory[@dp] != 0
      @ip = @jump_cache[@ip]
    true

  compiler_map =
    '>': -> 0
    '<': -> 1
    '+': -> 2
    '-': -> 3
    '.': -> 4
    ',': -> 5
    '[': ->
      @loop_position_cache.push @code.length
      6
    ']': ->
      if @loop_position_cache.length == 0
        @status = 'exception'
        return false
      else
        pos = @loop_position_cache.pop()
        @jump_cache[pos] = @code.length
        @jump_cache[@code.length] = pos
      7
  operator_map =
    0: forward
    1: backward
    2: increase
    3: decrease
    4: output
    5: input
    6: enter
    7: leave

  #general
  status: 'halt' #halt, running, wait_input, exception
  exception: ''
  code: []
  ip: 0
  memory: []
  dp: 0
  input_cache: []
  output_cache: []

  jump_cache: []
  loop_position_cache: []

  reset: ()->
    @status = 'halt'
    @exception = ''
    @code = []
    @ip = 0;

    @memory = []
    @dp = 0
    @input_cache = []
    @output_cache = []
    @jump_cache = []
    @loop_position_cache = []

  launch: ()->
    return false if @status != 'halt'
    if @loop_position_cache.length != 0
      @status = 'exception'
      return false
    @status = 'running'
    return true

  step: () ->
    return false if @status != 'running'
    if @ip >= @code.length
      @status = 'halt'
      return false

    if operator_map[@code[@ip]].apply(@)
      ++@ip
      return true
    else
      return false

  writeCode: (char)->
    return false if @status != 'halt' || typeof compiler_map[char] != 'function'
    opcode = compiler_map[char].apply(@)
    if opcode == false then return false
    @code.push opcode
    return true
  writeData: (data)->
    switch typeof data
      when 'number'
        @input_cache.push data
      when 'string'
        for index of data
          @input_cache.push data.charCodeAt index
      when 'object'
        if data instanceof Array
          @writeData e for e in data
        else
          return false
      else
        return false
    if @status == 'wait_input'
      @status = 'running'
    true

window.BrainfuckException = class BrainfuckException
  constructor: (@msg)->

window.BrainfuckCompileTimeException = class BrainfuckCompileTimeException extends BrainfuckException
window.BrainfuckRuntimeException = class BrainfuckRuntimeException extends BrainfuckException
window.BrainfuckNoDataException = class BrainfuckNoDataException extends BrainfuckException

window.BrainfuckInterpreter = class BrainfuckInterpreter
  instance = BrainfuckInterpreterInstance.prototype
  inFn: prompt
  outFn: console.info
  getStatus: -> return instance.status
  getException: -> return instance.exception
  getInstructionPointer: -> instance.ip
  getCurrentInstruction: -> instance.code[instance.ip]

  constructor: ()->
    instance = new BrainfuckInterpreterInstance()

  reset: ()-> instance.reset()
  launch: () -> instance.launch()

  #You may need to call reset() before writeCode
  writeCode: (code)->
    for char,index in code
      if !instance.writeCode(char) && 'halt' != instance.status
        throw new BrainfuckCompileTimeException(instance.exception)
    true

  step: ()->
    if ! instance.step()
      switch instance.status
        when 'halt' then return false
        when 'running' then return true
        when 'exception' then throw new BrainfuckRuntimeException(instance.exception)
        when 'wait_input'
          if typeof @inFn == 'function'
            instance.writeData @inFn.call()
          else
            throw new BrainfuckNoDataException(instance.exception)
        else
          throw new BrainfuckRuntimeException('Illegal Status!')
    else
      if instance.output_cache.length
        @outFn @,instance.output_cache
        instance.output_cache = []


    true
  run: ()->
    while (instance.step()) then ``;
    if instance.output_cache.length
      @outFn @,instance.output_cache
      instance.output_cache = []
    true
