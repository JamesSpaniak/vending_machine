require './lib/cart'

require 'test/unit'

class CartTest < Test::Unit::TestCase

    def setup
        @cart = Cart.new
    end

    def test_items_value_verify
        assert_equal(@cart.get_items_value, 0, "Empty cart has non-zero value.")

        @cart.add_item(Item.new(0, "TestItem", 2))
        @cart.add_item(Item.new(1, "TestItem1", 5))
        @cart.add_item(Item.new(2, "TestItem2", 3))

        assert_equal(@cart.get_items_value, 10.0, "Cart returned invalid total items value.")
    end

    def test_add_items
        items = [Item.new(0, "TestItem", 5), Item.new(1, "TestItem1", 2), Item.new(2, "TestItem2", 10)]
        items.each do |item|
            @cart.add_item(item)
        end

        assert_equal(items, @cart.get_items, "Items added to cart do not match items recieved.")
    end

    def test_is_empty
        assert_equal(@cart.get_num_items, 0, "Empty cart contains n>0 items.")

        @cart.add_item(Item.new(0, "TestItem", 5))
        assert_equal(@cart.get_num_items, 1, "Cart num_items not updated after add.")

        20.times do
            @cart.add_item(Item.new(1, "TestItem1", 10))
        end
        assert_equal(@cart.get_num_items, 21, "After multiple updates cart does not show correct num_items.")
    end

    def test_item_quantity
        assert_equal(@cart.get_item_quantity(0), 0, "Item count for empty cart invalid.")

        @cart.add_item(Item.new(0, "TestItem", 5))
        assert_equal(@cart.get_item_quantity(0), 1, "Item count for single item incorrect.")

        35.times do
            @cart.add_item(Item.new(1, "TestItem1", 10))
        end
        assert_equal(@cart.get_item_quantity(0), 1, "First item count incorrect.")
        assert_equal(@cart.get_item_quantity(1), 35, "Recent item count incorrect.")
        assert_equal(@cart.get_item_quantity(2), 0, "Unadded item count non-zero.")
    end
end