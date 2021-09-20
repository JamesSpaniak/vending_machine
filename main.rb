require './lib/vending_machine'
require 'yaml'

config = YAML.load_file('settings.yaml')

vm = VendingMachine.new(config)
vm.start