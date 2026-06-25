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

# EZ-cell Liberty does not set this; limiting fanout reduces routing stress.
set_max_fanout 16 [current_design]


#############################
## Driving Cells and Loads ##
#############################

# Default IO model: inputs are driven by one IO pad; outputs drive two 74HC
# inputs plus a 5 pF trace.
set_load [expr 2 * 5.0 + 5.0] [all_outputs]
set_driving_cell [all_inputs] -lib_cell sg13cmos5l_IOPadOut16mA -pin pad


##################
## Input Clocks ##
##################
puts "Clocks..."

# Target 100 MHz.
#set TCK_SYS [expr 1000.0 / 90.0]
set TCK_SYS 10.0
create_clock -name clk_sys -period $TCK_SYS [get_ports clk_i]

set TCK_JTG 25.0
create_clock -name clk_jtg -period $TCK_JTG [get_ports jtag_tck_i]

set TCK_RTC 50.0
create_clock -name clk_rtc -period $TCK_RTC [get_ports ref_clk_i]


##################################
## Clock Groups & Uncertainties ##
##################################

# These top-level clocks are asynchronous.  During CDC debug, use -allow_paths to
# expose crossings before adding focused constraints.
set_clock_groups -asynchronous -name clk_groups_async \
     -group {clk_rtc} \
     -group {clk_jtg} \
     -group {clk_sys}

# Clock uncertainty and rise/fall transition assumptions, in ns.
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition  0.2 [all_clocks]


####################
## Cdcs and Syncs ##
####################
puts "CDC/Sync..."

# CDC setup/hold checks are cut by the asynchronous clock groups above.  Add
# focused max-delay budgets so synchronizer changes propagate within one cycle;
# 3 ns is a practical metastability-recovery target.

## DMI request `cdc_2phase`
set_max_delay 3.0 -from $JTAG_ASYNC_REQ_START -to $JTAG_ASYNC_REQ_END -ignore_clock_latency

## DMI response `cdc_2phase`
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

# These low-priority outputs should still stay within one clk_sys cycle.
#set_output_delay -min -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {status_o neopixel_data_o unused*}]
#set_output_delay -max -add_delay -clock clk_sys [ expr $TCK_SYS * 0.10 ] [get_ports {status_o neopixel_data_o unused*}]

# Status/spare outputs are not cycle-critical; keep IO checks visible but allow
# two cycles for setup.
#set_multicycle_path -setup 2 -end -to [get_ports {status_o unused*_o}]
#set_multicycle_path -hold  1 -end -to [get_ports {status_o unused*_o}]


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
# HyperBus uses clk_sys_i for the control/write path.  Outgoing CK is clk_sys_i
# delayed by the TX delay line.  Reads are source-synchronous: HyperRAM returns
# DQ edge-aligned to RWDS, and the PHY delays RWDS before sampling DQ.
#
# Bidirectional DQ/RWDS timing is constrained at the core side of the IO pads to
# avoid mixing pad-side and core-side timing points.  One-way CK/CS#/RESET# keep
# top-port checks for IO-audit visibility.
#
# Instance patterns assume enough HyperBus hierarchy remains after synthesis to
# find the delay-line and RWDS clock pins.

################
## Parameters ##
################

# HyperBus CK and clk_sys_i use the same period in this top.
#
# The delay-line Liberty model has one in_i->out_o timing arc; tap-dependent
# delay is not exposed to STA.
set HYP_TCK $TCK_SYS

set HYP_HALF          [expr 0.50 * $HYP_TCK]
set HYP_QUARTER       [expr 0.25 * $HYP_TCK]

# Interface margins: READ is DQ-vs-RWDS skew, OUT is CK-vs-DQ/RWDS skew, CTRL is
# CK-vs-control skew.  Include board/device mismatch here.
set HYP_OUT_SKEW       0.55
set HYP_READ_SKEW      0.90
set HYP_CTRL_SKEW      0.55
set CLK_UNCERTAINTY    0.05

######################
## Port Collections ##
######################

proc hyp_assert_nonempty {name collection} {
  if {[llength $collection] == 0} {
    error "HyperBus constraint collection $name is empty"
  }
}

