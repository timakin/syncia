# Syncia

File sync service with Ruby. The procedure is:

```
1. Start as a daemon process
2. Start to watch a designated folder
3. If updated, execute rsync command
4. Synchronize your files to remote host
5. Endup if it received a signal.
```

Before synchronizing your file, you must register public key to the remote host like below:

```
$ cat ~/.ssh/id_rsa.pub | shh your_remote_host 'cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'syncia'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install syncia

## Usage

```syncia.rb
require 'Syncia'

syncia = Syncia.new('./testdir')
syncia.set_remote_info('timakin', '153.121.70.114')
syncia.set_remote_dir('/home/timakin/sync')
syncia.run
```

```CLI
$ ruby syncia.rb
$ cat .syncia.pid | xargs kill 
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/timakin/syncia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
