require "./spec_helper"
require "../src/cronus/date_range"

describe Cronus::DateRange do
  it "can be initialized using yyyy, mm, dd" do
    dr = Cronus::DateRange.new(2011, 1, 16, 2011, 2, 24)
    dr.to_s.should eq("(2011-01-16..2011-02-24)")
  end
end
