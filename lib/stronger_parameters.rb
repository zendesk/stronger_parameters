require 'stronger_parameters/version'
require 'action_pack'
require 'strong_parameters' if ActionPack::VERSION::MAJOR == 3
require 'stronger_parameters/parameters'
require 'stronger_parameters/constraints'
