#! /usr/bin/env ruby

require_relative "copedent/version"
require_relative "copedent/sheet"
require_relative "copedent/printer"
require_relative "copedent/fret"
require_relative "copedent/change"

require "terminal-table"
require "csv"
require "pry"

# TODO - look for multiple combinations of the triad for chord quality
#        ie need any?([1,3], [3,5]) for major, not just 3
# TODO NEXT - add pedals and knee levers
# TODO add a hash or first-class object for frets
# TODO need to choose a CLI tools library

module Copedent
  class CopedentError < StandardError; end

  ALL_TYPES = [:major, :minor, :dom7] # unused, for reference

  ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]
end
