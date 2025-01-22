# parameters and logic for a complete Sheet of analysis, which is several Frets
module Copedent
  class Sheet
    def initialize(root:, tuning:, changelist:, opts:)
      @root = root
      @tuning = tuning
      @key = shift_key(to: @root)
      @changelist = apply_changelist(changelist:)
      @chord_types = opts[:chord_types]
      @opts = opts
    end

    def analyze
      # the copedent is read column-wise, so to make partial calculations,
      # it only makes sense to do so in columnar blocks
      (0..11)
        .map { |fret_num| Fret.new(tuning: @tuning, key: @key, changelist: @changelist, fret_num:) }
        .flat_map { |fret| fret.generate_columns(changelist: @changelist, types: @chord_types) }
    end

    private

    def shift_key(to:)
      ALL_NOTES
        .slice_before(to)
        .to_a # rails .split() would avoid the type fixup
        .reverse
        .flatten
    end

    def apply_changelist(changelist:)
      raise CopedentError.new("Must be an Array") unless changelist.is_a?(Hash)

      changelist.each { |_, list| apply_change(list:) }
    end

    def apply_change(list:)
      list.map { |change| change.set_note(tuning: @tuning, key: @key) }
    end
  end
end
