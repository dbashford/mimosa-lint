"use strict";
var CSSLinter, csslint, logger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

csslint = require("csslint").CSSLint;

logger = null;

CSSLinter = (function() {
  function CSSLinter() {
    this._lint = __bind(this._lint, this);
  }

  CSSLinter.prototype.rules = {};

  CSSLinter.prototype.registration = function(config, register) {
    var extensions, rule, _i, _len, _ref;
    logger = config.log;
    extensions = null;
    if (config.lint.vendor.css) {
      logger.debug("vendor being linted, so everything needs to pass through linting");
      extensions = config.extensions.css;
    } else if (config.lint.copied.css && config.lint.compiled.css) {
      logger.debug("Linting compiled and copied CSS");
      extensions = config.extensions.css;
    } else if (config.lint.copied.css) {
      logger.debug("Linting copied CSS only");
      extensions = ['css'];
    } else if (config.lint.compiled.css) {
      logger.debug("Linting compiled CSS only");
      extensions = config.extensions.css.filter(function(ext) {
        return ext !== 'css';
      });
    } else {
      logger.debug("CSS linting is entirely turned off");
      extensions = [];
    }
    if (extensions.length === 0) {
      return;
    }
    _ref = csslint.getRules();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      rule = _ref[_i];
      if (config.lint.rules.css[rule.id] !== false) {
        this.rules[rule.id] = 1;
      }
    }
    return register(['add', 'update', 'buildExtension', 'buildFile'], 'afterCompile', this._lint, __slice.call(extensions));
  };

  CSSLinter.prototype._lint = function(config, options, next) {
    var hasFiles, i, _ref;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    i = 0;
    return options.files.forEach((function(_this) {
      return function(file) {
        var doit, message, result, _i, _len, _ref1, _ref2;
        if (((_ref1 = file.outputFileText) != null ? _ref1.length : void 0) > 0) {
          doit = true;
          if ((config.lint.exclude != null) && config.lint.exclude.indexOf(file.inputFileName) !== -1) {
            doit = false;
          }
          if ((config.lint.excludeRegex != null) && file.inputFileName.match(config.lint.excludeRegex)) {
            doit = false;
          }
          if (doit) {
            if (options.isCopy && !options.isVendor && !config.lint.copied.css) {
              logger.debug("Not linting copied script [[ " + file.inputFileName + " ]]");
            } else if (options.isVendor && !config.lint.vendor.css) {
              logger.debug("Not linting vendor script [[ " + file.inputFileName + " ]]");
            } else if (options.isCSS && !options.isCopy && !config.lint.compiled.css) {
              logger.debug("Not linting compiled script [[ " + file.inputFileName + " ]]");
            } else {
              result = csslint.verify(file.outputFileText, _this.rules);
              _ref2 = result.messages;
              for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
                message = _ref2[_i];
                _this._writeMessage(file.inputFileName, message);
              }
            }
          }
        }
        if (++i === options.files.length) {
          return next();
        }
      };
    })(this));
  };

  CSSLinter.prototype._writeMessage = function(fileName, message) {
    var output;
    output = "CSSLint Warning: " + message.message + " In [[ " + fileName + " ]],";
    if (message.line != null) {
      output += " on line [[ " + message.line + " ]], column " + message.col + ",";
    }
    output += " from CSSLint rule ID '" + message.rule.id + "'.";
    return logger.warn(output);
  };

  return CSSLinter;

})();

module.exports = new CSSLinter();
