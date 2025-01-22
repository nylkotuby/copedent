# describes a single change (raise or lower) in a copedent
# measured in semitones/half-tones
# glorified tuple of (string (ie index of tuning +1), modifier)
module Copedent
  class Change
    attr_accessor :string, :modifier, :note

    def initialize(string:, modifier:)
      @string = string
      @modifier = modifier
    end

    def note_index
      @string - 1
    end

    # ruby pattern would be to name `note` and memoize, but i find this misleading and bad
    # it's good to break patterns sometimes
    def set_note(tuning:, key:)
      @note = shift_note(note: tuning[note_index], amount: @modifier, key:,)
    end

    def validate!
      raise CopedentError.new("string must be an int") unless @string.is_a?(Int)
      raise CopedentError.new("string must be > 0") unless @string > 0

      raise CopedentError.new("modifier must be an int") unless @modifer.is_a?(Int)
    end

    private

    # TODO - changer module?
    def shift_note(note:, amount:, key:)
      current_index = key.find_index(note)
      new_index = (current_index + amount) % key.length
      key[new_index]
    end
  end
end
