jslint =  require './lib/js'
csslint = require './lib/css'

class MimosaLinters

  lifecycleRegistration: (config, register) ->
    jslint.lifecycleRegistration config, register
    csslint.lifecycleRegistration config, register

module.exports = new MimosaLinters()