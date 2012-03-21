# EM::FileUtils

`EM::FileUtils` provides a simple API to make invoke filesystem
commands in eventmachine.

## Installation

Add this line to your application's Gemfile:

    gem 'em_fileutils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em_fileutils

## Usage

Essentially the idea is to provide a similar API to what the Ruby
Stdlib is providing. Just that you get back a EM::FilesystemCommand on
which you can call asynchronous methods like `#watch`, `#success`,
`#readline`, `#progess` and so on.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
