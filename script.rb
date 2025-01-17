#! /usr/bin/env ruby

# https://github.com/tj/terminal-table
require "terminal-table"

# TODO NEXT - add pedals and knee levers
# TODO add a hash or first-class object for frets

ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

# high to low, add 1 to index to get to a string #
TUNING = ["E", "C#", "F#", "D", "B", "A", "F#", "E", "D", "C", "A", "D"]

# need to choose a CLI tools library
ROOT = "D"
TYPES = [:major, :minor, :dom7]

ALL_TYPES = [:dom7]
QUALITIES = {
  major: ["3"],
  minor: ["b3"],
  dom7: ["3", "b7"]
}

RELATIONS = [
  "Root",
  "b2",
  "2",
  "b3",
  "3",
  "4",
  "b5",
  "5",
  "#5",
  "6",
  "b7",
  "maj7",
  "Root",
  "b9",
  "9",
  "#9",
  "11",
  "#11",
  "b13",
  "13"
]

def shift_key(to:)
  ALL_NOTES
    .slice_before(to)
    .to_a # rails .split() would avoid the type fixup
    .reverse
    .flatten
end

def shift_tuning(key:, fret:)
  TUNING.map do |note|
    current_index = key.find_index(note)
    new_index = (current_index + fret) % key.length
    key[new_index]
  end
end

def relation(key:, note:)
  interval = key.find_index(note)
  RELATIONS[interval]
end

def convert(key:, fret:)
  shift_tuning(key:, fret:)
    .map
    .with_index do |note, idx|
      fret_num = idx.zero? ? fret : ""
      [fret_num, idx + 1, note, relation(key:, note:)]
    end
    .tap { |shifted| shifted.prepend(["#", "Str", "Note", "Int#"]) }
end

# check if the given fret has all of the required chord qualities for a given chord type
# e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
def has_chord_type?(fret:, type:)
  notes = fret.transpose[3]
  QUALITIES[type].all? { |qual| notes.include?(qual) }
end

def main
  key = shift_key(to: ROOT)

  (0..4)
    .map { |fret| convert(key:, fret:) }
    # only use frets with requested chord types
    .select { |fret| TYPES.any? { |type| has_chord_type?(fret:, type:) } }
    .map do |row|
      puts Terminal::Table.new(
        headings: row[0],
        rows: row[1..-1]
    )
  end
end

main
