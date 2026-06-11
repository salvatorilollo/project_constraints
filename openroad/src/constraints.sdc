# Copyright 2024 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# Backend constraints

############
## Global ##
############

source src/instances.tcl

# Not set in the liberty file of the EZ cells; limiting fanout often reduced routing stress
set_max_fanout 16 [current_design]


#############################
## Driving Cells and Loads ##
#############################

# As a default, drive multiple GPIO pads and be driven by one.
# accomodate for driving up to 2 74HC pads plus a 5pF trace
set_load [expr 2 * 5.0 + 5.0] [all_outputs]
set_driving_cell [all_inputs] -lib_cell sg13cmos5l_IOPadOut16mA -pin pad


##################
## Input Clocks ##
##################
puts "Clocks..."

# We target 100 MHz
set TCK_SYS 10.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 25.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports ref_clk_i]


##################################
## Clock Groups & Uncertainties ##
##################################

# Define which clocks are asynchronous to each other
# If you have added a clock it is a good idea to temporarily add -allow_paths.
# This means the paths between clocks (CDC) are timed and will show up as violations,
# making them very easy to find and write constraints for.
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys}

# We set reasonable uncertainties in their transistion timing
# and transition (rise/fall) times for all clocks (ns)
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


####################
## Cdcs and Syncs ##
####################
puts "CDC/Sync..."

# Clock Domain Crossings: paths going from an FF with one clock to an FF with another.
# The setup/hold checks on these paths are deactivated by set_clock_groups -asynchronous.
# An additional requirement is that the max delay is below min($TCK_SYS, $TCK_JTG) 
# to make sure any change propages within one cycle of either clock.
# An (optional) lower delay is better for metastability recovery -> 3ns as a reasonable goal

## Constrain `cdc_2phase` for DMI request
set_max_delay 3.0 -from $JTAG_ASYNC_REQ_START -to $JTAG_ASYNC_REQ_END -ignore_clock_latency

# Constrain `cdc_2phase` for DMI response
set_max_delay 3.0 -from $JTAG_ASYNC_RSP_START -to $JTAG_ASYNC_RSP_END -ignore_clock_latency


#############
## SoC Ins ##
#############
puts "Input/Outputs..."

# Reset should propagate to system domain within a clock cycle.
set_input_delay -max [ expr $TCK_JTG * 0.10 ] [get_ports {rst_ni testmode_i}]  
set_false_path -hold   -from [get_ports {rst_ni testmode_i}]
set_max_delay $TCK_SYS -from [get_ports {rst_ni testmode_i}]


##########
## JTAG ##
##########
puts "JTAG..."

set_input_delay  -min -add_delay -clock clk_jtg [ expr $TCK_JTG * 0.10 ] [get_ports {jtag_tdi_i jtag_tms_i}]
set_input_delay  -max -add_delay -clock clk_jtg [ expr $TCK_JTG * 0.30 ] [get_ports {jtag_tdi_i jtag_tms_i}]
set_output_delay -min -add_delay -clock clk_jtg [ expr $TCK_JTG * 0.10 ] [get_ports jtag_tdo_o]
set_output_delay -max -add_delay -clock clk_jtg [ expr $TCK_JTG * 0.20 ] [get_ports jtag_tdo_o]

# Reset should propagate to system domain within a clock cycle.
set_input_delay -max [ expr $TCK_JTG * 0.10 ] [get_ports jtag_trst_ni]  
set_false_path -hold    -from [get_ports jtag_trst_ni]
set_max_delay $TCK_JTG  -from [get_ports jtag_trst_ni]


##########
## GPIO ##
##########
puts "GPIO..."

set_input_delay  -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {gpio*}]
set_input_delay  -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.30 ] [get_ports {gpio*}]

set_output_delay -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {gpio*}]
set_output_delay -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.30 ] [get_ports {gpio*}]

# The timing of these signals are not important but we want to keep them in-cycle
#set_output_delay -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {status_o unused*}]
#set_output_delay -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {status_o unused*}]


