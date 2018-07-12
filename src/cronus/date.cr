# A really, really simple Gregorian Date
struct Cronus::Date
  include Comparable(Date)

  enum Month
    January   =  1
    February  =  2
    March     =  3
    April     =  4
    May       =  5
    June      =  6
    July      =  7
    August    =  8
    September =  9
    October   = 10
    November  = 11
    December  = 12
  end
  DAYS_OF_THE_MONTH = {
    Month::January   => 31,
    Month::February  => 28,
    Month::March     => 31,
    Month::April     => 30,
    Month::May       => 31,
    Month::June      => 30,
    Month::July      => 31,
    Month::August    => 31,
    Month::September => 30,
    Month::October   => 31,
    Month::November  => 30,
    Month::December  => 31,
  }

  def self.leap_year?(year : Int)
    year % 100 == 0 ? year % 400 == 0 : year % 4 == 0
  end

  @year : Int16
  @month : Month
  @day : Int8
  getter :year, :month, :day

  # Provide Object.from_json support. See https://github.com/crystal-lang/crystal/blob/master/src/json/from_json.cr
  def initialize(parser : JSON::PullParser)
    s = parser.read_string
    raise ArgumentError.new(%("#{s}" does not follow ISO 8601 YYYY-MM-DD format!)) unless s =~ /^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/
    yyyy, mm, dd = s.split("-").map(&.to_i32)
    initialize(yyyy, mm, dd)
  end

  # Date.new(2011, 1, 16)
  def initialize(year : Int, month : Int, day : Int)
    raise ArgumentError.new("Year must be a positive integer (#{year})") unless year > 0
    raise ArgumentError.new("Month must be within 1..12 (#{month})") unless (1..12).includes?(month)
    mm = Month.new(month)
    days_of_month = if month == 2
                      Date.leap_year?(year) ? 29 : 28
                    else
                      DAYS_OF_THE_MONTH[mm]
                    end
    raise ArgumentError.new("Day must be within 1..#{days_of_month} (#{year}, #{month}, #{day})") unless (1..days_of_month).includes?(day)
    @year = year.to_i16
    @month = mm
    @day = day.to_i8
  end

  # Parses an ISO 8601 date string of the format: YYYY-MM-DD
  def self.parse(s : String)
    raise ArgumentError.new(%("#{s}" does not follow ISO 8601 YYYY-MM-DD format!)) unless s =~ /^\d{4}\-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01])$/
    yyyy, mm, dd = s.split("-").map(&.to_i32)
    Date.new(yyyy, mm, dd)
  end

  def iso8601 : String
    sprintf("%04d-%02d-%02d", @year, @month, @day)
  end

  def <=>(other : Date)
    return @year <=> other.year unless @year == other.year
    @month == other.month ? @day <=> other.day : @month <=> other.month
  end

  def inspect(io : IO)
    io << "Date(#{@year}, #{@month}, #{@day})"
  end

  def to_s(io : IO)
    io << iso8601
  end

  module ISO8601
    def self.from_json(pull : JSON::PullParser) : Date
      Date.parse(pull.read_string)
    end

    def self.to_json(value : Date, builder : JSON::Builder)
      value.to_json(builder)
    end
  end

  def self.from_json(pull : JSON::PullParser)
    Date.parse(pull.read_string)
  end

  def to_json(builder : JSON::Builder)
    builder.string(iso8601)
  end
end
