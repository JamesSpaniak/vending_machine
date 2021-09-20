require './lib/money_manager'

require 'test/unit'


class MoneyManagerTest < Test::Unit::TestCase
    class << self
        def startup
            @@money_manager_settings = {
                "default_quantity" => 5,
                "max_quantity_per_coin" => 15,
                "accepted_coins" => [
                    { "display_name" => "$20", "value" => 20.00, "initial_quantity" => 0 },
                    { "display_name" => "$10", "value" => 10.00, "initial_quantity" => 0 },
                    { "display_name" => "$5", "value" => 5.00 },
                    { "display_name" => "$1", "value" => 1.00 },
                    { "display_name" => "25c", "value" => 0.25 },
                    { "display_name" => "10c", "value" => 0.10 },
                    { "display_name" => "5c", "value" => 0.05 },
                    { "display_name" => "1c", "value" => 0.01 }
                ]
            }
        end
    end

    def setup
        @money_manager = MoneyManager.new(@@money_manager_settings)
    end

    def test_initial_config
        assert_equal(@money_manager.get_coin_quantity(20.00), 0, "Initial config setup incorrect.")
        assert_equal(@money_manager.get_coin_quantity(5.00), 5, "Initial config setup incorrect.")
        assert_equal(@money_manager.get_coin_quantity(0.01), 5, "Initial config setup incorrect.")
        assert_equal(@money_manager.get_coin_quantity(50.00), 0, "Initial config setup incorrect.")
    end

    def test_can_make_change?
        assert(@money_manager.can_make_change?(0), "Can not make change for 0.00 due.")

        assert_false(@money_manager.can_make_change?(35.00), "Can make change for more than till total.")
    end

    def test_get_change
        assert_equal(@money_manager.get_change(0, true), 0, "Incorrect change returned for 0 expected.")

        assert_equal(@money_manager.get_change(4.50, true), 0, "Full change not returned.")
        assert_equal(@money_manager.get_change(0.07, true), 0, "Full change not returned.")

        assert_equal(@money_manager.get_change(7.03, true), 0, "Full change not returned.")
        assert_equal(@money_manager.get_change(0.25, true), 0, "Full change not returned.")

        assert_predicate(@money_manager.get_change(25.00, false), :positive?, "Change made for more than till total.")

        assert_not_equal(@money_manager.get_change(2.37, true), 0, "Made change from till with missing required coins.")
    end

    def test_save_payment
        payments = {
            5.00 => 1,
            0.25 => 1
        }
        @money_manager.save_payment(payments)

        assert_equal(@money_manager.get_coin_quantity(5.00), 6, "Payment not saved.")
        assert_equal(@money_manager.get_coin_quantity(10.00), 0, "Empty denomination returns non-zero.")

        second_payments = {
            10.00 => 1
        }
        @money_manager.save_payment(second_payments)

        assert_equal(@money_manager.get_coin_quantity(10.00), 1, "Payment not saved for initial zero value.")
    end
end