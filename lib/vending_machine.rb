require './lib/cart'
require './lib/display'
require './lib/inventory'
require './lib/money_manager'
require './lib/item'

# VendingMachine class handles connection between user input and core classes.
# See settings.yaml for example config setup
#
# James Spaniak September 2021
#

class VendingMachine
    def initialize(config)
        @config = config
        @display = Display.new
        
        initialize_machine_state
    end

    public

    # Starts machine, runs infinitely giving user menu options to interact with.
    def start
        @display.welcome_message
        loop do
            option = @display.menu(@cart.get_num_items)

            case option
            when 1
                order
            when 2
                checkout
            when 3
                reload_till
            when 4
                reload_inventory
            when 5
                initialize_machine_state
            when 6
                @display.goodbye_message
                exit true
            end
        end
    end

    private

    def initialize_machine_state
        @inventory = Inventory.new(@config["inventory"])
        @money_manager = MoneyManager.new(@config["money_manager"])
        @cart = Cart.new
    end

    # Displays user list of items available. If an item is selected add to cart.
    def order
        item_list = @inventory.get_items_available(@cart) # Return items in stock
        latest_selection = @display.item_options(item_list)

        if latest_selection
            @cart.add_item(latest_selection)
        end
    end


    # Checkout cart logic. If not empty, display info and collect initial payment. Collect more payments until total cost is meet.
    # Return change if value paid > cart cost. Dispense user items from inventory.
    def checkout
        if @cart.is_empty?
            @display.no_selection
        else
            coins_inserted = {}
            @display.checkout_message(@cart.get_num_items, @cart.get_items_value)
            money_inserted = @display.payment_options(@money_manager.accepted_coins) # Initial payment
            money_required = @cart.get_items_value
            coins_inserted[money_inserted] = 1

            if money_inserted > money_required
                # Return if no change and user returns
                return unless try_make_change(money_inserted-money_required)
            else
                while money_inserted < money_required
                    @display.request_additional_payment(money_required-money_inserted)
                    val_inserted = @display.payment_options(@money_manager.accepted_coins)
                    money_inserted+=val_inserted

                    # While collecting payments save what coins are inserted based on value
                    coins_inserted.key?(val_inserted) ? coins_inserted[val_inserted] += 1 : coins_inserted[val_inserted] = 1
                end

                if money_inserted > money_required
                    # Return if no change and user returns
                    return unless try_make_change(money_inserted-money_required)
                end
            end

            @money_manager.save_payment(coins_inserted)
            @inventory.dispense_cart_items(@cart)
            reset_cart
        end
    end

    # Tries to make change, if full change is not available give user the option to recieve partial change.
    # Returns true if user recieves change, false if user does not want change.
    def try_make_change(change_due)
        if @money_manager.can_make_change?(change_due)
            @display.give_change(change_due)
            @money_manager.get_change(change_due, true)
            return true
        else
            # Change not available
            change_missing = @money_manager.get_change(change_due, false)
            option = @display.offer_new_cost(change_missing+@cart.get_items_value) # Total cost is delta between cost + (change available in till)

            case option
            when 1
                # Take change available
                @display.give_change(change_due-change_missing)
                @money_manager.get_change(change_due-change_missing, true)
                return true
            when 2
                # Continue Shopping (keep cart)
                return false
            when 3
                # Start over, returns items in cart
                reset_cart
                return false
            end
        end
    end

    # Takes user through flow to add a more of a coin to the till.
    def reload_till
        coin_quantities = @money_manager.get_coin_quantities
        coin = @display.show_current_till(coin_quantities)

        if coin
            if (@money_manager.max_quantity-coin_quantities[coin])<=0 # If till can not hold any more of denomination, display max quantity
                @display.stock_limit(@money_manager.max_quantity)     # NOTE: machine can hold more than max of denomination when accepting payments to ensure money is not lost.
                return                                                # But we should respect the limit when manually loading to ensure space is respected.
            end
            refill = {}
            refill[coin['value']] = @display.refill_item(@money_manager.max_quantity-coin_quantities[coin])
            @money_manager.save_payment(refill)
        end
    end

    # Takes user through flow to increase stock of item
    def reload_inventory
        item_counts = @inventory.get_item_counts
        item = @display.show_current_stock(item_counts)

        if item
            if (@inventory.max_quantity-item_counts[item])<=0 # Ensure item capacity is adheared to
                @display.stock_limit(@inventory.max_quantity)
                return
            end
            to_add = @display.refill_item(@inventory.max_quantity-item_counts[item])
            @inventory.add_items_to_stock(item, to_add)
        end
    end

    # When user is returning cart / leaving
    def reset_cart
        @display.goodbye_message
        @cart = Cart.new
    end
end