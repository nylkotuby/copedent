# models a single fret, which might return several different columns of analysis
# like several pedal and lever combinations that would work at this fret
# long-term, might be better to do this less similarly to how it's done irl
module Copedent
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

  class Fret
    def initialize(tuning:, key:, fret_num:, changelist:)
      @key = key
      @tuning = shift_tuning(tuning:, fret_num:)
      @fret_num = fret_num
      @relations = relations_for(tuning:, fret_num:)
    end

    # check if the given fret has all of the required chord qualities for configured chords
    # e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
    def has_valid_chord?(types:)
      types.any? do |type|
        QUALITIES[type].all? { |qual| @relations.include?(qual) }
      end
    end

    # return array of different valid change combos that work on this fret
    def generate_columns
      [@tuning].map { |mapping| generate_column_for(mapping:) }
    end

    private

    def generate_column_for(mapping:)
      mapping.map.with_index do |note, idx|
        fret = idx.zero? ? @fret_num : ""
        [fret, idx + 1, note, relation(note:)]
      end
    end

    def relations_for(tuning:, fret_num:)
      @tuning.map { |note| relation(note:) }
    end

    def shift_tuning(tuning:, fret_num:)
      tuning.map { |note| shift_note(note:, amount: fret_num) }
    end

    # TODO - changer module for DRY?
    def shift_note(note:, amount:)
      current_index = @key.find_index(note)
      new_index = (current_index + amount) % @key.length
      @key[new_index]
    end

    def relation(note:)
      interval = @key.find_index(note)
      RELATIONS[interval]
    end
  end
end