##########
## UART ##
##########
puts "UART..."

set_input_delay  -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports uart_rx_i]
set_input_delay  -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.30 ] [get_ports uart_rx_i]
set_output_delay -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports uart_tx_o]
set_output_delay -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.30 ] [get_ports uart_tx_o]

##########
## HYPERBUS ##
##########

# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# This top has one functional clock, clk_sys_i.  The HyperBus PHY, AXI side,
# register side, command/address generation, and write datapath are synchronous
# to that clock.  The outgoing HyperBus CK is generated by delaying clk_sys_i by
# one quarter period.  The read datapath is source-synchronous: HyperRAM returns
# RWDS edge-aligned with DQ, and the PHY delays RWDS by one quarter period before
# capturing DQ.
#
# If this file is applied after wrapping the block in IO pads, map the port
# collections below to the pad data pins:
#   HYP_DQ_IN       -> pad outputs feeding hyper_dq_i[*][*]
#   HYP_RWDS_IN     -> pad outputs feeding hyper_rwds_i[*]
#   HYP_WRITE_OUT   -> pad data-input pins driven by hyper_dq_o[*][*]/hyper_rwds_o[*]
#   HYP_WRITE_OE    -> pad output-enable pins driven by hyper_dq_oe_o[*]/hyper_rwds_oe_o[*]
#   HYP_CK_OUT      -> CK pad data-input/output pin
#   HYP_CS_OUT      -> CS# pad data-input/output pins
#   HYP_RESET_OUT   -> RESET# pad data-input/output pins
#
# The instance patterns assume the RTL hierarchy under hyperbus_synchronous is
# preserved enough to find i_tx_clk_delay and each i_trx/i_delay_rx_rwds_90.  If
# synthesis renames or flattens these, update HYP_TX90_PIN and
# HYP_RX_SAMPLE_CLK to the corresponding delayed clock pins.

################
## Parameters ##
################

# HyperBus CK period.  The default below is 200 MHz, which matches the reset
# delay-line setting: t_tx_clk_delay == 16 taps, 16 * 78 ps ~= 1.25 ns == T/4.
# For this fully synchronous top, clk_sys_i and HyperBus CK use the same period.
set HYP_TCK 10.0

set HYP_HALF          [expr 0.50 * $HYP_TCK]
set HYP_QUARTER       [expr 0.25 * $HYP_TCK]
set HYP_THREE_QUARTER [expr 0.75 * $HYP_TCK]

# FPGA-/ASIC-centric interface margins.  HYP_READ_SKEW covers HyperRAM DQ-vs-RWDS
# skew plus PCB mismatch.  HYP_OUT_SKEW covers our CK-vs-DQ/RWDS output skew
# budget plus PCB mismatch.  Tighten these with board/device numbers if known.
set HYP_OUT_SKEW       0.55
set HYP_READ_SKEW      0.90
set HYP_CTRL_SKEW      0.55
set CLK_UNCERTAINTY    0.05

######################
## Port Collections ##
######################

# These wildcard filters intentionally match both packed-array names such as
# hyper_dq_i[0][7] and flattened names such as hyper_dq_i_0__7_.
set HYP_DQ_IN      [get_ports  -filter {direction==in  && name=~hyper_dq_i*}]
set HYP_RWDS_IN    [get_ports  -filter {direction==in  && name=~hyper_rwds_i*}]

set HYP_DQ_OUT     [get_ports  -filter {direction==out && name=~hyper_dq_o* && !(name=~hyper_dq_oe_o*)}]
set HYP_RWDS_OUT   [get_ports  -filter {direction==out && name=~hyper_rwds_o* && !(name=~hyper_rwds_oe_o*)}]
set HYP_WRITE_OUT  [get_ports  -filter {direction==out && ((name=~hyper_dq_o* && !(name=~hyper_dq_oe_o*)) || (name=~hyper_rwds_o* && !(name=~hyper_rwds_oe_o*)))}]
set HYP_WRITE_OE   [get_ports  -filter {direction==out && (name=~hyper_dq_oe_o* || name=~hyper_rwds_oe_o*)}]

