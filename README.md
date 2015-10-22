[![Dolly](http://dolly.railsc.ru/badges/abak-press/slaver/master)](http://dolly.railsc.ru/projects/129/builds/latest/?ref=master)

# Slaver

Welcome to slaver!

It's a simple gem for rails application within multi-database environment.
It allows you to change your current connection to other database configuration.
Some ideas was inspired by [octopus](https://github.com/tchandy/octopus).

## WARNING

It was tested only on `rails 3` and `ruby 1.9.3`. Other configurations may work or may not:)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slaver'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slaver

## Usage

### Config
You must have other connection on your database.yml file. For example:

```yml
production:
  adapter: pg
  host: master
  database: master
  post: 11111

production_slave:
  adapter: sqlite3
  host: slave
  database: slave
  post: 11113

production_mysql:
  adapter: mysql
  user: me
  host: somewhere_else
  post: 11112
  database: mysql
```

### Chain with AR

Only works with class/scope methods. Connection changed until query is perfomed. After that it'll swiched back to default connection.

```ruby
  SomeModel.on(:production_mysql).where(name: 'me').first


  # or, if you name starting with you Rails.env it can be skipped
  SomeModel.on(:mysql).where(name: 'me').to_a
```

### Execute block on other connection

Connection will be switched only for required class.

```ruby
  SomeModel.within(:slave) do
    SomeModel.where(name: 'me')
  end

  # It also can be combined with "on" method

  SomeModel.within(:mysql) do
    me = SomeModel.find_by_name('me')
    SomeModel.on(:slave).find_by_name('me').update_attributes(me.attributes)
  end

  # ACTUNG!!
  Somemodel.within(:slave) do
    #!!! Will be executed on default connection for OtherModel
    OtherModel.where(name: 'me').first
  end
```

### Execute whole method on any class on other connection
```ruby
class Some
  extend Slavable

  def some_method
    Foo.create
    f = Foo.where(...).first
    other = SomeModel.where(...).first
    f.update_attributes(...)
    other.update_attributes(...)
    ...
  end

  def self.class_method
    b = Bar.create
    b.update_attributes(...)
    Foo.where(bar: b)
    ....
  end

  switch :some_method, to: :other

  # it also can be called on multiple methods and works with class_methods

  switch :some_method, ..., to: :other

  # for switching class method just use singleton class pattern:
  class << self
    extend Slavable

    switch :class_method, ..., to: :other
  end
  ....
end

# it''ll be executed with :other connection
Some.class_method
Some.new.some_method
```

### ACTUNG!!!!

If you connection does not exists, behavior may change dependent of you current Rails environment:
 - `Rails.env == production`: It'll raise `ArgumentError`
 - otherwise: It'll try to switch to default connection - `Rails.env`

### Missing features

1. 'on' with assosiations
2. Transaction safety
3. `on` method on instance

## Development

To run test on local machine use `make` command. For more info please reffer to Makefile.

## Contributing

1. Fork it ( https://github.com/abak-press/slaver/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request



## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