# Use core-side pad pins for bidirectional DQ/RWDS timing; top-level inout ports
# do not give useful TX endpoints in OpenSTA.
set HYP_DQ_PAD_PORTS  [get_ports {hyper_dq_*_io}]
set HYP_RWDS_PAD_PORT [get_ports {hyper_rwds_io}]
set HYP_DQ_IO         [get_pins {pad_hyper_dq_*_io/p2c}]
set HYP_RWDS_IO       [get_pins {pad_hyper_rwds_io/p2c}]
set HYP_WRITE_OUT     [get_pins {pad_hyper_dq_*_io/c2p pad_hyper_rwds_io/c2p}]

# OE is a per-cycle pad control, not DDR data sampled by CK.
set HYP_WRITE_OE   [get_pins {pad_hyper_dq_*_io/c2p_en pad_hyper_rwds_io/c2p_en}]

set HYP_CK_OUT     [get_ports {hyper_ck_o}]
set HYP_CKN_OUT    [get_ports {hyper_ck_no}]
set HYP_CS_OUT     [get_ports {hyper_cs_no}]
set HYP_RESET_OUT  [get_ports {hyper_reset_no}]
set HYP_CK_C2P     [get_pins {pad_hyper_ck_o/c2p}]

hyp_assert_nonempty HYP_DQ_PAD_PORTS  $HYP_DQ_PAD_PORTS
hyp_assert_nonempty HYP_RWDS_PAD_PORT $HYP_RWDS_PAD_PORT
hyp_assert_nonempty HYP_DQ_IO      $HYP_DQ_IO
hyp_assert_nonempty HYP_RWDS_IO    $HYP_RWDS_IO
hyp_assert_nonempty HYP_WRITE_OUT  $HYP_WRITE_OUT
hyp_assert_nonempty HYP_WRITE_OE   $HYP_WRITE_OE
hyp_assert_nonempty HYP_CK_OUT     $HYP_CK_OUT
hyp_assert_nonempty HYP_CKN_OUT    $HYP_CKN_OUT
hyp_assert_nonempty HYP_CS_OUT     $HYP_CS_OUT
hyp_assert_nonempty HYP_RESET_OUT  $HYP_RESET_OUT
hyp_assert_nonempty HYP_CK_C2P     $HYP_CK_C2P

###################
## Primary Clock ##
###################

#create_clock -name clk_sys -period $HYP_TCK [get_ports clk_i]

# Functional timing assumes test-mode clock muxes select normal clocks.
set_case_analysis 0 [get_ports testmode_i]
set_input_delay -clock clk_sys -max [expr 0.10 * $HYP_TCK] [get_ports testmode_i]
set_false_path -hold -from [get_ports testmode_i]

# rst_ni is asynchronous and also feeds HyperBus RESET# directly.
set_input_delay -clock clk_sys -max [expr 0.10 * $HYP_TCK] [get_ports rst_ni]
set_false_path -hold -from [get_ports rst_ni]

#####################################
## Generated Outgoing HyperBus CK  ##
#####################################

# TX delay-line output used to generate HyperBus CK.
set HYP_TX90_PIN [get_pins  {
  *i_tx_clk_delay/i_delay_tx_clk_90/out_o
}]
set HYP_TX_DLINE_IN [get_pins {
  *i_tx_clk_delay/i_delay_tx_clk_90/in_i
}]

hyp_assert_nonempty HYP_TX90_PIN $HYP_TX90_PIN
hyp_assert_nonempty HYP_TX_DLINE_IN $HYP_TX_DLINE_IN

create_generated_clock -name clk_hyp_tx_90 \
  -source [get_ports clk_i] \
  -master_clock clk_sys \
  -divide_by 1 \
  $HYP_TX90_PIN

# Core-side CK times DQ/RWDS c2p pins; top-level CK/CK# clocks include pad delay
# for external-output reports.
create_generated_clock -name clk_hyp_ck_core \
  -source $HYP_TX90_PIN \
  -divide_by 1 \
  $HYP_CK_C2P

create_generated_clock -name clk_hyp_ck_out \
  -source $HYP_TX90_PIN \
  -divide_by 1 \
  $HYP_CK_OUT

