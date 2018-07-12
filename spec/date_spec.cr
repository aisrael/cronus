require "./spec_helper"
require "json"

struct StructUsingCronus::Date
  JSON.mapping(
    from: {type: Cronus::Date, converter: Cronus::Date::ISO8601}
  )

  def initialize(@from : Cronus::Date)
  end
end

struct StructUsingCronus::DateNoConverter
  JSON.mapping(
    from: {type: Cronus::Date}
  )

  def initialize(@from : Cronus::Date)
  end
end

describe Cronus::Date do
  it "can be initialized" do
    date = Cronus::Date.new(2011, 1, 16)
    date.to_s.should eq("2011-01-16")
  end
  it "throws an exception for invalid dates" do
    expect_raises(ArgumentError) do
      Cronus::Date.new(-1, 1, 16)
    end.message.should eq("Year must be a positive integer (-1)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(0, 1, 16)
    end.message.should eq("Year must be a positive integer (0)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(2000, 0, 16)
    end.message.should eq("Month must be within 1..12 (0)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(2000, 13, 16)
    end.message.should eq("Month must be within 1..12 (13)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(2000, 2, 0)
    end.message.should eq("Day must be within 1..29 (2000, 2, 0)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(2000, 2, 30)
    end.message.should eq("Day must be within 1..29 (2000, 2, 30)")
    expect_raises(ArgumentError) do
      Cronus::Date.new(1999, 2, 29)
    end.message.should eq("Day must be within 1..28 (1999, 2, 29)")
  end
  it "can be compared to another Cronus::Date" do
    a = Cronus::Date.new(2000, 1, 1)
    b = Cronus::Date.new(2000, 1, 2)
    c = Cronus::Date.new(2000, 2, 1)
    d = Cronus::Date.new(2001, 1, 1)
    (a == a).should be_true
    (b == b).should be_true
    (c == c).should be_true
    (d == d).should be_true
    (a < b).should be_true
    (a < c).should be_true
    (a < d).should be_true
    (b < c).should be_true
    (b < d).should be_true
    (c < d).should be_true
    (d > a).should be_true
    (d > b).should be_true
    (d > c).should be_true
    (c > a).should be_true
    (c > a).should be_true
    (b > a).should be_true
    [b, d, a, c].sort.should eq([a, b, c, d])
  end
  describe ".leap_year?" do
    it "returns true if the given year is a leap year" do
      Cronus::Date.leap_year?(2000).should be_true
      Cronus::Date.leap_year?(1999).should be_false
      Cronus::Date.leap_year?(2004).should be_true
      Cronus::Date.leap_year?(1900).should be_false
    end
  end
  describe "#iso8601" do
    it "returns the date as in ISO 8601 format" do
      date = Cronus::Date.new(2011, 1, 16)
      date.iso8601.should eq("2011-01-16")
    end
  end
  describe ".parse" do
    it "works" do
      date = Cronus::Date.parse("2011-01-16")
      date.year.should eq(2011)
      date.month.should eq(Cronus::Date::Month::January)
      date.day.should eq(16)
    end
    it "raise ArgumentError on invalid dates" do
      expect_raises(ArgumentError) do
        Cronus::Date.parse("999-01-01")
      end.message.should eq(%("999-01-01" does not follow ISO 8601 YYYY-MM-DD format!))
      expect_raises(ArgumentError) do
        Cronus::Date.parse("1999-00-01")
      end.message.should eq(%("1999-00-01" does not follow ISO 8601 YYYY-MM-DD format!))
      expect_raises(ArgumentError) do
        Cronus::Date.parse("1999-13-01")
      end.message.should eq(%("1999-13-01" does not follow ISO 8601 YYYY-MM-DD format!))
      expect_raises(ArgumentError) do
        Cronus::Date.parse("1999-01-00")
      end.message.should eq(%("1999-01-00" does not follow ISO 8601 YYYY-MM-DD format!))
      expect_raises(ArgumentError) do
        Cronus::Date.parse("1999-01-32")
      end.message.should eq(%("1999-01-32" does not follow ISO 8601 YYYY-MM-DD format!))
    end
  end
  describe "#from_json()" do
    it "works with a converter" do
      json_string = <<-JSON
      {
        "from": "2018-06-01"
      }
      JSON
      sud = StructUsingCronus::Date.from_json(json_string)
      sud.from.should eq(Cronus::Date.new(2018, 6, 1))
    end
    it "works without a converter" do
      json_string = <<-JSON
      {
        "from": "2018-06-01"
      }
      JSON
      sud = StructUsingCronus::DateNoConverter.from_json(json_string)
      sud.from.should eq(Cronus::Date.new(2018, 6, 1))
    end
  end
  describe "#to_json()" do
    it "works" do
      sud = StructUsingCronus::Date.new(from: Cronus::Date.new(2018, 6, 1))
      sud.to_json.should eq(%({"from":"2018-06-01"}))
    end
    it "works without converter" do
      sud = StructUsingCronus::DateNoConverter.new(from: Cronus::Date.new(2018, 6, 1))
      sud.to_json.should eq(%({"from":"2018-06-01"}))
    end
  end
end
