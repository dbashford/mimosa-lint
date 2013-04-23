"use strict";
var config, csslint, jslint, registration;

jslint = require('./linters/js');

csslint = require('./linters/css');

config = require('./config');

registration = function(conf, register) {
  jslint.registration(conf, register);
  return csslint.registration(conf, register);
};

module.exports = {
  registration: registration,
  defaults: config.defaults,
  placeholder: config.placeholder,
  validate: config.validate
};
