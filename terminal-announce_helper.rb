require 'terminal-announce'
require_relative 'config'

module Announce
  def self.info(message)
    log :info, message if LogShipper.debug
  end
end
