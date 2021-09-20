# Class to represent coin type object
class Coin
    attr_reader :id, :name, :value
  
    def initialize(id, name, value)
        @id = id
        @name = name
        @value = value
    end
end