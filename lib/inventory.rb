require './lib/item'

# Class to represent machine inventory
class Inventory
    attr_reader :max_quantity

    def initialize(config)
        @item_counts = {} # Hash | key = id, value = quantity
        @items = {} # Hash | key = id, value = Item

        save_config(config)
    end

    public

    # Returns all items available. Availability determined from stock of item in inventory minus (-) items of type in cart > 0.
    # Takes Cart object as input.
    def get_items_available(cart)
        items_in_stock = @item_counts.filter_map { | id, count | @items[id] if (count-cart.get_item_quantity(id)).positive? }

        return items_in_stock
    end

    # Dispense cart items
    def dispense_cart_items(cart)
        cart.get_items.each do |item|
            dispense(item.id)
        end
    end

    # Dispense item from inventory
    def dispense(id)
        @item_counts[id]-=1
    end

    def get_item_count(id)
        return @item_counts[id] || 0
    end

    def get_item_counts
        @items.map do |id, item|
            [item, @item_counts[id]]
        end.to_h
    end

    def add_items_to_stock(item, quantity)
        @item_counts[item.id]+=quantity
    end

    private

    # Validate and save config for initial inventory setup
    def save_config(config)
        default_quantity = config["default_quantity"]
        @max_quantity = config["max_quantity_per_item"]

        config["initial_products"].each_with_index do |item, idx|
            item_quantity = default_quantity
            item_quantity = item["initial_quantity"] || default_quantity

            raise "Invalid config, item quantity exceeds limit." unless item_quantity <= @max_quantity 

            @item_counts[idx] = item_quantity
            @items[idx] = Item.new(idx, item["display_name"], item["price"])
        end
    end
end