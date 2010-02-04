require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'rack/flash'
require 'pony'

lib = File.expand_path(File.dirname(__FILE__))

require File.join(lib, 'rack/contrib/cookies')
require File.join(lib, 'doorman/messages')
require File.join(lib, 'doorman/user')
require File.join(lib, 'doorman/core')
require File.join(lib, 'doorman/remember')
require File.join(lib, 'doorman/forgot')
