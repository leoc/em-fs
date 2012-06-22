# EM::FS

`EM::FS` provides a simple interface to gain simple filesystem access
in eventmachine via `EM::SystemCommand`.

`EM::FileUtils` attempts to mimic the behavoir of the filesystem API
of the Ruby stdlib. In the background it invokes linux/unix system
commands - like `rsync`, `mkdir` etc. - via the `em-systemcommand`
gem.

Furthermore `EM::Dir` and `EM::File` provide methods to crawl
directory structures via `find` command without blocking the reactor.

## Installation

Add this line to your application's Gemfile:

    gem 'em-fs'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install em-fs

## Usage

### FileUtils

`EM::FileUtils` basically provides an API similar to the `FileUtils`
class in the Ruby stdlib.

Have a look at the documentation.

### Crawl Directory Structures

    EM::Dir['./**/*.*'].each do |stat|
      puts stat.size
    end
    
    EM::Dir['./**/*.lisp'].each_entry do |entry|
      
    end
    
    EM::Dir['./**/*.rb'].each_path do |path|
      
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
