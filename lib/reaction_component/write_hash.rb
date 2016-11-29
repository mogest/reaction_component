module ReactionComponent
  class WriteHash
    attr_reader :read_hash, :write_hash

    def initialize(read_hash)
      @read_hash = read_hash
      @write_hash = {}
    end

    def [](key)
      @write_hash.fetch(key, @read_hash[key])
    end

    def []=(key, value)
      @write_hash[key] = value
    end

    def to_json
      @write_hash.to_json
    end
  end
end

