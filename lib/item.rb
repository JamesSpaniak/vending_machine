# Class to represent item object
class Item
    attr_reader :id, :name, :value
  
    def initialize(id, name, value)
        @id = id
        @name = name
        @value = value
    end
end