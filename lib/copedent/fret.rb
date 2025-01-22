# models a single fret, which might return several different columns of analysis
# like several pedal and lever combinations that would work at this fret
# long-term, might be better to do this less similarly to how it's done irl
module Copedent
  # TODO - look for multiple combinations of the triad
  QUALITIES = {
    major: [["Root", "3"], ["3", "maj7"]],
    minor: [["Root", "b3"], ["b3", "b7"]],
    dom7: [["3", "b7"]]
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

    # TODO: make this not static, probably
    # check if the given fret has all of the required chord qualities for configured chords
    # e.g. a major chord must have a 3, but a dom 7 must have a 3 and a b7
    def self.has_valid_chord?(fret:, types:)
      notes = fret.transpose[3]
      types.any? do |type|
        QUALITIES[type].any? { |combo| combo.all? { |qual| notes.include?(qual) } }
      end
    end

    # return array of different valid change combos that work on this fret
    def generate_columns(changelist:)
      single_mods = changelist.map do |name, list|
        overrides = list.each_with_object({}) do |change, hsh|
          hsh[change.note_index] = {note: change.note, name:}
        end

        generate_column_for(mapping: @tuning, overrides:, names: [name])
      end

      open = generate_column_for(mapping: @tuning)

      [open] | single_mods
    end

    private

    # be VERY careful
    # we are aligned on string index here but it would be better to use string # in the future
    def generate_column_for(mapping:, overrides: {}, names: [])
      col = mapping.map.with_index do |note, idx|
        note = overrides[idx][:note] unless overrides[idx].nil?
        ["", idx + 1, note, relation(note:)]
      end

      # add extra info to the reserved title column
      col[0][0] = @fret_num
      overrides.keys.each do |idx|
        col[idx][0] = overrides[idx][:name].to_s
      end

      col
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
