#! /usr/bin/env ruby

require_relative "copedent/version"
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

  # === CODE ===

  def self.shift_key(to:)
    ALL_NOTES
      .slice_before(to)
      .to_a # rails .split() would avoid the type fixup
      .reverse
      .flatten
  end

  # returns a fret, which is several columns and rows
  # long-term, might be better to do this less similarly to how it's done irl
  def self.convert_fret(tuning:, key:, fret:)
    shift_tuning(tuning:, key:, fret:)
      .map
      .with_index do |note, idx|
        fret_num = idx.zero? ? fret : ""
        [fret_num, idx + 1, note, relation(key:, note:)]
      end
  end

  # check if the given fret has all of the required chord qualities for configured chords
  # e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
  def self.has_valid_chord?(fret:, types:)
    notes = fret.transpose[3]
    types.any? do |type|
      QUALITIES[type].all? { |qual| notes.include?(qual) }
    end
  end

  def self.print_to_terminal(columns:)
    puts "Printing valid chords to terminal..."

    columns.map do |col|
      puts Terminal::Table.new(
        headings: ["Fr", "Str", "Note", "#"],
        rows: col,
      )
    end
  end

  def self.export_csv(columns:, filename:)
    puts "Exporting valid chords to CSV at #{CSV_FILENAME}..."

    CSV.open(filename, "w") do |csv|
      csv << ["Fret", "Str", "Note", "#"] * columns.length

      columns.transpose.each { |row| csv << row.flatten }
    end
  end

  def self.shift_tuning(tuning:, key:, fret:)
    tuning.map do |note|
      current_index = key.find_index(note)
      new_index = (current_index + fret) % key.length
      key[new_index]
    end
  end

  def self.relation(key:, note:)
    interval = key.find_index(note)
    RELATIONS[interval]
  end
end
