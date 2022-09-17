# linear-regression

**LinearRegression** for [Crystal](https://crystal-lang.org/) computes a linear least squares regression line (linear correlation).

The computation is performed in linear time, proportional to the length of the input data.

**LinearRegression** is currently used in production on [Total Real Returns](https://totalrealreturns.com/).

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  linear-regression:
    github: compumike/linear-regression
```

2. Run `shards install`

## Usage

```crystal
require "linear-regression"

linreg = LinearRegression.new([-1.0, 0.0, 1.0], [4.0, 4.0, 5.0])

# Examine properties of the fit:
linreg.slope                # 0.5
linreg.intercept            # 4.33333333
linreg.pearson_r            # 0.8660254038
linreg.pearson_r_squared    # 0.75

# Evaluate the regression line at a given x coordinate:
linreg.at(0.0)              # 4.33333333
linreg.at(10.0)             # 9.33333333

# Serialize and deserialize the fit: (does not serialize raw data points)
j = linreg.to_json          # '{"n":3,...}'
linreg2 = LinearRegression.from_json(j)
linreg2.slope               # 0.5
```

## Development

Run `./d_dev` to bring up a docker container for development, where you can easily run:

```shell
make spec     # to run unit tests
```

## Author

- [compumike](https://github.com/compumike) - creator and maintainer