create_generated_clock -name clk_hyp_ckn_out \
  -source $HYP_TX90_PIN \
  -invert \
  -divide_by 1 \
  $HYP_CKN_OUT

#####################################
## Returned RWDS Read-Strobe Clock ##
#####################################

# RWDS roles: latency-indicator level during CA, write data-mask/strobe during
# writes, and edge-aligned read source clock during reads.
#
# Read timing follows AN433: virtual RWDS launches DQ edge-aligned, while the
# propagated delayed RWDS clocks capture DQ in the eye.
create_clock -name clk_hyp_rwds_read_virt -period $HYP_TCK

# Delay-line output probe; capture flops are clocked after gate and test mux.
set HYP_RX_DELAY_OUT [get_pins -hierarchical {*i_trx/i_delay_rx_rwds_90/out_o}]
hyp_assert_nonempty HYP_RX_DELAY_OUT $HYP_RX_DELAY_OUT

# Post-inverter clock that pushes complete 16-bit read words into the FIFO.
set HYP_RX_SAMPLE_CLK [get_pins -hierarchical {*i_trx/i_rwds_clk_inverter/i_inv/Y}]
hyp_assert_nonempty HYP_RX_SAMPLE_CLK $HYP_RX_SAMPLE_CLK

set HYP_RX_CAPTURE_STOP [get_pins -hierarchical {*i_trx/i_rwds_clk_inverter/i_inv/A}]
hyp_assert_nonempty HYP_RX_CAPTURE_STOP $HYP_RX_CAPTURE_STOP

set HYP_RX_DELAY_IN [get_pins -hierarchical {*i_trx/i_delay_rx_rwds_90/in_i}]
hyp_assert_nonempty HYP_RX_DELAY_IN $HYP_RX_DELAY_IN

# Edge-aligned RWDS at the core side of the IO pad.
create_clock -name clk_hyp_rwds_edge -period $HYP_TCK $HYP_RWDS_IO

set HYP_RX_RWDS_CLK_MUX_SEL [get_pins -hierarchical {*i_trx/i_rx_rwds_clk_mux/i_mux/S0}]
set HYP_RX_RWDS_CLK_MUX_TEST_CLK [get_pins -hierarchical {*i_trx/i_rx_rwds_clk_mux/i_mux/A1}]
set HYP_RX_RWDS_CLK_MUX_CELL [get_cells -hierarchical {*i_trx/i_rx_rwds_clk_mux/i_mux}]
set HYP_RX_CAPTURE_CLK [get_pins -hierarchical {*i_trx/i_rx_rwds_clk_mux/i_mux/Y}]
hyp_assert_nonempty HYP_RX_RWDS_CLK_MUX_SEL $HYP_RX_RWDS_CLK_MUX_SEL
hyp_assert_nonempty HYP_RX_RWDS_CLK_MUX_TEST_CLK $HYP_RX_RWDS_CLK_MUX_TEST_CLK
hyp_assert_nonempty HYP_RX_RWDS_CLK_MUX_CELL $HYP_RX_RWDS_CLK_MUX_CELL
hyp_assert_nonempty HYP_RX_CAPTURE_CLK $HYP_RX_CAPTURE_CLK
set_case_analysis 0 $HYP_RX_RWDS_CLK_MUX_SEL
set_sense -type clock -stop_propagation -clocks [get_clocks clk_sys] $HYP_RX_RWDS_CLK_MUX_TEST_CLK

# Capture is delayed RWDS after gate/mux.  Sample is its local inverse and pushes
# the FIFO after both DDR beats are available.
create_generated_clock -name clk_hyp_rwds_capture \
  -source $HYP_RWDS_IO \
  -master_clock clk_hyp_rwds_edge \
  -divide_by 1 \
  $HYP_RX_CAPTURE_CLK

create_generated_clock -name clk_hyp_rwds_sample \
  -source $HYP_RX_CAPTURE_CLK \
  -master_clock clk_hyp_rwds_capture \
  -divide_by 1 \
  -invert \
  $HYP_RX_SAMPLE_CLK

