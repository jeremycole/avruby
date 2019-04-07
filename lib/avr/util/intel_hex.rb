class IntelHex
  RECORD_TYPES = [
    :data,
    :eof,
    :esa,
    :ssa,
    :ela,
    :sla,
  ]
  
  def initialize(filename)
    @filename = filename
    @file = File.open(filename, "r")
    @address = 0
    @esa = 0
    @ssa = 0
    @ela = 0
    @sla = 0
  end

  def parse_record(line)
    length = line[1..2].to_i(16)
    data_end = (9 + length*2)
    {
      length: length,
      address: line[3..6].to_i(16),
      type: RECORD_TYPES[line[7..8].to_i(16)],
      data: line[9...data_end].split("").each_slice(2).map { |a| a.join.to_i(16) },
      checksum: line[data_end..(data_end + 2)].to_i
    }
  end

  def each_record
    return Enumerator.new(self, :each_record) unless block_given?

    begin
      @file.each_line do |line|
        raise "Mis-formatted file" unless line[0] == ":" and line.size >= (1 + 2 + 4 + 2)
        yield parse_record(line.chomp)
      end
    rescue EOFError
      return nil
    end
  end

  def each_byte
    return Enumerator.new(self, :each_byte) unless block_given?

    each_record do |record|
      case record[:type]
      when :data
        record[:data].each_with_index do |byte, i|
          yield record[:address] + i, byte
        end
      end
    end
  end
end