# parameters and logic for a complete Sheet of analysis, which is several Frets
module Copedent
  class Sheet
    def initialize(root:, tuning:, changelist:, opts:)
      @root = root
      @tuning = tuning
      @changelist = changelist
      @chord_types = opts[:chord_types]
      @opts = opts
    end

    def analyze
      key = shift_key(to: @root)

      # the copedent is read column-wise, so to make partial calculations,
      # it only makes sense to do so in columnar blocks
      (0..11)
        .map { |fret_num| Fret.new(tuning: @tuning, key:, fret_num:) }
        .select { |fret| fret.has_valid_chord?(types: @chord_types) }
        .map(&:generate_column)
    end

    private

    def shift_key(to:)
      ALL_NOTES
        .slice_before(to)
        .to_a # rails .split() would avoid the type fixup
        .reverse
        .flatten
    end
  end
end
