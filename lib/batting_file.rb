require 'csv'

class BattingFile
  attr_accessor :data, :years

  def initialize(file=nil)
    @data = IO.read(file) if file
  end

  def read
    @years ||= YearCollection.new CSV.parse(@data, headers: true).map{|year| Year.new(year) }
  end

  def self.load(data)
    new.tap do |file|
      file.data = data
      file.read
    end
  end
end
