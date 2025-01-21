# parameters and logic for a single Sheet of analysis
module Copedent
  class Sheet
    def initialize(tuning:, root:, types:)
      @tuning = tuning
      @root = root
      @types = types
    end

    def analyze
      key = shift_key(to: @root)

      # the copedent is read column-wise, so to make partial calculations,
      # it only makes sense to do so in columnar blocks
      (0..11)
        .map { |fret| convert_fret(tuning: @tuning, key:, fret:) }
        .select { |fret| has_valid_chord?(fret:, types: @types) }
    end

    private

    def shift_key(to:)
      ALL_NOTES
        .slice_before(to)
        .to_a # rails .split() would avoid the type fixup
        .reverse
        .flatten
    end

    # TODO - consider making a fret class
    # returns a fret, which is several columns and rows
    # long-term, might be better to do this less similarly to how it's done irl
    def convert_fret(tuning:, key:, fret:)
      shift_tuning(tuning:, key:, fret:)
        .map
        .with_index do |note, idx|
          fret_num = idx.zero? ? fret : ""
          [fret_num, idx + 1, note, relation(key:, note:)]
        end
    end

    # check if the given fret has all of the required chord qualities for configured chords
    # e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
    def has_valid_chord?(fret:, types:)
      # transpose is done since these are columns instead of rows
      notes = fret.transpose[3]
      types.any? do |type|
        QUALITIES[type].all? { |qual| notes.include?(qual) }
      end
    end

    def shift_tuning(tuning:, key:, fret:)
      tuning.map do |note|
        current_index = key.find_index(note)
        new_index = (current_index + fret) % key.length
        key[new_index]
      end
    end

    def relation(key:, note:)
      interval = key.find_index(note)
      RELATIONS[interval]
    end
  end
end
