require "json"
require "./date"

# A really, really simple DateRange composed of a start and end `Date`
struct Cronus::DateRange
  getter :start_date, :end_date

  # DateRange.new(start_date, end_date)
  def initialize(@start_date : Date, @end_date : Date)
  end

  JSON.mapping(
    start_date: {key: "startDate", type: Date},
    end_date: {key: "endDate", type: Date}
  )

  # DateRange.new(2011, 1, 16, 2011, 2, 24)
  def initialize(start_year : Int, start_month : Int, start_day : Int, end_year : Int, end_month : Int, end_day : Int)
    initialize(Date.new(start_year, start_month, start_day), Date.new(end_year, end_month, end_day))
  end

  def inspect(io : IO)
    io << "(#{start_date}..#{end_date})"
  end

  def to_s(io : IO)
    io << "("
    io << start_date
    io << ".."
    io << end_date
    io << ")"
  end
end
