"use strict";
var JSLinter, jslint, logger, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

jslint = require('jshint').JSHINT;

_ = require("lodash");

logger = require("logmimosa");

JSLinter = (function() {
  function JSLinter() {
    this._lint = __bind(this._lint, this);
  }

  JSLinter.prototype.defaultOptions = {
    coffee: {
      boss: true,
      eqnull: true,
      shadow: true
    },
    iced: {
      boss: true,
      eqnull: true,
      shadow: true
    }
  };

  JSLinter.prototype.registration = function(config, register) {
    var extensions;

    extensions = null;
    if (config.lint.vendor.javascript) {
      logger.debug("vendor being linted, so everything needs to pass through linting");
      extensions = config.extensions.javascript;
    } else if (config.lint.copied.javascript && config.lint.compiled.javascript) {
      logger.debug("Linting compiled/copied JavaScript only");
      extensions = config.extensions.javascript;
    } else if (config.lint.copied.javascript) {
      logger.debug("Linting copied JavaScript only");
      extensions = ['js'];
    } else if (config.lint.compiled.javascript) {
      logger.debug("Linting compiled JavaScript only");
      extensions = config.extensions.javascript.filter(function(ext) {
        return ext !== 'js';
      });
    } else {
      logger.debug("JavaScript linting is entirely turned off");
      extensions = [];
    }
    if (extensions.length === 0) {
      return;
    }
    this.options = config.lint.rules.rcRules ? _.extend({}, config.lint.rules.rcRules, config.lint.rules.javascript) : config.lint.rules.javascript;
    return register(['buildFile', 'add', 'update'], 'afterCompile', this._lint, __slice.call(extensions));
  };

  JSLinter.prototype._lint = function(config, options, next) {
    var foo, hasFiles, i, rules, _ref,
      _this = this;

    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    foo = {};
    foo['bar'] = 'baz';
    rules = this.defaultOptions[options.extension] ? _.extend({}, this.defaultOptions[options.extension], this.options) : void 0;
    i = 0;
    return options.files.forEach(function(file) {
      var doit, lintok, _ref1;

      if (((_ref1 = file.outputFileText) != null ? _ref1.length : void 0) > 0) {
        doit = true;
        if ((config.lint.exclude != null) && config.lint.exclude.indexOf(file.inputFileName) !== -1) {
          doit = false;
        }
        if ((config.lint.excludeRegex != null) && file.inputFileName.match(config.lint.excludeRegex)) {
          doit = false;
        }
        if (doit) {
          if (options.isCopy && !options.isVendor && !config.lint.copied.javascript) {
            logger.debug("Not linting copied script [[ " + file.inputFileName + " ]]");
          } else if (options.isVendor && !config.lint.vendor.javascript) {
            logger.debug("Not linting vendor script [[ " + file.inputFileName + " ]]");
          } else if (options.isJavascript && !options.isCopy && !config.lint.compiled.javascript) {
            logger.debug("Not linting compiled script [[ " + file.inputFileName + " ]]");
          } else {
            lintok = jslint(file.outputFileText, rules);
            if (!lintok) {
              jslint.errors.forEach(function(e) {
                if (e != null) {
                  return _this.log(file.inputFileName, e.reason, e.line);
                }
              });
            }
          }
        }
      }
      if (++i === options.files.length) {
        return next();
      }
    });
  };

  JSLinter.prototype.log = function(fileName, message, lineNumber) {
    message = "JavaScript Lint Error: " + message + ", in file [[ " + fileName + " ]]";
    if (lineNumber) {
      message += ", at line number [[ " + lineNumber + " ]]";
    }
    return logger.warn(message);
  };

  return JSLinter;

})();

module.exports = new JSLinter();