set HYP_CK_OUT     [get_ports  -filter {direction==out && name=~hyper_ck_o*}]
set HYP_CKN_OUT    [get_ports  -filter {direction==out && name=~hyper_ck_no*}]
set HYP_CS_OUT     [get_ports  -filter {direction==out && name=~hyper_cs_no*}]
set HYP_RESET_OUT  [get_ports  -filter {direction==out && name=~hyper_reset_no*}]

###################
## Primary Clock ##
###################

#create_clock -name clk_sys -period $HYP_TCK [get_ports clk_i]

# TARGET_XILINX adds clk_ref200_i for IDELAY-style delay primitives.  It is not a
# second HyperBus protocol domain, but it should be declared if the port exists.
#set HYP_CLK_REF200 [get_ports  clk_ref200_i]
#if {[llength $HYP_CLK_REF200] > 0} {
#  create_clock -name clk_ref200 -period 5.0 $HYP_CLK_REF200
#}

# Functional timing assumes test-mode clock muxes are disabled.  In particular,
# hyperbus_trx can replace the gated RWDS read clock with clk_sys_i in test mode.
set_case_analysis 0 [get_ports testmode_i]
set_input_delay -clock clk_sys -max [expr 0.10 * $HYP_TCK] [get_ports testmode_i]
set_false_path -hold -from [get_ports testmode_i]

# rst_ni is asynchronous to the functional clock.  It feeds the external
# HyperBus reset output directly, so do not model it as a clocked data output.
set_input_delay -clock clk_sys -max [expr 0.10 * $HYP_TCK] [get_ports rst_ni]
set_false_path -hold -from [get_ports rst_ni]

#####################################
## Generated Outgoing HyperBus CK  ##
#####################################

# Match the output of hyperbus_tx_clk_delay.  This is clk_sys_i delayed by the
# configured tx delay and is used as the clock input to hyperbus_clock_diff_out.


set HYP_TX90_PIN [get_pins  {
  *i_tx_clk_delay/i_delay_tx_clk_90/out_o
}]


#if {[llength $HYP_TX90_PIN] > 0} {
#  create_generated_clock -name clk_hyp_tx_90 \
#    -source [get_ports clk_i] \
#    -master_clock clk_sys \
#    -divide_by 1 \
#    -edges {1 2 3} \
#    -edge_shift [list $HYP_QUARTER $HYP_QUARTER $HYP_QUARTER] \
#    $HYP_TX90_PIN
#} else {
#  puts "WARNING: HYP_TX90_PIN is empty; update it to the delayed TX clock pin."
#}

if {[llength $HYP_TX90_PIN] > 0} {
  create_generated_clock -name clk_hyp_tx_90 \
    -source [get_ports clk_i] \
    -master_clock clk_sys \
    -divide_by 1 \
    -divide_by 1 \
    $HYP_TX90_PIN
  set_clock_latency $HYP_QUARTER -source [get_clocks clk_hyp_tx_90]
} else {
  puts "WARNING: HYP_TX90_PIN is empty; update it to the delayed TX clock pin."
}

# The clock seen by the HyperRAM is the generated clock at hyper_ck_o.  Use this
# as the reference clock for source-synchronous output delays.  CK# is modeled for
# completeness but is not used as a data-delay reference.
if {[llength $HYP_CK_OUT] > 0 && [llength [get_clocks  clk_hyp_tx_90]] > 0} {
  create_generated_clock -name clk_hyp_ck_out \
    -source $HYP_TX90_PIN \
    -divide_by 1 \
    $HYP_CK_OUT
}

if {[llength $HYP_CKN_OUT] > 0 && [llength [get_clocks  clk_hyp_tx_90]] > 0} {
  create_generated_clock -name clk_hyp_ckn_out \
    -source $HYP_TX90_PIN \
    -invert \
    -divide_by 1 \
    $HYP_CKN_OUT
}