set_clock_uncertainty $CLK_UNCERTAINTY [all_clocks]
set_clock_transition  0.05 [get_clocks {
  clk_sys clk_jtg clk_rtc
  clk_hyp_tx_90 clk_hyp_ck_core clk_hyp_ck_out clk_hyp_ckn_out
  clk_hyp_rwds_edge clk_hyp_rwds_capture clk_hyp_rwds_sample
}]

##########################
## Write And CA Outputs ##
##########################

# CA/write DQ and write RWDS are DDR outputs sampled by center-aligned CK.  The
# TX delay line is propagated clock latency; adding one period to max delay is the
# AN433 same-edge form that checks setup against the current delayed CK edge.
set_output_delay -max -add_delay             -clock clk_hyp_ck_core [expr $HYP_TCK + $HYP_OUT_SKEW] $HYP_WRITE_OUT
set_output_delay -max -add_delay -clock_fall -clock clk_hyp_ck_core [expr $HYP_TCK + $HYP_OUT_SKEW] $HYP_WRITE_OUT
set_output_delay -min -add_delay             -clock clk_hyp_ck_core [expr -$HYP_OUT_SKEW] $HYP_WRITE_OUT
set_output_delay -min -add_delay -clock_fall -clock clk_hyp_ck_core [expr -$HYP_OUT_SKEW] $HYP_WRITE_OUT

# DDR mux select is the launch mechanism for pad transitions, so keep it timed.
set HYP_DDR_MUX_CELLS [get_cells -hierarchical {
  *i_trx/gen_ddr_tx_data*.i_ddr_tx_data/i_ddrmux/i_mux
  *i_trx/i_ddr_tx_rwds/i_ddrmux/i_mux
}]
hyp_assert_nonempty HYP_DDR_MUX_CELLS $HYP_DDR_MUX_CELLS

set HYP_DDR_MUX_OUT_PINS [get_pins -of_objects $HYP_DDR_MUX_CELLS -filter {name==Y}]
hyp_assert_nonempty HYP_DDR_MUX_OUT_PINS $HYP_DDR_MUX_OUT_PINS

set HYP_DDR_MUX_SEL_PINS [get_pins -of_objects $HYP_DDR_MUX_CELLS -filter {name==S0}]
hyp_assert_nonempty HYP_DDR_MUX_SEL_PINS $HYP_DDR_MUX_SEL_PINS

# Cut invalid DDR edge relationships; keep opposite-edge hold checks so the next
# half-cycle transition cannot corrupt the previous CK sample.
set_false_path -setup -rise_from [get_clocks clk_sys] -fall_to [get_clocks clk_hyp_ck_core] -through $HYP_DDR_MUX_OUT_PINS
set_false_path -setup -fall_from [get_clocks clk_sys] -rise_to [get_clocks clk_hyp_ck_core] -through $HYP_DDR_MUX_OUT_PINS
set_false_path -hold  -rise_from [get_clocks clk_sys] -rise_to [get_clocks clk_hyp_ck_core] -through $HYP_DDR_MUX_OUT_PINS
set_false_path -hold  -fall_from [get_clocks clk_sys] -fall_to [get_clocks clk_hyp_ck_core] -through $HYP_DDR_MUX_OUT_PINS

# DQ/RWDS output enables are per-cycle controls, not DDR data.  They are enabled
# before CK starts; do not apply falling-edge DDR checks or 3/4-cycle hold.
set HYP_OE_BUDGET [expr $HYP_QUARTER - $HYP_CTRL_SKEW]
set_output_delay -max -add_delay -clock clk_hyp_ck_core $HYP_OE_BUDGET $HYP_WRITE_OE
set_output_delay -min -add_delay -clock clk_hyp_ck_core $HYP_OE_BUDGET $HYP_WRITE_OE

# CS# is single-data-rate and must be stable around CK start/stop.
set_output_delay -max -add_delay -clock clk_hyp_ck_out [expr $HYP_HALF - $HYP_CTRL_SKEW] $HYP_CS_OUT
set_output_delay -min -add_delay -clock clk_hyp_ck_out [expr             $HYP_CTRL_SKEW] $HYP_CS_OUT

