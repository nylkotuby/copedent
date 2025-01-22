# models a single fret, which might return several different columns of analysis
# like several pedal and lever combinations that would work at this fret
# long-term, might be better to do this less similarly to how it's done irl
module Copedent
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

  # TODO - don't special case open tuning
  class Fret
    def initialize(tuning:, key:, fret_num:, changelist:)
      @key = key
      @tuning = shift_tuning(tuning:, fret_num:)
      @fret_num = fret_num
      @changelist = create_changelist(changelist:)
      @modified_tunings = tunings_for(changelist: @changelist, fret_num:)
    end

    # return array of different valid change combos that work on this fret
    def generate_columns(types:)
      if tuning_has_valid_chord?(tuning: @tuning, types:)
        open = generate_column_for(mapping: @tuning)
      end

      changes =
        @modified_tunings
          .select { |_, list| tuning_has_valid_chord?(tuning: list, types:) }
          .select { |name, list| change_modified_chord_tone?(name:, types:) }
          .map { |name, list| generate_column_for(mapping: list, name:) }

      changes
        .unshift(open)
        .compact
    end

    private

    # tell if this change raised/lowered to a chord tone,
    # which makes it of interest to the player.
    # restricts the number of possible options shown to a reasonable set
    def change_modified_chord_tone?(name:, types:)
      # any single chord tone is fine for now
      qualities = types.flat_map do |type|
        QUALITIES[type].flatten.uniq - ["Root"]
      end

      @changelist[name].any? do |change|
        qualities.include?(relation(note: change.note))
      end
    end

    # TODO: optimization - should save the relation map w/the tuning map
    # so we don't re-generate on column generation
    def tuning_has_valid_chord?(tuning:, types:)
      notes = tuning.map { |note| relation(note:) }
      types.any? do |type|
        QUALITIES[type].any? do |combo|
          combo.all? { |qual| notes.include?(qual) }
        end
      end
    end

    # be VERY careful
    # we are aligned on string index here but it would be better to use string # in the future
    def generate_column_for(mapping:, name: nil)
      col = mapping.map.with_index do |note, idx|
        ["", idx + 1, note, relation(note:)]
      end

      # add extra info to the reserved title column
      col[0][0] = @fret_num

      unless name.nil? # ignore open tuning
        @changelist[name].each do |change|
          col[change.note_index][0] = name.to_s
        end
      end

      col
    end

    def tunings_for(changelist:, fret_num:)
      changelist.transform_values { |list| tuning_with_override(list:) }
    end

    def tuning_with_override(list: [])
      @tuning.map.with_index do |default_note, idx|
        if (change = list.detect { |ch| ch.note_index == idx })
          change.note
        else
          default_note
        end
      end
    end

    def create_changelist(changelist:)
      raise CopedentError.new("Must be a Hash") unless changelist.is_a?(Hash)

      changelist.transform_values { |list| apply_change(list:) }
    end

    def apply_change(list:)
      list.map do |change|
        Change.new(
          string: change[:string],
          modifier: change[:modifier],
          tuning: @tuning,
          key: @key
        )
      end
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
