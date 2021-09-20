# Vending Machine

## Overview
Vending Machine built in ruby that supports inventory and accepted currencies customization. Through the use of a cart, an end user can purchase multiple items in one transaction. When accepting payments if the machine can not make full change an offer for partial change will appear. The end user can stock inventory of items and refill the till for all coin values via the menu.

## Product Ask
Implement a vending machine with the following functionality
- Once an item is selected and the appropriate amount of money (coins) is inserted, the vending machine should return the product
- It should also return change if too much money is provided, or ask for more money if insufficient funds have been inserted.
- Correctly manage scenarios where the item is out of stock or the machine does not have enough change to return to the customer.

## Extended Functionality

- Multi product transactions through the use of the cart.
- If the machine can not make full change offer the user to recieve partial change.
- An end user can restock inventory and coin quantities through the menu.
- Easily customizable configuration to setup vending machine in various states.

## Setup and Installation
To get started with the project:

### Prerequisites
Ruby 3.0.2 is required for the project.

### Installation
Download project repo

Install Gem dependencies.
```
bundle install
```

### Entry Point & Initialization
The vending machine entry point is main.rb

Initial inventory stock based on products under inventory.initial_products in the config located in the settings.yaml. Accepted currencies can be defined in the settings alongside their initial quantity available.

To start the vending machine:
```
ruby main.rb
```

### Running Tests
Run the tests from the project root folder.
```
rake
```

### Configuration
Project configuration is located in settings.yaml.

To add a product to the vending machine add the following under inventory.initial_products.
```
    - display_name: "Buffalo Chicken Wrap"
      price: 8.37
      initial_quantity: 0
```

See table for more information regarding setting customization.

| Field Name   | Type  | Description |
| :----------: | :----:| :---------: |
| inventory | object | Contains settings for vending machine Inventory class. |
| money_manager | object | Contains settings for vending machine MoneyManager class. |
| [inventory, money_manager].default_quantity | int | Default value for quantity of items or coins. |
| inventory.max_quantity_per_item | int | Maximum number of items allowed in stock. |
| inventory.initial_products | list | List of items stocked by machine. |
| money_manager.max_quantity_per_coin | int | Maximum number of coins allowed in stock *(NOTE: Max only affects number of coins available for restock, will not reject payment at max.)*. |
| money_manager.accepted_coins | list | List of accepted payment types. |

### Built With
- Ruby 3.0.2
- tty-prompt, tty-table

## Implementation Details
Started with simple classes for Coins and Items. The Coin class is attributed by value and a display name. An instance of an Item has a price (represented by value), and display name. The MoneyManager and Inventory classes hold instances of the Coin and Item respectively to represent quantities, and contain logic to handle viewing data, checkouts, payments, and refills.

Calculation of the coins returned after a sale uses a greedy algorithm approace. The coins are ordered by value (based on initial setup), from largest to smallest, and iterated to select the largest denomination of coin which is not greater than the remaining amount to be made. If the MoneyManager's stock does not support making change for the value requested it can offer the largest it can give.

The Cart class describes the current list of the items the user is purchasing. The class has information for number of items selected and value of items in the cart.

This vending machine uses the interactive command line prompt, tty-prompt. The Display class contains methods to inferace between the end user and the program.

## Design Considerations Made
- To use classes and maintain a separation of modules that each contain self contained logic.
- Items are modelled by a Item class with a value and display name.
- Inventory manages Item quantities.
- MoneyManager manages Coin quantities and transactions with coin change.
- Coins are modelled by a Coin class with value and display name.
- Display is an interface between tty-prompt and vending machine.
- Project configuration will be stored in settings.yaml file.

## Future Improvements
Future improvements if I had more time to work on this project

- Keep a history of transactions.
- Options to view most popular products, most restocked items, items with largest out of stock time, etc.
- Switch to database instead of in memory storage for long term data persistance.
- Support accounts to encourage return customers.