# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./forwardingUnit.sv"
vlog "./IFID.sv"
vlog "./IDEX.sv"
vlog "./EXMEM.sv"
vlog "./MEMWR.sv"
vlog "./paramDFF.sv"
vlog "./addAddresses.sv"
vlog "./alu.sv"
vlog "./aluBitSlice.sv"
vlog "./cpu.sv"
vlog "./D_FF.sv"
vlog "./datamem.sv"
vlog "./dataPath.sv"
vlog "./decoder.sv"
vlog "./fullAdder.sv"
vlog "./instructfetch.sv"
vlog "./instructmem.sv"
vlog "./isZero.sv"
vlog "./mux2_1.sv"
vlog "./mux3_1.sv"
vlog "./mux4_1.sv"
vlog "./mux5x2_1.sv"
vlog "./mux8_1.sv"
vlog "./mux16_1.sv"
vlog "./mux32_1.sv"
vlog "./mux64_1.sv"
vlog "./mux64x2_1.sv"
vlog "./mux64x3_1.sv"
vlog "./mux64x4_1.sv"
vlog "./pc.sv"
vlog "./regfile.sv"
vlog "./register.sv"
vlog "./setFlag.sv"
vlog "./shifter.sv"
vlog "./signExtend.sv"
vlog "./mux2x3_1.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work cpu_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do cpu_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
