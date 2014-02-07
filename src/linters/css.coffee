"use strict"

csslint = require("csslint").CSSLint
logger = null

class CSSLinter

  rules:{}

  registration: (config, register) ->
    logger = config.log

    extensions = null
    if config.lint.vendor.css
      logger.debug "vendor being linted, so everything needs to pass through linting"
      extensions = config.extensions.css
    else if config.lint.copied.css and config.lint.compiled.css
      logger.debug "Linting compiled and copied CSS"
      extensions = config.extensions.css
    else if config.lint.copied.css
      logger.debug "Linting copied CSS only"
      extensions = ['css']
    else if config.lint.compiled.css
      logger.debug "Linting compiled CSS only"
      extensions = config.extensions.css.filter (ext) -> ext isnt 'css'
    else
      logger.debug "CSS linting is entirely turned off"
      extensions = []

    return if extensions.length is 0

    for rule in csslint.getRules()
      unless config.lint.rules.css[rule.id] is false
        @rules[rule.id] = 1

    # buildExtension for compiled assets, buildFile for copied/vendor
    register ['add','update','buildExtension','buildFile'], 'afterCompile', @_lint, [extensions...]

  _lint: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles

    i = 0
    options.files.forEach (file) =>
      if file.outputFileText?.length > 0
        doit = true
        if config.lint.exclude? and config.lint.exclude.indexOf(file.inputFileName) isnt -1
          doit = false
        if config.lint.excludeRegex? and file.inputFileName.match(config.lint.excludeRegex)
          doit = false

        if doit
          # if is copy, and not a vendor copy, and copy is turned off
          if options.isCopy and not options.isVendor and not config.lint.copied.css
            logger.debug "Not linting copied script [[ #{file.inputFileName} ]]"
          # if is vendor and vendor is not turned off
          else if options.isVendor and not config.lint.vendor.css
            logger.debug "Not linting vendor script [[ #{file.inputFileName} ]]"
          # if is css, but not copied css and compiled css is not turned off
          else if options.isCSS and not options.isCopy and not config.lint.compiled.css
            logger.debug "Not linting compiled script [[ #{file.inputFileName} ]]"
          else
            result = csslint.verify file.outputFileText, @rules
            @_writeMessage(file.inputFileName, message) for message in result.messages
      next() if ++i is options.files.length

  _writeMessage: (fileName, message) ->
    output =  "CSSLint Warning: #{message.message} In [[ #{fileName} ]],"
    output += " on line [[ #{message.line} ]], column #{message.col}," if message.line?
    output += " from CSSLint rule ID '#{message.rule.id}'."
    logger.warn output

module.exports = new CSSLinter()