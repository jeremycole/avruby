# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/intel_hex/all/intel_hex.rbi
#
# intel_hex-0.5.3

module IntelHex
end
class IntelHex::MisformattedFileError < RuntimeError
end
class IntelHex::ValidationError < StandardError
end
class IntelHex::InvalidTypeError < IntelHex::ValidationError
end
class IntelHex::InvalidLengthError < IntelHex::ValidationError
end
class IntelHex::InvalidOffsetError < IntelHex::ValidationError
end
class IntelHex::InvalidDataError < IntelHex::ValidationError
end
class IntelHex::InvalidChecksumError < IntelHex::ValidationError
end
class IntelHex::Record
  def calculate_checksum; end
  def checksum; end
  def data; end
  def data=(value); end
  def data_s; end
  def data_to_uint16(offset = nil); end
  def data_to_uint32(offset = nil); end
  def each_byte_with_address; end
  def ela(offset = nil); end
  def ela=(value, offset = nil); end
  def esa(offset = nil); end
  def esa=(value, offset = nil); end
  def initialize(type, length = nil, offset = nil, data = nil, checksum = nil, line: nil, validate: nil); end
  def length; end
  def line; end
  def offset; end
  def recalculate_checksum; end
  def self.data(data); end
  def self.ela(value); end
  def self.eof; end
  def self.esa(value); end
  def self.parse(line); end
  def self.sla(value); end
  def self.ssa(value); end
  def self.type_with_value(type, value); end
  def sla(offset = nil); end
  def sla=(value, offset = nil); end
  def ssa(offset = nil); end
  def ssa=(value, offset = nil); end
  def to_ascii; end
  def to_s; end
  def type; end
  def uint16_to_data(value, offset = nil); end
  def uint32_to_data(value, offset = nil); end
  def valid?; end
  def validate; end
  def validate_checksum; end
  def validate_data; end
  def validate_length; end
  def validate_offset; end
  def validate_type; end
  def value_s; end
end
class IntelHex::FileReader
  def each_byte_with_address; end
  def each_record; end
  def initialize(filename); end
end
