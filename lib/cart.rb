require './lib/item'

class Cart
    def initialize
        @items_selected = Array.new
        @item_map = {}
        @cart_value = 0
    end

    def get_items_value
        return @cart_value
    end

    def get_items
        return @items_selected
    end

    def get_item_quantity(id)
        return @item_map[id] || 0
    end

    def get_num_items
        return @items_selected.length
    end

    def add_item(item)
        @items_selected.append(item)
        @cart_value+=item.value
        if !@item_map.include?(item.id)
            @item_map[item.id] = 1
        else
            @item_map[item.id] += 1
        end
    end

    def is_empty?
        return @items_selected.empty?
    end
end