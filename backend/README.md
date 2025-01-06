# Cookbook AI - API

## Tech stack

- [Ruby 3.3.6](https://www.ruby-lang.org/en/)
- [Grape](https://github.com/ruby-grape/grape)

## Development

- Install dependencies

```
bundle install
```

- Setup ENV variables from root of the project (../.env.sample).

- Run app

```
bundle exec rackup
```

- Test if it's responding

```
curl "http://localhost:9292/api/v1/ping"
```