# Mark CK/CK# top-level outputs as intentionally constrained.
set_output_delay -max -add_delay -clock clk_hyp_tx_90 0.0 $HYP_CK_OUT
set_output_delay -min -add_delay -clock clk_hyp_tx_90 0.0 $HYP_CK_OUT
set_output_delay -max -add_delay -clock clk_hyp_tx_90 0.0 $HYP_CKN_OUT
set_output_delay -min -add_delay -clock clk_hyp_tx_90 0.0 $HYP_CKN_OUT

# RESET# is an asynchronous rst_ni passthrough with a bounded propagation budget.
set_max_delay [expr 2.0 * $HYP_TCK] -from [get_ports rst_ni] -to $HYP_RESET_OUT -ignore_clock_latency
set_false_path -hold -from [get_ports rst_ni] -to $HYP_RESET_OUT

#############################
## RWDS Latency Indicator  ##
#############################

# In CA/latency, RWDS is a stable level sampled by clk_sys_i, not DDR data.  It
# is not launched by local clk_sys, so constrain only the internal pad-to-sample
# path instead of using clk_sys input delays.
set HYP_RWDS_SAMPLE_D [get_pins -hierarchical {*i_trx/rwds_sample_o_reg/D}]
hyp_assert_nonempty HYP_RWDS_SAMPLE_D $HYP_RWDS_SAMPLE_D

set HYP_RWDS_SAMPLE_BUDGET [expr 0.50 * $HYP_TCK]
set_max_delay $HYP_RWDS_SAMPLE_BUDGET -through $HYP_RWDS_IO -to $HYP_RWDS_SAMPLE_D -ignore_clock_latency
set_min_delay 0.0                     -through $HYP_RWDS_IO -to $HYP_RWDS_SAMPLE_D -ignore_clock_latency

######################
## Read DQ Inputs   ##
######################

# Read DQ is edge-aligned to virtual RWDS.  The propagated delayed RWDS clocks
# provide the center capture point, so input delay is only DQ-vs-RWDS skew.
set_input_delay -max -add_delay             -clock clk_hyp_rwds_read_virt  $HYP_READ_SKEW         $HYP_DQ_IO
set_input_delay -max -add_delay -clock_fall -clock clk_hyp_rwds_read_virt  $HYP_READ_SKEW         $HYP_DQ_IO
set_input_delay -min -add_delay             -clock clk_hyp_rwds_read_virt [expr -$HYP_READ_SKEW] $HYP_DQ_IO
set_input_delay -min -add_delay -clock_fall -clock clk_hyp_rwds_read_virt [expr -$HYP_READ_SKEW] $HYP_DQ_IO

# Keep only valid DDR edge relationships between virtual RWDS launch and delayed
# RWDS capture.
#
# The unusual "0 -end" form is intentional: it makes same-edge setup use the
# virtual launch edge plus propagated delay-line latency, not the next RWDS edge.
set_multicycle_path -setup 0 -end -rise_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_capture]
set_multicycle_path -setup 0 -end -fall_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_capture]
set_false_path -setup -fall_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_capture]
set_false_path -setup -rise_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_capture]
set_false_path -hold  -rise_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_capture]
set_false_path -hold  -fall_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_capture]

# The post-inverter FIFO-push edge captures the second beat; cut the other edge
# pairings.
set_multicycle_path -setup 0 -end -fall_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_sample]
set_false_path -setup -rise_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_sample]
set_false_path -setup -rise_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]
set_false_path -setup -fall_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]
set_false_path -hold  -fall_from [get_clocks clk_hyp_rwds_read_virt] -rise_to [get_clocks clk_hyp_rwds_sample]
set_false_path -hold  -fall_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]
set_false_path -hold  -rise_from [get_clocks clk_hyp_rwds_read_virt] -fall_to [get_clocks clk_hyp_rwds_sample]

######################################
## RWDS-Domain Control And CDC FIFO ##
######################################

# RWDS gate enable is a control path that must settle before read sampling.
set HYP_RWDS_GATE_EN [get_pins -hierarchical {*i_trx/i_rwds_in_clk_gate/gen_clkgate.i_clkgate/E}]
hyp_assert_nonempty HYP_RWDS_GATE_EN $HYP_RWDS_GATE_EN

