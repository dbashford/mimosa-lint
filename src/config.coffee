"use strict"

path = require "path"
fs = require "fs"

exports.defaults = ->
  lint:
    exclude: []
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
      jshintrc:".jshintrc"
      javascript: {}
      css: {}

exports.placeholder = ->
  """
  \t

    lint:                      # settings for js, css linting/hinting
      exclude:[]               # array of strings or regexes that match files to not lint,
                               # strings are paths that can be relative to the watch.compiledDir
                               # or absolute
      compiled:                # settings for compiled files
        javascript:true        # fire jshint on successful compile of meta-language to javascript
        css:true               # fire csslint on successful compile of meta-language to css
      copied:                  # settings for copied files, files already in .css and .js files
        javascript: true       # fire jshint for copied javascript files
        css: true              # fire csslint for copied css files
      vendor:                  # settings for vendor files
        javascript: false      # fire jshint for copied vendor javascript files (like jquery)
        css: false             # fire csslint for copied vendor css files (like bootstrap)
      rules:                   # All hints/lints come with defaults built in.  Here is where
                               # you'd override those defaults. Below is listed an example of an
                               # overridden default for each lint type, also listed, next to the
                               # lint types is the url to find the settings for overriding.
        jshintrc: ".jshintrc"  # This is the path, either relative to the root of the project or
                               # absolute, to a .jshintrc file. By default mimosa will look at
                               # the root of the project for this file. The file does not need to
                               # be present. If it is present, it must be valid JSON.
        javascript:            # Settings: http://www.jshint.com/docs/options/, these settings will
                               # override any settings set up in the jshintrc
          # plusplus: true     # This is an example override, this is not a default
        css:                   # Settings: https://github.com/stubbornella/csslint/wiki/Rules
          # floats: false      # This is an example override, this is not a default

  """

exports.validate = (config, validators) ->
  errors = []

  if validators.ifExistsIsObject(errors, "lint config", config.lint)
    langs = ['javascript', 'css']
    for type in ['compiled', 'copied', 'vendor']
      typeObj = config.lint[type]
      if validators.ifExistsIsObject(errors, "lint.#{type}", typeObj)
        for lang in langs
          validators.ifExistsIsBoolean(errors, "lint.#{type}.#{lang}", typeObj[lang])

    if validators.ifExistsIsObject(errors, "lint.rules", config.lint.rules)
      if config.lint.rules.jshintrc?
        hintrcPath = validators.determinePath config.lint.rules.jshintrc, config.root
        try
          _checkHintRcPath(hintrcPath, config)
        catch err
          errors.push "Error reading .jshintrc: #{err}"

      for lang in langs
        langConf = config.lint.rules[lang]
        if langConf?
          unless typeof langConf is "object" and not Array.isArray(langConf)
            errors.push "lint.rules.#{lang} must be an object"

    validators.ifExistsFileExcludeWithRegexAndString(errors, "lint.exclude", config.lint, config.watch.sourceDir)

  errors

_checkHintRcPath = (hintrcPath, config) ->
  if fs.existsSync hintrcPath
    hintText = fs.readFileSync hintrcPath
    try
      config.lint.rules.rcRules = JSON.parse hintText
    catch err
      throw "Cannot parse jshintrc file at [[ #{hintrcPath} ]], #{err}"
  else
    hintrcPath = path.join(path.dirname(hintrcPath), '..', '.jshintrc')
    dirname = path.dirname hintrcPath
    if dirname.indexOf(path.sep) is dirname.lastIndexOf(path.sep)
      config.log.debug "Unable to find mimosa-config"
      return null
    _checkHintRcPath(hintrcPath, config)
