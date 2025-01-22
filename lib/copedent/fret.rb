# models a single fret, or single complete column of analysis
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
    attr_accessor :data

    def initialize(tuning:, key:, fret_num:)
      @tuning = shift_tuning(tuning:, key:, fret_num:)
      @key = key
      @fret_num = fret_num
      @relations = relations_for(tuning:, key:, fret_num:)
    end

    # check if the given fret has all of the required chord qualities for configured chords
    # e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
    def has_valid_chord?(types:)
      types.any? do |type|
        QUALITIES[type].all? { |qual| @relations.include?(qual) }
      end
    end

    def apply_changes(changes)
      raise CopedentError.new("Must be an Array") unless changes.is_a?(Array)

      changes.map { |change| apply_change(change) }
    end

    # used for printing
    def generate_column
      @tuning.map.with_index do |note, idx|
        fret = idx.zero? ? @fret_num : ""
        [fret, idx + 1, note, relation(key: @key, note:)]
      end
    end

    private

    def apply_change(change)
    end

    def relations_for(tuning:, key:, fret_num:)
      @tuning.map { |note| relation(key:, note:) }
    end

    def shift_tuning(tuning:, key:, fret_num:)
      tuning.map do |note|
        current_index = key.find_index(note)
        new_index = (current_index + fret_num) % key.length
        key[new_index]
      end
    end

    def relation(key:, note:)
      interval = key.find_index(note)
      RELATIONS[interval]
    end
  end
end
