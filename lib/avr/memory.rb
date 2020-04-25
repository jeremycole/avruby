# frozen_string_literal: true

require 'avr/memory/memory_byte'
require 'intel_hex'

module AVR
  class Memory
    class Watch
      def initialize(proc = nil, &block)
        @watch_proc = proc || block.to_proc
      end

      def notify(memory_byte, old_value, new_value)
        @watch_proc.call(memory_byte, old_value, new_value)
      end
    end

    attr_reader :cpu
    attr_reader :name
    attr_reader :size
    attr_reader :memory
    attr_reader :watches

    def initialize(name, size, value = 0)
      @name = name
      @size = size
      @memory = size.times.map { |address| MemoryByte.new(self, address, value) }
      @watches = []
    end

    def inspect
      "#<#{self.class.name} size=#{size}>"
    end

    def reset
      memory.each do |byte|
        byte.value = 0
      end
    end

    def notify(memory_byte, old_value, new_value)
      watches.each do |watch|
        if watch[:filter] == true || watch[:filter].include?(memory_byte.address)
          watch[:watch].notify(memory_byte, old_value, new_value)
        end
      end
    end

    def unshift_watch(filter, watch)
      watches.unshift({ filter: filter, watch: watch })
    end

    def push_watch(filter, watch)
      watches.push({ filter: filter, watch: watch })
    end

    def watch(filter = true, &block)
      watch = Watch.new(block.to_proc)
      push_watch(filter.is_a?(Integer) ? [filter] : filter, watch)
      watch
    end

    def word(address)
      byte_address = address << 1
      (memory[byte_address + 1].value << 8) | memory[byte_address].value
    end

    def set_word(address, value)
      byte_address = address << 1
      memory[byte_address + 1].value = (value & 0xff00) >> 8
      memory[byte_address].value = value & 0x00ff
    end

    def load_from_intel_hex(filename)
      ihex = IntelHex::FileReader.new(filename)
      sum = 0
      ihex.each_byte_with_address do |byte, address|
        memory[address].value = byte
        sum += 1
      end
      sum
    end
  end
end

require 'avr/memory/sram'
require 'avr/memory/eeprom'
require 'avr/memory/flash'
