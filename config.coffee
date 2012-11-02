"use strict"

exports.defaults = ->
  lint:
    compiled:
      javascript:true
      css:true
    copied:
      javascript: true
      css: true
    vendor:
      javascript: false
      css: false
    rules:
      javascript: {}
      css: {}

exports.placeholder = ->
  """
  \t

    # lint:                                 # settings for js, css linting/hinting
      # compiled:                           # settings for compiled files
        # javascript:true                   # fire jshint on successful compile of meta-language to javascript
        # css:true                          # fire csslint on successful compile of meta-language to css
      # copied:                             # settings for copied files, files already in .css and .js files
        # javascript: true                  # fire jshint for copied javascript files
        # css: true                         # fire csslint for copied css files
      # vendor:                             # settings for vendor files
        # javascript: false                 # fire jshint for copied vendor javascript files (like jquery)
        # css: false                        # fire csslint for copied vendor css files (like bootstrap)
      # rules:                              # All hints/lints come with defaults built in.  Here is where you'd override those defaults.
                                            # Below is listed an example of an overridden default for each lint type, also listed, next
                                            # to the lint types is the url to find the settings for overriding.
        # javascript:                       # Settings: http://www.jshint.com/options/
          # plusplus: true                  # This is an example override, this is not a default
        # css:                              # Settings: https://github.com/stubbornella/csslint/wiki/Rules
          # floats: false                   # This is an example override, this is not a default
  """

###
TODO: check validity of individual rules?
###

exports.validate = (config) ->
  errors = []
  if config.lint?
    langs = ['javascript', 'css']
    if typeof config.lint is "object" and not Array.isArray(config.lint)
      for type in ['compiled', 'copied', 'vendor']
        typeObj = config.lint[type]
        if typeObj?
          if typeof typeObj is "object" and not Array.isArray(typeObj)
            for lang in langs
              langConf = typeObj[lang]
              if langConf?
                unless typeof langConf is "boolean"
                  errors.push "lint.#{type}.#{lang} must be boolean."
          else
            errors.push "lint.#{type} must be an object."
      if config.lint.rules?
        rs = config.lint.rules
        if typeof rs is "object" and not Array.isArray(rs)
          for lang in langs
            langConf = rs[lang]
            if langConf?
              unless typeof langConf is "object" and not Array.isArray(langConf)
                errors.push "lint.rules.#{lang} must be an object"
        else
         errors.push "lint.rules must be an object."
    else
      errors.push "lint configuration must be an object."

  errors
