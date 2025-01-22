# describes a single change (raise or lower) in a copedent
# measured in semitones/half-tones
# glorified tuple of (string (ie index of tuning +1), modifier)
module Copedent
  class Change
    def initialize(string:, modifier:)
      @string = string
      @modifier = modifier
    end

    def validate!
      raise CopedentError.new("string must be an int") unless @string.is_a?(Int)
      raise CopedentError.new("string must be > 0") unless @string > 0

      raise CopedentError.new("modifier must be an int") unless @modifer.is_a?(Int)
    end
  end
end
