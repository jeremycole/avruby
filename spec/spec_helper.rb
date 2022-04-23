# typed: ignore
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "avr"

RSpec.configure do |config|
  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching(:focus)
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = "doc" if config.files_to_run.one?

  config.filter_run_excluding(opcode_decoder: :all)

  # config.profile_examples = 10
  config.order = :random

  Kernel.srand(config.seed)
end

def mix_dr(d, r = 0)
  (r & 0b1111) | ((d & 0b11111) << 4) | ((r & 0b10000) << 5)
end

def opcode_for_all_rd(opcode_base, mnemonic, before: nil, after: nil)
  (0..31).to_h do |d|
    [
      opcode_base | mix_dr(d),
      "#{mnemonic} " + [before, "r#{d}", after].flatten.compact.join(", "),
    ]
  end
end

def opcode_for_all_high_rd(opcode_base, mnemonic, before: nil, after: nil)
  (16..31).to_h do |d|
    [
      opcode_base | mix_dr(d - 16),
      "#{mnemonic} " + [before, "r#{d}", after].flatten.compact.join(", "),
    ]
  end
end

def opcode_for_all_word_registers(opcode_base, mnemonic, before: nil, after: nil)
  # rubocop:disable Style/MapToHash
  (0..3).map { |n| [n, 24 + (n * 2)] }.map { |n, l| [n, l + 1, l] }.to_h do |n, h, l|
    [
      opcode_base | (n << 4),
      "#{mnemonic} " + [before, "r#{h}:r#{l}", after].flatten.compact.join(", "),
    ]
  end
  # rubocop:enable Style/MapToHash
end

def word_registers(min: 0, max: 31)
  (min..max).select(&:even?).map { |n| [n + 1, n] }
end

def opcode_for_all_word_register_pairs(opcode_base, mnemonic, min: 0, max: 31, before: nil, after: nil)
  wr = word_registers(min: min, max: max)
  wr.product(wr).to_h do |(dh, dl), (rh, rl)|
    [
      opcode_base | mix_dr(dl >> 1, rl >> 1),
      "#{mnemonic} " + [before, "r#{dh}:r#{dl}, r#{rh}:r#{rl}", after].flatten.compact.join(", "),
    ]
  end
end

def opcode_for_all_rd_rr_pairs(opcode_base, mnemonic, min: 0, max: 31, alternate: nil)
  (min..max).to_a.product((min..max).to_a).to_h do |d, r|
    if alternate && d == r
      [opcode_base | mix_dr(d - min, r - min), "#{alternate} r#{r}"]
    else
      [opcode_base | mix_dr(d - min, r - min), "#{mnemonic} r#{d}, r#{r}"]
    end
  end
end

def opcode_for_all_sreg_flags(opcode_base, mnemonic, before: nil, after: nil)
  AVR::SREG::STATUS_BITS.each_with_index.to_h do |name, i|
    [
      opcode_base | (i << 4),
      "#{mnemonic} " + [before, "SREG.#{name}", after].flatten.compact.join(", "),
    ]
  end
end
