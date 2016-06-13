# Changelog

## 0.3.0
- When allowed is provide in a parameter, the cli provide an interactive chooser of available parameter

###Breaking Change
- Construction of the cli has no change, you can now:
    * create a class extending `CoffeeCli` and annotate you function
    * instanciate `CoffeeCli` and use `addCommand`

see [README](https://github.com/lejard-h/coffee_cli/blob/master/README.md)


## 0.2.1

* Fix various bugs

## 0.2.0

###Breaking Change
- `CoffeeParameter` 
    - `possibleValues` in `CoffeeParameter` change by `allowed`
    - `bool` parameter are no define as a flag
- `CoffeeCommand`
    - `command` rename by `executable`
    - `subcommands` rename by `commands`
 
    
* Can add CoffeeCommand as subcommand of an other CoffeeCommand
* Better usage

## 0.1.1

Fix usage

## 0.1.0

Easy way to create interactive command line application
