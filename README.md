# Sudo Sandwich is an example Heroku Add-on

Example Heroku add-on built with Rails for the Add-on Partner API v3.

Following instructions found at
https://devcenter.heroku.com/articles/building-an-add-on.

## Set up

### macOS

Install [Homebrew].

Install [Heroku CLI].

```
brew install heroku/brew/heroku
```

Install and start PostgreSQL.

```
brew install postgresql
brew services start postgresql
```

[Homebrew]: https://brew.sh/
[Heroku CLI]: https://devcenter.heroku.com/articles/heroku-cli

### Ruby on Rails

This application is built using [Ruby on Rails].

Your system will require [Ruby] to develop on the application.

The required Ruby version is listed in the [.ruby-version](.ruby-version) file.

If you do not have this binary, [use this guide to get set up on MacOS].

[Ruby on Rails]: http://rubyonrails.org
[Ruby]: https://www.ruby-lang.org/en/
[use this guide to get set up on MacOS]: http://installfest.railsbridge.org/installfest/macintosh

### Configuring the Application

After cloning this repo, run: `bin/setup`.

## Day-to-day Development

### Local Server

* Run the server(s): `bin/rails start`
* Visit [your local server](http://localhost:3000)
* Run tests: `rake`
