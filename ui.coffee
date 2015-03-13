ui =
  el:
    editor: '.editor'
    run: '.run'
    result: '.result'
    debug:
      status: '.debug .status'
      ip: '.debug .ip'
      option: '.debug input[name="isDebug"]'

  interpreter: null

  init: ()->
    @interpreter = new BrainfuckInterpreter()
    @interpreter.outFn = @appendOutput.bind(@)
    @buildElement()

  buildElement: ()->
    @el = DOMGrab.grab(@el)
    @el.run.addEventListener 'click', @doRun.bind(@)


  doRun: () ->
    @el.result.innerText = ''
    @interpreter.reset()

    try
      !@interpreter.writeCode @el.editor.value
    catch ex
      alert("Fail to write code.")
      return false
    finally
      @updateStatus()

    if !@interpreter.launch()
      @updateStatus()
      alert(@interpreter.getException())
      return false

    if @el.debug.option.checked
      @doStepByStep()
    else
      @interpreter.run()
      @updateStatus()

    false
  updateStatus: ()->
    @el.debug.status.innerText = @interpreter.getStatus()
    @el.debug.ip.innerText = @interpreter.getInstructionPointer()

  doStepByStep: () ->
    if @interpreter.step()
      setTimeout (@doStepByStep.bind @), 0
    @updateStatus()

  appendOutput: (itp, data_array) ->
    @el.result.innerText += String.fromCharCode(e) for e in data_array
    true

window.addEventListener 'load', ()-> ui.init();