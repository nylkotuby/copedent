#! /usr/bin/env ruby

# https://github.com/tj/terminal-table
require "terminal-table"
require "csv"

# TODO NEXT - add pedals and knee levers
# TODO add a hash or first-class object for frets
# TODO need to choose a CLI tools library

# === PER-RUN USER CONFIG ===

ROOT = "D"
TYPES = [:major, :minor, :dom7]
ENABLE_CLI = true
ENABLE_CSV = true
CSV_FILENAME = "#{TYPES.map(&:to_s).join("_")}_#{Time.now.to_i}_export.csv"

# high to low, add 1 to index to get to a string #
TUNING = ["E", "C#", "F#", "D", "B", "A", "F#", "E", "D", "C", "A", "D"]

# === STATIC CONFIG ===

ALL_TYPES = [:major, :minor, :dom7] # unused, for reference

ALL_NOTES = ["E", "F", "F#", "G", "G#", "A", "A#", "B", "C", "C#", "D", "D#"]

QUALITIES = {
  major: ["3"],
  minor: ["b3"],
  dom7: ["3", "b7"]
}

# TODO: use the 9+ qualities for QoL
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

# === CODE ===

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

# returns a fret, which is several columns and rows
# long-term, might be better to do this less similarly to how it's done irl
def convert_fret(key:, fret:)
  shift_tuning(key:, fret:)
    .map
    .with_index do |note, idx|
      fret_num = idx.zero? ? fret : ""
      [fret_num, idx + 1, note, relation(key:, note:)]
    end
    # TODO - header could be better suited somewhere else
    .tap { |shifted| shifted.prepend(["Fr", "Str", "Note", "#"]) }
end

# check if the given fret has all of the required chord qualities for configured chords
# e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
def has_valid_chord?(fret:)
  notes = fret.transpose[3]
  TYPES.any? do |type|
    QUALITIES[type].all? { |qual| notes.include?(qual) }
  end
end

def print_to_terminal(columns:)
  "Printing valid chords to terminal..."

  columns.map do |col|
    puts Terminal::Table.new(
      headings: col[0],
      rows: col[1..-1]
    )
  end
end

def export_csv(columns:)
  "Exporting valid chords to CSV at #{CSV_FILENAME}..."
  CSV.open(CSV_FILENAME, "w") do |csv|
    columns.transpose.each { |col| csv << col.flatten }
  end
end

# ======

def main
  key = shift_key(to: ROOT)

  # the copedent is read column-wise, so to make partial calculations,
  # it only makes sense to do so in columnar blocks
  columns = (0..4)
    .map { |fret| convert_fret(key:, fret:) }
    .select { |fret| has_valid_chord?(fret:) }

  print_to_terminal(columns:) if ENABLE_CLI
  export_csv(columns:) if ENABLE_CSV
end

main
