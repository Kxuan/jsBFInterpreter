window.DOMBuilder = class
  config:
    el: {}
    css:
      prefix: ''
      separator: '_'
      suffix: ''
  dom: {}
  createElements: (el, css_prefix = '')->
    panel = document.createElement el['_panel'] ? 'div'
    panel.className = css_prefix;
    for name,element of el
      if name == '_panel'
        continue
      else if typeof element == 'string'
        el[name] = document.createElement element
        el[name].className = css_prefix + @config.css.separator + name + @config.css.suffix
        panel.appendChild el[name]
      else if typeof element == 'object'
        panel.appendChild @createElements(element, css_prefix + @config.css.separator + name)
    return panel
  initConfig: (config, def)->
    for key,value in def
      if typeof value != 'object'
        def[key] = config[key] if config[key]
      else
        config[key] = @initConfig(config[key], def[key])
    return config

  constructor: (config, build = true)->
    @initConfig config, @config

    if build
      for key,value of @config.el
        this[key] = @createElements(@config.el, @config.css.prefix + key)