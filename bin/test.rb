cpu = AVR::CPU.new(2048, 32768, 512)
cpu.flash.load_from_intel_hex("/Users/jeremycole/git/asmvr/blink.hex")
cpu.step
