require 'faye'
require './app.rb'

use Faye::RackAdapter, :mount => '/faye', :timeout => 25

run App
