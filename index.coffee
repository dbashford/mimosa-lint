jslint =  require './lib/js'
csslint = require './lib/css'
config = require './config'

registration = (conf, register) ->
  jslint.lifecycleRegistration conf, register
  csslint.lifecycleRegistration conf, register

module.exports =
  registration: registration
  defaults:     config.defaults
  placeholder:  config.placeholder
  validate:     config.validate