set HYP_RWDS_GATE_BUDGET [expr 0.25 * $HYP_TCK]
set_clock_gating_check -setup $HYP_RWDS_GATE_BUDGET -hold $CLK_UNCERTAINTY $HYP_RWDS_GATE_EN
set_max_delay $HYP_RWDS_GATE_BUDGET -from [get_clocks clk_sys] -to $HYP_RWDS_GATE_EN -ignore_clock_latency
set_min_delay 0.0 -from [get_clocks clk_sys] -to $HYP_RWDS_GATE_EN -ignore_clock_latency

# RWDS soft reset releases from the same clk_sys enable that opens the RWDS gate.
# Time the release path, but do not require removal to a gated-off RWDS edge.
set HYP_RX_SOFT_RST_PINS [get_pins -hierarchical {*i_trx/i_rx_rwds_cdc_fifo.src_*_reg/RB}]
hyp_assert_nonempty HYP_RX_SOFT_RST_PINS $HYP_RX_SOFT_RST_PINS
set_max_delay $HYP_RWDS_GATE_BUDGET -from [get_clocks clk_sys] -to $HYP_RX_SOFT_RST_PINS -ignore_clock_latency
set_false_path -hold -from [get_clocks clk_sys] -to $HYP_RX_SOFT_RST_PINS

# TX CK gate enable must settle before the shifted CK edge reaches the gate.
set HYP_TX_CK_GATE_EN [get_pins -hierarchical {*i_trx/i_clock_diff_out/i_hyper_ck_gating/gen_clkgate.i_clkgate/E}]
hyp_assert_nonempty HYP_TX_CK_GATE_EN $HYP_TX_CK_GATE_EN

set HYP_TX_CK_GATE_BUDGET [expr 0.25 * $HYP_TCK]
set_clock_gating_check -setup $HYP_TX_CK_GATE_BUDGET -hold $CLK_UNCERTAINTY $HYP_TX_CK_GATE_EN
set_max_delay $HYP_TX_CK_GATE_BUDGET -from [get_clocks clk_sys] -to $HYP_TX_CK_GATE_EN -ignore_clock_latency
set_min_delay 0.0 -from [get_clocks clk_sys] -to $HYP_TX_CK_GATE_EN -ignore_clock_latency

# The real CDC here is the read-data FIFO from delayed RWDS back to clk_sys_i.
#
# Do not blanket-false-path clk_sys and RWDS clocks; that can hide the bounded
# async-pointer checks below.
set HYP_RWDS_CDC_ASYNC [get_nets -hierarchical {*i_trx/i_rx_rwds_cdc_fifo.async*}]
hyp_assert_nonempty HYP_RWDS_CDC_ASYNC $HYP_RWDS_CDC_ASYNC

set_max_delay [expr  0.50 * $HYP_TCK] -through $HYP_RWDS_CDC_ASYNC -ignore_clock_latency
set_min_delay [expr -$CLK_UNCERTAINTY] -through $HYP_RWDS_CDC_ASYNC -ignore_clock_latency

###################################
## DDR Mux / Clock-Select Checks ##
###################################

# Stop clock propagation through DDR mux selects; the selects are launch controls,
# not clocks or external data.
set HYP_DDR_MUX_CELLS [get_cells -hierarchical {
  *i_trx/gen_ddr_tx_data*.i_ddr_tx_data/i_ddrmux/i_mux
  *i_trx/i_ddr_tx_rwds/i_ddrmux/i_mux
}]
hyp_assert_nonempty HYP_DDR_MUX_CELLS $HYP_DDR_MUX_CELLS

set HYP_DDR_MUX_SEL_PINS [get_pins -of_objects $HYP_DDR_MUX_CELLS -filter {name==S0}]
hyp_assert_nonempty HYP_DDR_MUX_SEL_PINS $HYP_DDR_MUX_SEL_PINS

set_sense -type clock -stop_propagation $HYP_DDR_MUX_SEL_PINS

# Avoid broad RWDS false paths: RWDS is constrained separately as level, read
# clock, and write strobe.
