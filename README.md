# Roman Numerals in Ruby

## Tests

```sh
bundle exec rake test
```

```sh
bundle exec rake test TEST=tests/roman_test.rb
```

```sh
bundle exec rake test TEST=tests/roman_test.rb TESTOPTS="--name=/test_large_values.*/ -v"
```

## Documentation

### Public

```sh
bundle exec rake doc
```

```sh
bundle exec yard doc
```

### Internal

```sh
bundle exec yard doc --yardopts=.yardopts_dev
```
