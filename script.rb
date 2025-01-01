#! /usr/bin/env ruby

# https://github.com/tj/terminal-table
require "terminal-table"

ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

# high to low, add 1 to index to get to a string #
TUNING = ["F#", "C#", "G#", "E", "B", "G#", "F#", "E", "B", "G#", "E", "B"]

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

def relation(key:, note:)
  interval = key.find_index(note)
  RELATIONS[interval]
end

def main
  root = "B"
  key = ALL_NOTES
    .slice_before(root)
    .to_a # rails .split() would avoid the type fixup
    .reverse
    .flatten

  converted = TUNING.map.with_index do |note, idx|
    string = idx + 1
    [string, note, relation(key:, note:)]
  end

  puts Terminal::Table.new(rows: converted)
end

main
