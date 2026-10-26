# typed: strict
# frozen_string_literal: true

module AVR
  class Memory
    class Fuses < MemoryByteBacked
      extend T::Sig

      DEFAULT_VALUE = 0xff

      sig { returns(Device) }
      attr_reader :device

      sig { returns(RegisterFile) }
      attr_reader :registers

      sig { returns(T::Array[Symbol]) }
      def bit_names
        @bit_names ||= T.let(device.fuse_bit_names_map.values.flatten.compact, T.nilable(T::Array[Symbol]))
      end

      sig { returns(T::Hash[Symbol, Integer]) }
      def bits
        @bits ||= T.let(registers.registers.values.flat_map(&:bits).reduce({}) do |x, h|
          x.merge(h)
        end, T.nilable(T::Hash[Symbol, Integer]))
      end

      sig { returns(T::Hash[Symbol, T::Boolean]) }
      def booleans
        @booleans ||= bits.to_h { |name, value| [name, value == 1] }
      end

      sig { params(name: Symbol).returns(T.nilable(T::Boolean)) }
      def programmed?(name)
        # Programmed fuses are set to 0.
        !booleans[name]
      end

      sig { params(name: Symbol).returns(T.nilable(T::Boolean)) }
      def unprogrammed?(name)
        # Programmed fuses are set to 1.
        booleans[name]
      end

      sig { returns(T::Hash[Symbol, Integer]) }
      def composites
        @composites ||= T.let(multi_bit_fuse_definitions.to_h do |prefix, bit_names|
          [prefix, bit_names.map { |i, bit| T.must(@device.fuses.bits[bit]) << i }.sum]
        end, T.nilable(T::Hash[Symbol, Integer]))
      end

      sig { params(device: Device).void }
      def initialize(device)
        super("Fuses", device.fuse_size, DEFAULT_VALUE)
        @device = device
        @registers = T.let(RegisterFile.new(device.cpu), AVR::RegisterFile)

        device.fuse_memory_map.each_key do |name|
          @registers.add(register(name))
        end

        reset_to_defaults
      end

      sig { void }
      def reset_memoized_values
        @bits = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))
        @booleans = T.let(nil, T.nilable(T::Hash[Symbol, T::Boolean]))
        @composites = T.let(nil, T.nilable(T::Hash[Symbol, Integer]))

        nil
      end

      sig { params(values: T::Array[Integer]).returns(NilClass) }
      def set(values)
        values.each_with_index do |value, index|
          T.must(memory[index]).value = value
        end

        reset_memoized_values

        nil
      end

      sig { void }
      def reset_to_defaults
        set(device.fuse_default_values.values)
      end

      sig { void }
      def print_status
        registers.print_status
      end

      sig { returns(String) }
      def inspect
        "#<#{self.class.name} #{registers.register_values}>"
      end

      private

      sig { returns(T::Hash[Symbol, T::Hash[Integer, Symbol]]) }
      def multi_bit_fuse_definitions
        multi_bit_fuses = {}

        bit_names.each do |bit_name|
          next unless (match = bit_name.to_s.match(/\A(.+?)(\d+)\z/))

          prefix = T.must(match[1]).to_sym
          index = match[2].to_i
          multi_bit_fuses[prefix] ||= {}
          multi_bit_fuses[prefix][index] = bit_name
        end

        multi_bit_fuses.select { |_k, v| v.include?(0) }
      end

      sig { params(name: Symbol).returns(MemoryByteRegister) }
      def register(name)
        if T.must(device.fuse_bit_names_map[name]).any?
          MemoryByteRegisterWithNamedBits.new(device.cpu, name.to_s, memory[T.must(device.fuse_memory_map[name])],
            device.fuse_bit_names_map[name])
        else
          MemoryByteRegister.new(device.cpu, name.to_s, T.must(memory[T.must(device.fuse_memory_map[name])]))
        end
      end
    end
  end
end
