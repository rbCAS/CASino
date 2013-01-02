# CASino [![Build Status](https://secure.travis-ci.org/rbCAS/CASino.png?branch=master)](https://travis-ci.org/rbCAS/CASino)

A simple [CAS](http://www.jasig.org/cas) server written in Ruby using the Rails framework.

It currently supports [CAS 1.0 and CAS 2.0](http://www.jasig.org/cas/protocol) as well as [CAS 3.1 Single Sign Out](https://wiki.jasig.org/display/CASUM/Single+Sign+Out) and [CAS RESTful API](https://wiki.jasig.org/display/CASUM/RESTful+API).

CASino is separated into a web app and core components:

* CASino is the web application (using the Rails framework)
* CASinoCore contains all the CAS server logic

This simplifies the creation of a CAS server implementation for other developers.

## Setup

### 1. Create a Ruby on Rails application

Make sure you installed Ruby on Rails 3.2.x!

    rails new my-casino --skip-active-record --skip-test-unit --skip-bundle
    cd my-casino

### 2. Include and install CASino engine gem

Edit your application's Gemfile and add these lines if missing:

    gem 'sqlite3', '~> 1.3'
    gem 'casino'

Run `bundle install` afterwards.

### 3. Generate the initial configuration

    bundle exec rails g casino:install

### 4. Edit the configuration

    mate config/cas.yml
    mate config/database.yml

Information about configuration can be found in our Wiki: [Configuration](https://github.com/pencil/CASino/wiki/Configuration)

### 5. Load the database

Load the default DB schema with `rake casino_core:db:schema:load`. After an update, run `rake casino_core:db:migrate` instead.

### 6. Configure a cronjob

Configure a cronjob to do a `rake casino_core:cleanup:all > /dev/null` every 5 minutes. This is not essential in a development environment.

### 7. Customize it!

Learn how to customize your CASino installation: [Customization](https://github.com/pencil/CASino/wiki/Customization)

### 8. Ship it!

To start the server in a development environment, run:

    bundle exec rails s

## Contributing to CASino

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.

## Copyright

Copyright (c) 2012 Nils Caspar. See LICENSE.txt for further details.
