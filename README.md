mimosa-lint
===========

## Overview

This is a [Mimosa](http://mimosa.io) module that merges both [CSSLint](http://csslint.net/) and [JSHint](http://www.jshint.com/) to run static analysis on both your CSS and JS within the same configuration.

This module, prior to Mimosa version `1.1.0` was a default Mimosa module and came bundled with it.  As of that version it was replaced with two modules, one each for JSHint and CSSLint.

## Usage

Include `"lint"` in your modules list.  That is all, Mimosa will install it for you the next time you start up a `build` or `watch`.

## Functionality

To 'lint' code is to check it for common mistakes or variances from the idiom. Using the mimosa-lint module, Mimosa will automatically lint all of the CSS and JavaScript it moves from source directories to compiled directories. Any errors or warnings that come out of linting will be printed to the console but will not stop or fail the compilation.

## Default Config

```
lint:
  exclude:[]
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
    jshintrc: ".jshintrc"
    js:
      plusplus: true     # an example, not a default
    css:
      floats: false      # an example, not a default
```

* `exclude`: an array of strings or regexes that match files to not lint. Strings are paths that can be relative to the `watch.compiledDir` or absolute.
* `compiled`: The compiled block controls whether or not linting is enabled for compiled code. So when Mimosa compiles SASS, LESS or Stylus, Mimosa will send the resulting CSS through a linting process. Similarly for the JavaScript transpilers, Mimosa will lint the resulting JavaScript.
*  `copied`: The copied settings determine whether or not to lint copied files, like hand-coded JavaScript.
*  `vendor`: Linting is, by default, disabled for vendor assets, that is, those assets living inside a `vendor.javascripts` directory. Vendor libraries often break from the idiom or use hacks to solve complex browser issues for you. For example, when run through CSSLint, Bootstrap causes 400+ warnings. To enable vendor asset linting, uncomment and enable the setting and switch the flags to `true`.
*  `rules`: The rules block is where linting rules for each of the linting tools are overridden or changed. Example overrides are provided in the default configuration. Those are examples, they are not actually overrides.
* `rules.js`: The list of JSHint rules can be found here: http://www.jshint.com/docs/options/
* `rules.css`: The list of CSSLint rules can be found here: https://github.com/stubbornella/csslint/wiki/Rules

## Default, Implied Rules

For CoffeeScript and IcedCoffeeScript some jshint rules are turned off by default. Those transpilers output JavaScript that violates jshint and there is nothing that can be done other than turn the rules off. So when compiling those files, Mimosa will turn off the listed rules by default.

```
boss: true
eqnull: true
shadow: true
expr: true
```