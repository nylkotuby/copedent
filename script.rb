#! /usr/bin/env ruby

# https://github.com/tj/terminal-table
require "terminal-table"

ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

# high to low, add 1 to index to get to a string #
TUNING = ["F#", "C#", "G#", "D#", "B", "G#", "F#", "D#", "B", "G#", "E", "B"]

# need to choose a CLI tools library
ROOT = "B"
TYPES = [:dom7]

QUALITIES = {
  major: "3",
  minor: "b3",
  # dom7 might not actually work yet but kl + ped needs implementing
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
      [idx + 1, note, relation(key:, note:)]
    end
end

def main
  key = shift_key(to: ROOT)
  wanted_chord_qualities = QUALITIES.slice(*TYPES).values

  (0..3).map do |fret|
    rows = convert(key:, fret:)
    # skip this fret if it doesn't represent a requested chord type
    next unless rows.flatten.intersect?(wanted_chord_qualities)

    puts Terminal::Table.new(
      title: "Fret #{fret}",
      headings: ["Str", "Note", "#"],
      rows:
    )
  end
end

main
