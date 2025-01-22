#! /usr/bin/env ruby

require_relative "copedent/version"
require_relative "copedent/sheet"
require_relative "copedent/printer"
require_relative "copedent/fret"
require "terminal-table"
require "csv"

# TODO - look for multiple combinations of the triad for chord quality
#        ie need any?([1,3], [3,5]) for major, not just 3
# TODO NEXT - add pedals and knee levers
# TODO add a hash or first-class object for frets
# TODO need to choose a CLI tools library

module Copedent
  class CopedentError < StandardError; end

  ALL_TYPES = [:major, :minor, :dom7] # unused, for reference

  ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

  # TODO: allow passing in aliases (e.g. :a for :p1)
  # TODO: these should all be passed in?
  PEDAL_NAMES = [:p0, :p1, :p2, :p3, :p4, :p5, :p6, :p7, :p8]
  LEVER_NAMES = [:lkl1, :lkl2, :lkv, :lkr, :rkl, :rkr]
  ALL_MODS = PEDAL_NAMES | LEVER_NAMES
end