#####################################
## Returned RWDS Read-Strobe Clock ##
#####################################

# RWDS has three protocol roles:
#   1. During CA/latency it is a level sampled by clk_sys_i to request extra
#      latency.
#   2. During writes it is driven by us as the DDR data-mask/write-strobe signal.
#   3. During reads it is driven by HyperRAM as the edge-aligned source clock for DQ.
#
# The read-strobe model below follows AN433's source-synchronous input method:
# use a virtual edge-aligned launch clock at the HyperRAM/board boundary and a
# delayed sample clock inside the receiver.  DQ is constrained to +/-HYP_READ_SKEW
# relative to the virtual launch clock; the delayed sample clock is shifted by T/4.
create_clock -name clk_hyp_rwds_read_virt -period $HYP_TCK

# Optional physical RWDS clock on the top input.  It documents the strobe role and
# helps tools report the incoming clock, but the DQ input delays below use the
# virtual launch clock so they do not depend on exact port-to-delay-line naming.
if {[llength $HYP_RWDS_IN] > 0} {
  create_clock -name clk_hyp_rwds_edge -period $HYP_TCK $HYP_RWDS_IN
}

# Match every delayed RWDS clock that feeds i_rwds_in_clk_gate.  For NumPhys==2
# the path is under phy_wrap/phy_unroll[*]/i_phy; for NumPhys==1 it is directly
# under i_backend/i_phy/i_phy.
set HYP_RX_SAMPLE_CLK [get_pins -hierarchical {*i_trx/i_delay_rx_rwds_90/out_o}]

if {[llength $HYP_RX_SAMPLE_CLK] > 0} {
  create_clock -name clk_hyp_rwds_sample \
    -period $HYP_TCK \
    -waveform [list $HYP_QUARTER [expr $HYP_QUARTER + $HYP_HALF]] \
    $HYP_RX_SAMPLE_CLK
} else {
  puts "WARNING: HYP_RX_SAMPLE_CLK is empty; update it to each delayed RWDS sample-clock pin."
}

set_clock_uncertainty $CLK_UNCERTAINTY [all_clocks]
set_clock_transition  0.05 [all_clocks]

##########################
## Write And CA Outputs ##
##########################

# Command/address DQ, write DQ, and write RWDS are all DDR outputs launched by
# clk_sys_i and sampled by the memory using center-aligned CK.  This is AN433's
# same-edge, center-aligned DDR output case:
#   max = +T/4 - output_skew
#   min = -T/4 + output_skew
# The -clock_fall copies are required because HyperBus transfers on both CK edges.
if {[llength $HYP_WRITE_OUT] > 0 && [llength [get_clocks  clk_hyp_ck_out]] > 0} {
  set_output_delay -max -add_delay             -clock clk_hyp_ck_out [expr  $HYP_QUARTER - $HYP_OUT_SKEW] $HYP_WRITE_OUT
  set_output_delay -max -add_delay -clock_fall -clock clk_hyp_ck_out [expr  $HYP_QUARTER - $HYP_OUT_SKEW] $HYP_WRITE_OUT
  set_output_delay -min -add_delay             -clock clk_hyp_ck_out [expr -$HYP_QUARTER + $HYP_OUT_SKEW] $HYP_WRITE_OUT
  set_output_delay -min -add_delay -clock_fall -clock clk_hyp_ck_out [expr -$HYP_QUARTER + $HYP_OUT_SKEW] $HYP_WRITE_OUT

  # The DDR mux implements same-edge transfer for each half-cycle.  Cut invalid
  # opposite-edge setup checks and same-edge hold checks, matching the commercial
  # constraints and AN433's DDR edge-exception guidance for this formulation.
  set_false_path -setup -rise_from [get_clocks clk_sys] -fall_to [get_clocks clk_hyp_ck_out] -to $HYP_WRITE_OUT
  set_false_path -setup -fall_from [get_clocks clk_sys] -rise_to [get_clocks clk_hyp_ck_out] -to $HYP_WRITE_OUT
  set_false_path -hold  -rise_from [get_clocks clk_sys] -rise_to [get_clocks clk_hyp_ck_out] -to $HYP_WRITE_OUT
  set_false_path -hold  -fall_from [get_clocks clk_sys] -fall_to [get_clocks clk_hyp_ck_out] -to $HYP_WRITE_OUT
}

