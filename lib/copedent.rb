#! /usr/bin/env ruby

require_relative "copedent/version"
require_relative "copedent/sheet"
require_relative "copedent/printer"
require_relative "copedent/fret"
require_relative "copedent/change"

require "terminal-table"
require "csv"
require "pry"

# TODO - if the pedal/lever doesn't create a chord tone,
# don't add it to the output
# TODO need to choose a CLI tools library

module Copedent
  class CopedentError < StandardError; end

  ALL_TYPES = [:major, :minor, :dom7] # unused, for reference

  ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]
end
