"use strict";
var fs, path, _checkHintRcPath;

path = require("path");

fs = require("fs");

exports.defaults = function() {
  return {
    lint: {
      exclude: [],
      compiled: {
        javascript: true,
        css: true
      },
      copied: {
        javascript: true,
        css: true
      },
      vendor: {
        javascript: false,
        css: false
      },
      rules: {
        jshintrc: ".jshintrc",
        javascript: {},
        css: {}
      }
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  lint:                      # settings for js, css linting/hinting\n    exclude:[]               # array of strings or regexes that match files to not lint,\n                             # strings are paths that can be relative to the watch.compiledDir\n                             # or absolute\n    compiled:                # settings for compiled files\n      javascript:true        # fire jshint on successful compile of meta-language to javascript\n      css:true               # fire csslint on successful compile of meta-language to css\n    copied:                  # settings for copied files, files already in .css and .js files\n      javascript: true       # fire jshint for copied javascript files\n      css: true              # fire csslint for copied css files\n    vendor:                  # settings for vendor files\n      javascript: false      # fire jshint for copied vendor javascript files (like jquery)\n      css: false             # fire csslint for copied vendor css files (like bootstrap)\n    rules:                   # All hints/lints come with defaults built in.  Here is where\n                             # you'd override those defaults. Below is listed an example of an\n                             # overridden default for each lint type, also listed, next to the\n                             # lint types is the url to find the settings for overriding.\n      jshintrc: \".jshintrc\"  # This is the path, either relative to the root of the project or\n                             # absolute, to a .jshintrc file. By default mimosa will look at\n                             # the root of the project for this file. The file does not need to\n                             # be present. If it is present, it must be valid JSON.\n      javascript:            # Settings: http://www.jshint.com/docs/options/, these settings will\n                             # override any settings set up in the jshintrc\n        # plusplus: true     # This is an example override, this is not a default\n      css:                   # Settings: https://github.com/stubbornella/csslint/wiki/Rules\n        # floats: false      # This is an example override, this is not a default\n";
};

exports.validate = function(config, validators) {
  var err, errors, hintrcPath, lang, langConf, langs, type, typeObj, _i, _j, _k, _len, _len1, _len2, _ref;
  errors = [];
  if (validators.ifExistsIsObject(errors, "lint config", config.lint)) {
    langs = ['javascript', 'css'];
    _ref = ['compiled', 'copied', 'vendor'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      typeObj = config.lint[type];
      if (validators.ifExistsIsObject(errors, "lint." + type, typeObj)) {
        for (_j = 0, _len1 = langs.length; _j < _len1; _j++) {
          lang = langs[_j];
          validators.ifExistsIsBoolean(errors, "lint." + type + "." + lang, typeObj[lang]);
        }
      }
    }
    if (validators.ifExistsIsObject(errors, "lint.rules", config.lint.rules)) {
      if (config.lint.rules.jshintrc != null) {
        hintrcPath = validators.determinePath(config.lint.rules.jshintrc, config.root);
        try {
          _checkHintRcPath(hintrcPath, config);
        } catch (_error) {
          err = _error;
          errors.push("Error reading .jshintrc: " + err);
        }
      }
      for (_k = 0, _len2 = langs.length; _k < _len2; _k++) {
        lang = langs[_k];
        langConf = config.lint.rules[lang];
        if (langConf != null) {
          if (!(typeof langConf === "object" && !Array.isArray(langConf))) {
            errors.push("lint.rules." + lang + " must be an object");
          }
        }
      }
    }
    validators.ifExistsFileExcludeWithRegexAndString(errors, "lint.exclude", config.lint, config.watch.sourceDir);
  }
  return errors;
};

_checkHintRcPath = function(hintrcPath, config) {
  var dirname, err, hintText;
  if (fs.existsSync(hintrcPath)) {
    hintText = fs.readFileSync(hintrcPath);
    try {
      return config.lint.rules.rcRules = JSON.parse(hintText);
    } catch (_error) {
      err = _error;
      throw "Cannot parse jshintrc file at [[ " + hintrcPath + " ]], " + err;
    }
  } else {
    hintrcPath = path.join(path.dirname(hintrcPath), '..', '.jshintrc');
    dirname = path.dirname(hintrcPath);
    if (dirname.indexOf(path.sep) === dirname.lastIndexOf(path.sep)) {
      config.log.debug("Unable to find mimosa-config");
      return null;
    }
    return _checkHintRcPath(hintrcPath, config);
  }
};
