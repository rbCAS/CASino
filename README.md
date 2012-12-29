# CASino [![Build Status](https://secure.travis-ci.org/pencil/CASino.png?branch=master)](https://travis-ci.org/pencil/CASino)

A simple [CAS](http://www.jasig.org/cas) server written in Ruby using the Rails framework.

It currently supports [CAS 1.0 and CAS 2.0](http://www.jasig.org/cas/protocol) as well as [CAS 3.1 Single Sign Out](https://wiki.jasig.org/display/CASUM/Single+Sign+Out). Coming soon: [CAS RESTful API](https://wiki.jasig.org/display/CASUM/RESTful+API)

CASino is separated into a web app and core components:

* CASino is the web application (using the Rails framework)
* CASinoCore contains all the CAS server logic

This simplifies the creation of a CAS server implementation for other developers.

## Setup

* Clone the project
* Customize the design (`app/assets/stylesheets`, `app/views/layouts`) and configurations (`config/cas.yml`, `config/database.yml`)
* Deploy it using capistrano, git, Jenkins, ...
* Load the default DB schema: `DATABASE_ENV=production rake casino_core:db:schema:load` (after an update: run `DATABASE_ENV=production rake casino_core:db:migrate` instead)
* Configure a cronjob to do a `DATABASE_ENV=production rake casino_core:cleanup:all > /dev/null` every 5 minutes

## Authenticators

Work in progress... See `CASinoCore::Authenticator::Static` if you would like to implement an authenticator

## Contributing to CASino

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.

## Copyright

Copyright (c) 2012 Nils Caspar. See LICENSE.txt for further details.
