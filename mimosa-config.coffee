exports.config =
  modules: ["lint"]
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null

  lint:                      # settings for js, css linting/hinting
    # exclude:[]               # array of strings or regexes that match files to not lint,
                               # strings are paths that can be relative to the watch.compiledDir
                               # or absolute
    # compiled:                # settings for compiled files
      # javascript:true        # fire jshint on successful compile of meta-language to javascript
    rules:                   # All hints/lints come with defaults built in.  Here is where
                               # you'd override those defaults. Below is listed an example of an
                               # overridden default for each lint type, also listed, next to the
                               # lint types is the url to find the settings for overriding.
      javascript:            # Settings: http://www.jshint.com/options/, these settings will
                               # override any settings set up in the jshintrc
        node: true       # This is an example override, this is not a default