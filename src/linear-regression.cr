require "json"

# A LinearRegression instance represents the immutable result of a least-squares linear regression.
#
# Call `LinearRegression.new(xs, ys)` with your equal-sized arrays of Float64s to find a fit.
#
# On your instance, call `.at(x)` to evaluate the regression line at `x`, or call `.slope`, `.intercept`, `.pearson_r`, `.pearson_r_squared` for metrics about the fit.
#
# The LinearRegression may be serialized `.to_json` and deserialized `#from_json`. (The serialized state does not store the raw data points that were used to find the regression line.)
class LinearRegression
  include JSON::Serializable

  class ZeroXVarianceException < Exception; end

  @[JSON::Field]
  getter n : Int32

  @[JSON::Field]
  getter mean_x : Float64

  @[JSON::Field]
  getter mean_y : Float64

  @[JSON::Field]
  getter var_x : Float64

  @[JSON::Field]
  getter var_y : Float64

  @[JSON::Field]
  getter stdev_x : Float64

  @[JSON::Field]
  getter stdev_y : Float64

  @[JSON::Field]
  getter cov_xy : Float64

  @[JSON::Field]
  getter slope : Float64

  @[JSON::Field]
  getter intercept : Float64

  @[JSON::Field]
  getter pearson_r : Float64

  @[JSON::Field]
  getter pearson_r_squared : Float64

  # Computes the regression given input data, where (xs[0], ys[0]) represents a single data point.
  #
  # The computation happens in linear time, proportional to O(xs.size).
  #
  # Raises an IndexError unless these input conditions are met: xs and ys must be the same length, and must have at least two elements.
  #
  # Raises an `ZeroXVarianceException` if the xs values are all the same.
  def initialize(xs : Array(Float64), ys : Array(Float64))
    raise IndexError.new("Array size mismatch") unless xs.size == ys.size
    @n = xs.size

    raise IndexError.new("Not enough elements") unless @n >= 2

    # Compute sums over data
    sum_x = 0.0
    sum_y = 0.0
    sum_xx = 0.0
    sum_yy = 0.0
    sum_xy = 0.0
    @n.times do |i|
      xi = xs[i]
      yi = ys[i]
      sum_x += xi
      sum_y += yi
      sum_xx += xi**2
      sum_yy += yi**2
      sum_xy += xi*yi
    end

    # Means and Expectations:
    @mean_x = sum_x / @n # E[X]
    @mean_y = sum_y / @n # E[Y]
    e_xx = sum_xx / @n # E[X^2]
    e_yy = sum_yy / @n # E[Y^2]
    e_xy = sum_xy / @n # E[X*Y]

    # Variances:
    #   var(X) = E[(X - E[X])^2]
    #          = E[X^2 -2*X*E[X] + (E[X])^2]
    #          = E[X^2] -2*E[X]*E[X] + (E[X])^2
    #          = E[X^2] - (E[X])^2
    @var_x = e_xx - (@mean_x**2)
    @var_y = e_yy - (@mean_y**2)
    raise ZeroXVarianceException.new("Must have unique X values") if @var_x == 0.0
    @stdev_x = Math.sqrt(@var_x)
    @stdev_y = Math.sqrt(@var_y)

    # Covariance:
    #   cov(X,Y) = E[(X-E[X])*(Y-E[Y])]
    #            = E[X*Y - X*E[Y] - Y*E[X] + E[X]E[Y]]
    #            = E[X*Y] - E[X]*E[Y] - E[Y]*E[X] + E[X]E[Y]
    #            = E[X*Y] - E[X]*E[Y]
    @cov_xy = e_xy - (@mean_x * @mean_y)

    # Pearson R:
    #   r = cov(X,Y) / (stdev(X) * stdev(Y))
    if stdev_y == 0.0
      # All Y values are equal, so there is zero correlation with X
      @pearson_r = 0.0
    else
      @pearson_r = @cov_xy / (stdev_x * stdev_y)
    end
    @pearson_r_squared = @pearson_r ** 2

    # Slope:
    #   slope = r * (stdev(Y) / stdev(X))
    #         = cov(X,Y) / var(X)
    @slope = @cov_xy / @var_x

    # Intercept:
    #   int = mean_y - slope*mean_x
    @intercept = @mean_y - (@slope * @mean_x)
  end

  # Evaluate the regression line at a given x value.
  def at(x : Float64) : Float64
    @intercept + (@slope * x)
  end
end
