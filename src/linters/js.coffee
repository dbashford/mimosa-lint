"use strict"

jslint = require('jshint').JSHINT
_ = require "lodash"
logger = require "logmimosa"

class JSLinter

  defaultOptions:
    coffee:
      boss: true
      eqnull: true
      shadow: true
      expr: true
    iced:
      boss: true
      eqnull: true
      shadow: true
      expr: true

  registration: (config, register) ->
    extensions = null
    if config.lint.vendor.javascript
      logger.debug "vendor being linted, so everything needs to pass through linting"
      extensions = config.extensions.javascript
    else if config.lint.copied.javascript and config.lint.compiled.javascript
      logger.debug "Linting compiled/copied JavaScript only"
      extensions = config.extensions.javascript
    else if config.lint.copied.javascript
      logger.debug "Linting copied JavaScript only"
      extensions = ['js']
    else if config.lint.compiled.javascript
      logger.debug "Linting compiled JavaScript only"
      extensions = config.extensions.javascript.filter (ext) -> ext isnt 'js'
    else
      logger.debug "JavaScript linting is entirely turned off"
      extensions = []

    return if extensions.length is 0

    @options = if config.lint.rules.rcRules
      _.extend({}, config.lint.rules.rcRules, config.lint.rules.javascript)
    else
      config.lint.rules.javascript

    register ['buildFile','add','update'], 'afterCompile', @_lint, [extensions...]

  _lint: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles

    rules = if @defaultOptions[options.extension]
      _.extend({}, @defaultOptions[options.extension], @options)

    i = 0
    options.files.forEach (file) =>
      if file.outputFileText?.length > 0
        doit = true
        if config.lint.exclude? and config.lint.exclude.indexOf(file.inputFileName) isnt -1
          doit = false
        if config.lint.excludeRegex? and file.inputFileName.match(config.lint.excludeRegex)
          doit = false

        if doit
          if options.isCopy and not options.isVendor and not config.lint.copied.javascript
            logger.debug "Not linting copied script [[ #{file.inputFileName} ]]"
          else if options.isVendor and not config.lint.vendor.javascript
            logger.debug "Not linting vendor script [[ #{file.inputFileName} ]]"
          else if options.isJavascript and not options.isCopy and not config.lint.compiled.javascript
            logger.debug "Not linting compiled script [[ #{file.inputFileName} ]]"
          else
            lintok = jslint file.outputFileText, rules
            unless lintok
              jslint.errors.forEach (e) =>
                if e?
                  @log file.inputFileName, e.reason, e.line
      next() if ++i is options.files.length

  log: (fileName, message, lineNumber) ->
    message = "JavaScript Lint Error: #{message}, in file [[ #{fileName} ]]"
    message += ", at line number [[ #{lineNumber} ]]" if lineNumber
    logger.warn message

module.exports = new JSLinter()