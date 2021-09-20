require 'tty-prompt'
require 'tty-table'

# Class to handle CLI interface. Displays messages and collects user inputs
# See https://github.com/piotrmurach/tty-prompt for supported use cases and extensive test suite.
class Display
    PROMPT = TTY::Prompt.new(symbols: { marker: '>' }, interrupt: :exit)

    def welcome_message
        PROMPT.ok("Welcome to James Spaniak's Vending Machine!")
    end

    def goodbye_message
        PROMPT.ok("Thank you for coming!")
    end

    def menu(cart_items)
        options = [
            { name: 'Vend', value: 1 },
            { name: 'Checkout', value: 2 },
            { name: 'Reload Till', value: 3 },
            { name: 'Reload Inventory', value: 4 },
            { name: 'Reset Machine State', value: 5 },
            { name: 'Quit', value: 6 }
        ]
        PROMPT.select("Cart Size: #{cart_items}. Select an action to continue", options)
    end

    def add_go_back(item_list)
        item_list << { name: 'Go Back', value: nil }
    end
    
    def item_options(list)
        item_list = list.map { |item| item_details(item) }
        add_go_back(item_list)
        
        PROMPT.select("Select Item", item_list)
    end

    def item_details(item)
        {
            name: "#{item.name} $#{'%.2f' % item.value}", 
            value: item
        }
    end

    def checkout_message(num_items, cost)
        PROMPT.ok("Thank you for visiting! You total cost for (#{num_items}) item(s) is $#{'%.2f' % cost}.")
    end

    def request_additional_payment(cost)
        PROMPT.warn("Amount remaining due: $#{'%.2f' % cost}.")
    end

    def payment_options(accepted_coins)
        coin_list = accepted_coins.map { |coin| coin_details(coin) }
        add_go_back(coin_list)
        PROMPT.select("Please select a payment.", coin_list)
    end

    def coin_details(item)
        {
            name: "$#{'%.2f' % item.value}", 
            value: item.value
        }
    end
    
    def offer_new_cost(cost)
        options = [
            { name: "Recieve partial change. Total cost: $#{'%.2f' % cost}", value: 1 },
            { name: 'Continue shopping', value: 2 },
            { name: "Start over", value: 3 },
        ]
        PROMPT.select("Unfortunately we can not make change. Please select an option.", options)
    end

    def give_change(change_returned)
        PROMPT.ok("Change returned: $#{'%.2f' % change_returned}")
    end

    def show_current_stock(item_quantities)
        options = Array.new
        item_quantities.each do | item, quantity |
            options.append({ name: "#{item.name}, Current stock: #{quantity}", value: item })
        end
        add_go_back(options)
        PROMPT.select("Select an item to restock.", options)
    end

    def refill_item(max_items)
        PROMPT.slider("Reload", max: max_items, step: 1, default: 5)
    end

    def no_selection
        PROMPT.ok("No items in cart, returning.")
    end

    def show_current_till(coin_quantities)
        options = Array.new
        coin_quantities.each do | coin, quantity |
            options.append({ name: "#{coin['display_name']}, Amount remaining: #{quantity}", value: coin })
        end
        add_go_back(options)
        PROMPT.select("Select a coin to restock.", options)
    end

    def stock_limit(max)
        PROMPT.warn("Maximum number (#{max}) already reached.")
    end
end