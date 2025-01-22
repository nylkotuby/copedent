# parameters and logic for a complete Sheet of analysis, which is several Frets
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
        .map { |fret_num| Fret.new(tuning: @tuning, key:, fret_num:) }
        .select { |fret| fret.has_valid_chord?(types: @types) }
        .map(&:data)
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
