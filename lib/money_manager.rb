require './lib/coin'

# Class to represent interface for money. Handles getting change, saving payments, returning available coins.
# NOTE: (Bills and coins are handled the same, eg, $5 is coin)
class MoneyManager
    attr_reader :accepted_coins, :max_quantity

    def initialize(config)
        @accepted_coins = Array.new # Array of accepted coins
        @all_values = Array.new # Array of coin values
        @coins = {} # Hash | key = value of coin, value = Coin object
        @till = {} # Hash | key = value of coin, value = quantity of coin

        save_config(config)
    end

    public

    # Returns true if till can provide full value of change due, else false
    def can_make_change?(change_due)
        return get_change(change_due, false)&.zero?
    end

    # Algorithm to make accurate change using the least amount of coins possible.
    # NOTE: values*100 to handle floating bit precision errors
    # Inputs: change_due: change required by user | modify: if modify update till with coins being returned
    # Outputs: 0 if full change can be made, else return the value of missing change that can not be made
    def get_change(change_due, modify)
        till_value = get_till_value
        return till_value unless change_due<=till_value

        curr = change_due*100
        @all_values.each do |value| # For each coin (values descending - enforced by config)
            can_take=[((curr/100)/value), @till[value]].min.to_i

            curr-=(value*can_take*100)

            can_take and modify and @till[value]-=can_take

            return 0 unless curr # Short circuit and return 0 when change made
        end

        return (curr/100).round(2) # Return value of missing change
    end

    # Saves payment by increasing quantity of coins in till
    def save_payment(coins_inserted)
        coins_inserted.each do |value, quantity|
            @till[value]+=quantity
        end
    end

    # Return Hash with coins and quantity of each.
    def get_coin_quantities
        return @coins.map do |value, coin|
            [coin, @till[value]]
        end.to_h
    end

    # return quantity of coin value
    def get_coin_quantity(value)
        return @till[value] || 0
    end

    private

    # Validate and save config for initial setup
    def save_config(config)
        default_quantity = config["default_quantity"]
        @max_quantity = config["max_quantity_per_coin"]

        prev = 10000
        config["accepted_coins"].each_with_index do |coin, idx|
            coin_value = coin["value"]
            coin_quantity = coin["initial_quantity"] || default_quantity

            raise "Invalid config, coin quantity exceeds limit." unless coin_quantity <= @max_quantity 
            raise "Invalid config, coins should be saved in descending order" unless prev>coin_value

            @accepted_coins.append(Coin.new(idx, coin["display_name"], coin["value"]))
            @all_values.append(coin_value)
            @coins[coin_value] = coin
            @till[coin_value] = coin_quantity
        end
    end

    # Get total value of till
    def get_till_value
        return @till.reduce(0) { |sum, (value, quantity)| sum+=(value*quantity) }
    end
end