# DQ/RWDS output enables are registered once per full clk_sys_i cycle and control
# both DDR beats.  They must not be constrained as falling-edge DDR data.
if {[llength $HYP_WRITE_OE] > 0 && [llength [get_clocks  clk_hyp_ck_out]] > 0} {
  set_output_delay -max -add_delay -clock clk_hyp_ck_out [expr  $HYP_QUARTER       - $HYP_CTRL_SKEW] $HYP_WRITE_OE
  set_output_delay -min -add_delay -clock clk_hyp_ck_out [expr -$HYP_THREE_QUARTER + $HYP_CTRL_SKEW] $HYP_WRITE_OE
}

# CS# is a single-data-rate control.  It is intentionally changed away from the
# DDR data transitions and only needs to be stable around CK start/stop edges.
if {[llength $HYP_CS_OUT] > 0 && [llength [get_clocks  clk_hyp_ck_out]] > 0} {
  set_output_delay -max -add_delay -clock clk_hyp_ck_out [expr $HYP_HALF - $HYP_CTRL_SKEW] $HYP_CS_OUT
  set_output_delay -min -add_delay -clock clk_hyp_ck_out [expr             $HYP_CTRL_SKEW] $HYP_CS_OUT
}

# RESET# is an asynchronous passthrough of rst_ni in hyperbus_trx.  Give it a
# bounded propagation budget, but do not make it a DDR/CK-timed output.
if {[llength $HYP_RESET_OUT] > 0} {
  set_max_delay [expr 2.0 * $HYP_TCK] -from [get_ports rst_ni] -to $HYP_RESET_OUT -ignore_clock_latency
  set_false_path -hold -from [get_ports rst_ni] -to $HYP_RESET_OUT
}

#############################
## RWDS Latency Indicator  ##
#############################

# During CA and initial latency, RWDS is a level sampled by clk_sys_i
# (hyperbus_trx.proc_ff_rwds_sample).  It is not DDR data in this role and should
# not get -clock_fall constraints.  The protocol keeps it stable for multiple CK
# cycles; the delay below exists to keep the path visible without over-constraining
# it to read-strobe timing.
if {[llength $HYP_RWDS_IN] > 0} {
  set_input_delay -max -add_delay -clock clk_sys [expr 0.50 * $HYP_TCK]     $HYP_RWDS_IN
  set_input_delay -min -add_delay -clock clk_sys [expr -$CLK_UNCERTAINTY]   $HYP_RWDS_IN
}

######################
## Read DQ Inputs   ##
######################

# During reads, HyperRAM launches DQ edge-aligned with RWDS.  The receiver delays
# RWDS by T/4 and samples DQ in the data eye, so the DQ input delay is simply the
# allowed DQ-vs-RWDS skew around the virtual read launch clock.  This is AN433's
# same-edge, center-aligned DDR input case.
if {[llength $HYP_DQ_IN] > 0 && [llength [get_clocks  clk_hyp_rwds_sample]] > 0} {
  set_input_delay -max -add_delay             -clock clk_hyp_rwds_read_virt  $HYP_READ_SKEW  $HYP_DQ_IN
  set_input_delay -max -add_delay -clock_fall -clock clk_hyp_rwds_read_virt  $HYP_READ_SKEW  $HYP_DQ_IN
  set_input_delay -min -add_delay             -clock clk_hyp_rwds_read_virt [expr -$HYP_READ_SKEW] $HYP_DQ_IN
  set_input_delay -min -add_delay -clock_fall -clock clk_hyp_rwds_read_virt [expr -$HYP_READ_SKEW] $HYP_DQ_IN

  # Cut invalid DDR edge relationships between the virtual launch clock and the
  # delayed RWDS sample clock.  Keep same-edge setup and opposite-edge hold.
  set_false_path -setup -fall_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_sample]
  set_false_path -setup -rise_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]
  set_false_path -hold  -rise_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_sample]
  set_false_path -hold  -fall_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]
}

