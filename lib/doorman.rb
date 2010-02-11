lib = File.dirname(__FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'rack/contrib/cookies'
require 'doorman/messages'
require 'doorman/user'
require 'doorman/base'
