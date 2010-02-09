require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'

require 'warden' unless defined? ::Warden
require 'pony' unless defined? ::Pony

lib = File.expand_path(File.dirname(__FILE__))

require File.join(lib, 'rack/contrib/cookies')
require File.join(lib, 'doorman/messages')
require File.join(lib, 'doorman/user')
require File.join(lib, 'doorman/base')
require File.join(lib, 'doorman/middleware')