######################################
## RWDS-Domain Control And CDC FIFO ##
######################################

# The RWDS clock gate is enabled by the PHY FSM before read sampling starts and is
# reset only after the outstanding read samples have drained.  Treat the enable as
# a multicycle control, not a per-beat datapath.

# Find the rwds clock-gate enable net
set RWDS_ENA_NET [get_nets -hierarchical *rx_rwds_clk_ena*]

# Find the clock-gate cell connected to that net
set RWDS_GATE_CELL [get_cells -of_objects $RWDS_ENA_NET -filter {ref_name=~*clk_gating*}]

# Get the en_i pin on that cell
set HYP_RWDS_GATE_EN [get_pins -of_objects $RWDS_GATE_CELL -filter {name=~*en_i*}]


if {[llength $HYP_RWDS_GATE_EN] > 0} {
  set_multicycle_path -setup 2 -through $HYP_RWDS_GATE_EN
  set_multicycle_path -hold  1 -through $HYP_RWDS_GATE_EN
}

# The only real cross-domain path in the fully synchronous top is the read-data
# FIFO from delayed/gated RWDS back to clk_sys_i.  There are no i_cdc_2phase_* or
# frontend/backend CDC FIFOs in hyperbus_synchronous, so do not carry those old
# commercial constraints over.
#
# Do not add a blanket set_clock_groups -asynchronous between clk_sys and the
# RWDS clocks in this canonical block.  Some tools give clock-group false paths
# higher precedence than max/min delay constraints, which would also hide the
# bounded async-pointer checks below.  If your flow requires clock groups, use a
# tool-specific allow-paths mechanism or re-apply the CDC max/min constraints with
# verified precedence.
set HYP_RWDS_CDC_ASYNC [get_nets -hierarchical {*i_trx/i_rx_rwds_cdc_fifo.async*}]


if {[llength $HYP_RWDS_CDC_ASYNC] > 0} {
  set_max_delay [expr  0.50 * $HYP_TCK] -through $HYP_RWDS_CDC_ASYNC -ignore_clock_latency
  set_min_delay [expr -$CLK_UNCERTAINTY] -through $HYP_RWDS_CDC_ASYNC -ignore_clock_latency
}

###################################
## DDR Mux / Clock-Select Checks ##
###################################

# hyperbus_ddr_out uses tc_clk_mux2 with clk_sys_i as the select to build a DDR
# output.  STA may otherwise treat the select as a clock-gating check or propagate
# clk_sys_i through the mux as data.  Keep this scoped to the DDR output muxes.
# If set_disable_clock_gating_check is not available in your STA tool, use the
# equivalent scoped set_sense -clock -stop_propagation on the i_ddrmux select pins.
set HYP_DDR_MUX_CELLS [get_cells -hierarchical {*i_trx/i_ddr_tx_*/i_ddrmux*}]

set HYP_DDR_MUX_SEL_PINS [get_pins -of_objects $HYP_DDR_MUX_CELLS -filter {name=~*S*}]

if {[llength $HYP_DDR_MUX_CELLS] > 0} {
  set_sense -clock -stop_propagation $HYP_DDR_MUX_SEL_PINS
}

# Do not add a broad false path through hyper_rwds_i.  That hides the read DQ
# source-synchronous interface.  RWDS-as-level is constrained above; RWDS-as-clock
# is modeled by clk_hyp_rwds_read_virt/clk_hyp_rwds_sample; RWDS-as-write-strobe
# is included in HYP_WRITE_OUT.

