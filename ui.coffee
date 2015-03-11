ui =
  el: {}
  interpreter: null
  init: ()->
    @interpreter = new BrainfuckInterpreter()
    @interpreter.setOutFn @appendOutput.bind(@)
    @buildElement()

  buildElement: ()->
    @el = new DOMBuilder ({
      el:
        editor: 'textarea'
        run: 'button'
        debug:
          view:
            _panel: 'table'
            row1:
              _panel: 'tr'
              cell1:
                _panel: 'td'
                ip: 'span'
                character: 'span'
          optionLabel:
            _panel: 'label'
            option: 'input'
        result: 'div'
    })

    @el.run.innerText = 'Run'
    @el.run.addEventListener 'click', @doRun.bind @

    @el.debug.option.type = 'checkbox'
    @el.debug.option.checked = true
    @el.debug.optionLabel.innerText = 'Debug'

  doRun: () ->
    @el.result.innerText = ''
    @interpreter.writeCode @el.editor.value
    @doStepByStep()
  doStepByStep: () ->
    if @interpreter.step()
      setTimeout (@doStepByStep.bind @), 0
#@el.debug.innerText

  appendOutput: (text) ->
    @el.result.innerText += text

window.addEventListener 'load', ()-> ui.init();