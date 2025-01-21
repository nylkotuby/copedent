#! /usr/bin/env ruby

require_relative "copedent/version"
require_relative "copedent/sheet"
require_relative "copedent/printer"
require "terminal-table"
require "csv"

# TODO - look for multiple combinations of the triad for chord quality
#        ie need any?([1,3], [3,5]) for major, not just 3
# TODO NEXT - add pedals and knee levers
# TODO add a hash or first-class object for frets
# TODO need to choose a CLI tools library

# holds everything for now, will break out into more classes soon
module Copedent
  # === STATIC CONFIG ===

  ALL_TYPES = [:major, :minor, :dom7] # unused, for reference

  ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

  # TODO - look for multiple combinations of the triad
  QUALITIES = {
    major: ["3"],
    minor: ["b3"],
    dom7: ["3", "b7"]
  }

  # TODO: use the 9+ qualities for QoL
  RELATIONS = [
    "Root", "b2", "2", "b3", "3",
    "4", "b5", "5", "#5", "6", "b7",
    "maj7", "Root", "b9", "9", "#9",
    "11", "#11", "b13", "13"
  ]
end
