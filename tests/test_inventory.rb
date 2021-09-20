require './lib/cart'
require './lib/inventory'

require 'test/unit'


class InventoryTest < Test::Unit::TestCase
    class << self
        def startup
            @@inventory_settings = {
                "default_quantity" => 2,
                "max_quantity_per_item" => 15,
                "initial_products" => [
                    { "display_name" => "TestItem1", "price" => 2.00 },
                    { "display_name" => "TestItem2", "price" => 3.00 },
                    { "display_name" => "TestItem3", "price" => 4.50, "initial_quantity" => 5 },
                    { "display_name" => "TestItem4", "price" => 4.50, "initial_quantity" => 0 }
                ]
            }
        end
    end

    def setup
        @inventory = Inventory.new(@@inventory_settings)
    end

    def test_initial_config
        assert_equal(@inventory.get_item_count(0), 2, "Initial config setup incorrect.")
        assert_equal(@inventory.get_item_count(2), 5, "Initial config setup incorrect.")
        assert_equal(@inventory.get_item_count(3), 0, "Initial config setup incorrect.")
    end

    def test_get_items_available
        items = @inventory.get_items_available(Cart.new)
        items.each do |item|
            assert_predicate(@inventory.get_item_count(item.id), :positive?, "Available item has negative stock.")
        end

        @inventory.dispense(0)
        @inventory.dispense(0)

        items = @inventory.get_items_available(Cart.new)
        items.each do |item|
            assert_predicate(@inventory.get_item_count(item.id), :positive?, "Available item has negative stock.")
        end
    end

    def test_dispense
        @inventory.dispense(0)
        assert_equal(@inventory.get_item_count(0), 1, "Item pre-dispense quantity incorrect.")

        @inventory.dispense(1)
        @inventory.dispense(1)
        assert_equal(@inventory.get_item_count(1), 0, "Item dispensed quantity incorrect.")

        assert_equal(@inventory.get_item_count(3), 0, "Item not dispensed quantity incorrect.")
    end

    def test_add_items_to_stock
        @inventory.add_items_to_stock(Item.new(0,nil,nil), 5)

        assert_equal(@inventory.get_item_count(0), 7, "Added items not reflected in stock.")
        assert_equal(@inventory.get_item_count(1), 2, "Non-updated items updated in stock.")
    end
end