require "./spec_helper"

require "../src/linear-regression"

describe LinearRegression do
  it "throws exceptions when arrays are mismatched or too small" do
    empty = Array(Float64).new
    one_elem = Array(Float64).new
    one_elem << 6.324
    two_elem = Array(Float64).new
    two_elem << 6.324
    two_elem << 1.22

    expect_raises(IndexError) { LinearRegression.new(empty, empty) }
    expect_raises(IndexError) { LinearRegression.new(empty, one_elem) }
    expect_raises(IndexError) { LinearRegression.new(one_elem, empty) }
    expect_raises(IndexError) { LinearRegression.new(one_elem, one_elem) }
    expect_raises(IndexError) { LinearRegression.new(two_elem, one_elem) }
    expect_raises(IndexError) { LinearRegression.new(one_elem, two_elem) }
  end

  it "throws exception when x points are the same" do
    expect_raises(LinearRegression::ZeroXVarianceException) {
      LinearRegression.new([5.0, 5.0], [10.0, 15.0])
    }
  end

  it "works for two simple points, positive slope" do
    linreg = LinearRegression.new([-10.0, 10.0], [-30.0, 30.0])
    linreg.pearson_r.should eq(1)
    linreg.pearson_r_squared.should eq(1)
    linreg.slope.should eq(3)
    linreg.intercept.should eq(0)
    linreg.at(0).should eq(0)
    linreg.at(-1).should eq(-3)
    linreg.at(1).should eq(3)
  end

  it "works for two simple points, negative slope" do
    linreg = LinearRegression.new([-10.0, 10.0], [30.0, -30.0])
    linreg.pearson_r.should eq(-1)
    linreg.pearson_r_squared.should eq(1)
    linreg.slope.should eq(-3)
    linreg.intercept.should eq(0)
    linreg.at(0).should eq(0)
    linreg.at(-1).should eq(3)
    linreg.at(1).should eq(-3)
  end

  it "works for two simple points, zero slope" do
    linreg = LinearRegression.new([-10.0, 10.0], [30.0, 30.0])
    linreg.pearson_r.should eq(0)
    linreg.pearson_r_squared.should eq(0)
    linreg.slope.should eq(0)
    linreg.intercept.should eq(30)
    linreg.at(0).should eq(30)
    linreg.at(-1).should eq(30)
    linreg.at(1).should eq(30)
  end

  it "works for three points" do
    linreg = LinearRegression.new([-1.0, 0.0, 1.0], [4.0, 4.0, 5.0])
    linreg.pearson_r.should be_close(0.8660254038, 0.001)
    linreg.pearson_r_squared.should be_close(0.75, 0.001)
    linreg.slope.should be_close(0.5, 0.001)
    linreg.intercept.should be_close(4.33333333, 0.001)
    linreg.at(0).should be_close(4.33333333, 0.001)
    linreg.at(10).should be_close(9.33333333, 0.001)
  end

  it "works for 10 points" do
    linreg = LinearRegression.new([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0], [9.0, 1.0, 0.0, 5.0, 4.0, 7.0, 7.0, 0.0, 9.0, 3.0])
    linreg.pearson_r.should be_close(0.05813274708, 1e-6)
    linreg.slope.should be_close(0.066666667, 0.001)
    linreg.intercept.should be_close(4.13333333, 0.001)
  end

  it "serialies to_json" do
    linreg = LinearRegression.new([-10.0, 10.0], [-30.0, 30.0])
    json = linreg.to_json

    json.should eq("{\"n\":2,\"mean_x\":0.0,\"mean_y\":0.0,\"var_x\":100.0,\"var_y\":900.0,\"stdev_x\":10.0,\"stdev_y\":30.0,\"cov_xy\":300.0,\"slope\":3.0,\"intercept\":0.0,\"pearson_r\":1.0,\"pearson_r_squared\":1.0}")
  end

  it "deserializes from_json" do
    linreg = LinearRegression.from_json("{\"n\":2,\"mean_x\":0.0,\"mean_y\":0.0,\"var_x\":100.0,\"var_y\":900.0,\"stdev_x\":10.0,\"stdev_y\":30.0,\"cov_xy\":300.0,\"slope\":3.0,\"intercept\":0.0,\"pearson_r\":1.0,\"pearson_r_squared\":1.0}")

    linreg.n.should eq(2)
    linreg.mean_x.should eq(0)
    linreg.mean_y.should eq(0)
    linreg.var_x.should eq(100.0)
    linreg.var_y.should eq(900.0)
    linreg.stdev_x.should eq(10.0)
    linreg.stdev_y.should eq(30.0)
    linreg.cov_xy.should eq(300.0)
    linreg.slope.should eq(3.0)
    linreg.intercept.should eq(0.0)
    linreg.pearson_r.should eq(1.0)
    linreg.pearson_r_squared.should eq(1.0)

    linreg.at(0.0).should eq(0.0)
    linreg.at(1.0).should eq(3.0)
  end
end
