require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'rack/flash'

lib = File.expand_path(File.dirname(__FILE__))

require File.join(lib, 'bouncer/models/user')
require File.join(lib, 'bouncer/bouncer')
