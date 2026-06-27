# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# HyperBus timing report deck for OpenROAD/OpenSTA.
#
# Usage:
#   HYP_RPT_CHECKPOINT=03_croc.cts ./run_backend.sh --run scripts/hyperbus_constraints_report.tcl
#   HYP_RPT_CHECKPOINT=04_croc.routed ./run_backend.sh --run scripts/hyperbus_constraints_report.tcl
#
# Loads the requested checkpoint, estimates parasitics, and writes focused
# reports under reports/hyperbus_<checkpoint>/.

source scripts/startup.tcl

set HYP_RPT_CHECKPOINT [expr {[info exists ::env(HYP_RPT_CHECKPOINT)] ? $::env(HYP_RPT_CHECKPOINT) : "latest"}]
set HYP_RPT_USE_CURRENT_SDC [expr {[info exists ::env(HYP_RPT_USE_CURRENT_SDC)] ? $::env(HYP_RPT_USE_CURRENT_SDC) : 0}]
set HYP_RPT_TAG [string map {"/" "_" "." "_"} $HYP_RPT_CHECKPOINT]
set HYP_RPT_DIR [file join $report_dir "hyperbus_${HYP_RPT_TAG}"]
if {[file exists $HYP_RPT_DIR]} {
  file delete -force $HYP_RPT_DIR
}
file mkdir $HYP_RPT_DIR

utl::report "HyperBus report checkpoint: $HYP_RPT_CHECKPOINT"

proc hyp_load_checkpoint_db_only {checkpoint} {
  global save_dir
  if {$checkpoint eq "" || $checkpoint eq "latest"} {
    set zips [lsort -decreasing -index 0 [glob -nocomplain -directory $save_dir -types f *.zip]]
    if {![llength $zips]} {
      error "No checkpoint .zip found in $save_dir"
    }
    set checkpoint [file rootname [file tail [lindex $zips 0]]]
  }

  set candidates [glob -nocomplain -directory $save_dir -types f "*${checkpoint}*"]
  if {![llength $candidates]} {
    error "No checkpoint found matching: $checkpoint"
  }

  set name [lindex $candidates 0]
  set ext [file extension $name]
  if {$ext eq ".zip"} {
    set chkpath [file join $save_dir "hyp_rpt_${checkpoint}"]
    file delete -force $chkpath
    exec unzip -qq -o $name -d $chkpath
    read_db [file join $chkpath $checkpoint.odb]
    file delete -force $chkpath
  } elseif {$ext eq ".odb"} {
    read_db $name
  } else {
    error "Unsupported checkpoint type for DB-only load: $ext"
  }
}

if {$HYP_RPT_USE_CURRENT_SDC} {
  utl::report "HyperBus report using current src/constraints.sdc"
  hyp_load_checkpoint_db_only $HYP_RPT_CHECKPOINT
  read_sdc src/constraints.sdc
} else {
  load_checkpoint $HYP_RPT_CHECKPOINT
}

setDefaultParasitics
set HYP_RPT_PARASITICS [expr {[info exists ::env(HYP_RPT_PARASITICS)] ? $::env(HYP_RPT_PARASITICS) : ""}]
if {$HYP_RPT_PARASITICS eq ""} {
  if {[regexp {(routed|route|grt|final)} $HYP_RPT_CHECKPOINT]} {
    set HYP_RPT_PARASITICS "global_routing"
  } else {
    set HYP_RPT_PARASITICS "placement"
  }
}

utl::report "HyperBus report parasitics: estimate_parasitics -$HYP_RPT_PARASITICS"
if {$HYP_RPT_PARASITICS eq "placement"} {
  estimate_parasitics -placement
} elseif {$HYP_RPT_PARASITICS eq "global_routing"} {
  estimate_parasitics -global_routing
} elseif {$HYP_RPT_PARASITICS eq "none"} {
  utl::report "HyperBus report parasitics disabled by HYP_RPT_PARASITICS=none"
} else {
  error "Unsupported HYP_RPT_PARASITICS=$HYP_RPT_PARASITICS"
}

if {[regexp {(cts|routed|route|grt|final)} $HYP_RPT_CHECKPOINT]} {
  set HYP_RPT_PROP_CLOCKS [get_clocks -quiet {
    clk_sys clk_jtg clk_rtc
    clk_hyp_tx_90 clk_hyp_ck_core clk_hyp_ck_out clk_hyp_ckn_out
    clk_hyp_rwds_edge clk_hyp_rwds_capture clk_hyp_rwds_sample
  }]
  if {[llength $HYP_RPT_PROP_CLOCKS] == 0} {
    error "HyperBus report collection HYP_RPT_PROP_CLOCKS is empty"
  }
  set_propagated_clock $HYP_RPT_PROP_CLOCKS
}

set HYP_RPT_FORMAT full_clock_expanded
set HYP_RPT_FIELDS {slew cap input fanout}
set HYP_RPT_DIGITS 4
set HYP_RPT_GROUP_PATH_COUNT 80
set HYP_RPT_ENDPOINT_PATH_COUNT 4

proc hyp_size {collection} {
  return [llength $collection]
}

proc hyp_require {name collection} {
  if {[hyp_size $collection] == 0} {
    error "HyperBus report collection $name is empty"
  }
}

proc hyp_write_header {rpt title command} {
  set fh [open $rpt w]
  puts $fh "###############################################################################"
  puts $fh "# $title"
  puts $fh "###############################################################################"
  puts $fh ""
  puts $fh "Command:"
  puts $fh "  $command"
  puts $fh ""
  close $fh
}

proc hyp_run_cmd {tag title cmd} {
  global HYP_RPT_DIR
  set rpt [file join $HYP_RPT_DIR "${tag}.rpt"]
  hyp_write_header $rpt $title $cmd
  puts "HyperBus report $tag -> $rpt"

  set cmd1 $cmd
  lappend cmd1 >> $rpt
  if {![catch {uplevel 1 $cmd1} msg]} {
    return
  }

  set fh [open $rpt a]
  puts $fh ""
  puts $fh "ERROR:"
  puts $fh $msg
  close $fh
  puts "WARNING: HyperBus report $tag failed: $msg"
}

proc hyp_report_checks {tag title args} {
  global HYP_RPT_FORMAT HYP_RPT_FIELDS HYP_RPT_DIGITS
  global HYP_RPT_GROUP_PATH_COUNT HYP_RPT_ENDPOINT_PATH_COUNT

  set cmd [list report_checks]
  lappend cmd -format $HYP_RPT_FORMAT
  lappend cmd -fields $HYP_RPT_FIELDS
  lappend cmd -digits $HYP_RPT_DIGITS
  lappend cmd -sort_by_slack
  lappend cmd -group_path_count $HYP_RPT_GROUP_PATH_COUNT
  lappend cmd -endpoint_path_count $HYP_RPT_ENDPOINT_PATH_COUNT
  foreach a $args {
    lappend cmd $a
  }

  # OpenROAD/OpenSTA option names changed in some versions.
  set rpt [file join $::HYP_RPT_DIR "${tag}.rpt"]
  hyp_write_header $rpt $title $cmd
  puts "HyperBus report $tag -> $rpt"

  set cmd1 $cmd
  lappend cmd1 >> $rpt
  if {![catch {uplevel 1 $cmd1} msg]} {
    return
  }

  set cmd2 {}
  foreach a $cmd {
    if {$a eq "-group_path_count"} {
      lappend cmd2 "-group_count"
    } elseif {$a eq "-endpoint_path_count"} {
      lappend cmd2 "-endpoint_count"
    } else {
      lappend cmd2 $a
    }
  }
  lappend cmd2 >> $rpt
  if {![catch {uplevel 1 $cmd2} msg2]} {
    return
  }

  set fh [open $rpt a]
  puts $fh ""
  puts $fh "ERROR:"
  puts $fh "  first attempt: $msg"
  puts $fh "  fallback     : $msg2"
  close $fh
  puts "WARNING: HyperBus report $tag failed: $msg2"
}

proc hyp_report_checks_expected_empty {tag title reason args} {
  hyp_report_checks $tag $title {*}$args

  set rpt [file join $::HYP_RPT_DIR "${tag}.rpt"]
  set fh [open $rpt r]
  set txt [read $fh]
  close $fh

  if {[string first "No paths found." $txt] >= 0} {
    set txt [string map [list "No paths found." "EXPECTED_EMPTY:\n  $reason"] $txt]
    set fh [open $rpt w]
    puts -nonewline $fh $txt
    close $fh
  }
}

proc hyp_report_clock_cmd {tag title cmd} {
  if {[llength [info commands [lindex $cmd 0]]] > 0} {
    hyp_run_cmd $tag $title $cmd
  }
}

proc hyp_collection_names {collection} {
  set names {}
  foreach obj $collection {
    lappend names [get_full_name $obj]
  }
  return [lsort $names]
}

###############################################################################
# Collections.
###############################################################################

set HYP_DQ_PAD_PORTS  [get_ports -quiet {hyper_dq_*_io}]
set HYP_RWDS_PAD_PORT [get_ports -quiet {hyper_rwds_io}]
set HYP_DQ_IO       [get_pins -quiet {pad_hyper_dq_*_io/p2c}]
set HYP_RWDS_IO     [get_pins -quiet {pad_hyper_rwds_io/p2c}]
set HYP_DQ_C2P      [get_pins -quiet {pad_hyper_dq_*_io/c2p}]
set HYP_RWDS_C2P    [get_pins -quiet {pad_hyper_rwds_io/c2p}]
set HYP_WRITE_C2P   [concat $HYP_DQ_C2P $HYP_RWDS_C2P]
set HYP_WRITE_OUT   $HYP_WRITE_C2P
set HYP_WRITE_OE    [get_pins -quiet {pad_hyper_dq_*_io/c2p_en pad_hyper_rwds_io/c2p_en}]
set HYP_CK_OUT      [get_ports -quiet {hyper_ck_o}]
set HYP_CKN_OUT     [get_ports -quiet {hyper_ck_no}]
set HYP_CS_OUT      [get_ports -quiet {hyper_cs_no}]
set HYP_RESET_OUT   [get_ports -quiet {hyper_reset_no}]
set HYP_CK_C2P      [get_pins -quiet {pad_hyper_ck_o/c2p}]
set HYP_RESET_C2P   [get_pins -quiet {pad_hyper_reset_no/c2p}]
set HYP_BIDIR_PAD_PORTS [concat $HYP_DQ_PAD_PORTS $HYP_RWDS_PAD_PORT]

set HYP_TX_DLINE_IN [get_pins -quiet -hierarchical {*i_tx_clk_delay/i_delay_tx_clk_90/in_i}]
set HYP_TX90_PIN    [get_pins -quiet -hierarchical {*i_tx_clk_delay/i_delay_tx_clk_90/out_o}]

set HYP_RX_DELAY_IN      [get_pins -quiet -hierarchical {*i_trx/i_delay_rx_rwds_90/in_i}]
set HYP_RX_DELAY_OUT     [get_pins -quiet -hierarchical {*i_trx/i_delay_rx_rwds_90/out_o}]
set HYP_RX_CAPTURE_CLK   [get_pins -quiet -hierarchical {*i_trx/i_rx_rwds_clk_mux/i_mux/Y}]
set HYP_RX_CAPTURE_STOP  [get_pins -quiet -hierarchical {*i_trx/i_rwds_clk_inverter/i_inv*/A}]
set HYP_RX_SAMPLE_CLK    [get_pins -quiet -hierarchical {*i_trx/i_rwds_clk_inverter/i_inv*/Y}]
set HYP_RWDS_SAMPLE_D    [get_pins -quiet -hierarchical {*i_trx/rwds_sample_o_reg/D}]
set HYP_RWDS_GATE_EN     [get_pins -quiet -hierarchical {*i_trx/i_rwds_in_clk_gate/gen_clkgate.i_clkgate/E}]
set HYP_TX_CK_GATE_EN    [get_pins -quiet -hierarchical {*i_trx/i_clock_diff_out/i_hyper_ck_gating/gen_clkgate.i_clkgate/E}]
set HYP_RX_SOFT_RST_PINS [get_pins -quiet -hierarchical {*i_trx/i_rx_rwds_cdc_fifo.src_*_reg/RB}]
set HYP_RWDS_CDC_ASYNC   [get_nets -quiet -hierarchical {*i_trx/i_rx_rwds_cdc_fifo.async*}]

set HYP_DDR_MUX_CELLS [get_cells -quiet -hierarchical {
  *i_trx/gen_ddr_tx_data*.i_ddr_tx_data/i_ddrmux/i_mux
  *i_trx/i_ddr_tx_rwds/i_ddrmux/i_mux
}]
set HYP_DDR_MUX_PINS [get_pins -quiet -of_objects $HYP_DDR_MUX_CELLS]
set HYP_DDR_MUX_OUT_PINS [get_pins -quiet -of_objects $HYP_DDR_MUX_CELLS -filter {name==Y}]
set HYP_DDR_MUX_SEL_PINS [get_pins -quiet -of_objects $HYP_DDR_MUX_CELLS -filter {name==S0}]

hyp_require HYP_DQ_PAD_PORTS $HYP_DQ_PAD_PORTS
hyp_require HYP_RWDS_PAD_PORT $HYP_RWDS_PAD_PORT
hyp_require HYP_DQ_IO $HYP_DQ_IO
hyp_require HYP_RWDS_IO $HYP_RWDS_IO
hyp_require HYP_DQ_C2P $HYP_DQ_C2P
hyp_require HYP_RWDS_C2P $HYP_RWDS_C2P
hyp_require HYP_WRITE_OUT $HYP_WRITE_OUT
hyp_require HYP_WRITE_C2P $HYP_WRITE_C2P
hyp_require HYP_WRITE_OE $HYP_WRITE_OE
hyp_require HYP_CK_OUT $HYP_CK_OUT
hyp_require HYP_CKN_OUT $HYP_CKN_OUT
hyp_require HYP_CS_OUT $HYP_CS_OUT
hyp_require HYP_RESET_OUT $HYP_RESET_OUT
hyp_require HYP_CK_C2P $HYP_CK_C2P
hyp_require HYP_RESET_C2P $HYP_RESET_C2P
hyp_require HYP_BIDIR_PAD_PORTS $HYP_BIDIR_PAD_PORTS
hyp_require HYP_TX_DLINE_IN $HYP_TX_DLINE_IN
hyp_require HYP_TX90_PIN $HYP_TX90_PIN
hyp_require HYP_RX_DELAY_IN $HYP_RX_DELAY_IN
hyp_require HYP_RX_DELAY_OUT $HYP_RX_DELAY_OUT
hyp_require HYP_RX_CAPTURE_CLK $HYP_RX_CAPTURE_CLK
hyp_require HYP_RX_CAPTURE_STOP $HYP_RX_CAPTURE_STOP
hyp_require HYP_RX_SAMPLE_CLK $HYP_RX_SAMPLE_CLK
hyp_require HYP_RWDS_SAMPLE_D $HYP_RWDS_SAMPLE_D
hyp_require HYP_RWDS_GATE_EN $HYP_RWDS_GATE_EN
hyp_require HYP_TX_CK_GATE_EN $HYP_TX_CK_GATE_EN
hyp_require HYP_RX_SOFT_RST_PINS $HYP_RX_SOFT_RST_PINS
hyp_require HYP_RWDS_CDC_ASYNC $HYP_RWDS_CDC_ASYNC
hyp_require HYP_DDR_MUX_CELLS $HYP_DDR_MUX_CELLS
hyp_require HYP_DDR_MUX_PINS $HYP_DDR_MUX_PINS
hyp_require HYP_DDR_MUX_OUT_PINS $HYP_DDR_MUX_OUT_PINS
hyp_require HYP_DDR_MUX_SEL_PINS $HYP_DDR_MUX_SEL_PINS

set summary [file join $HYP_RPT_DIR "000_summary.rpt"]
set fh [open $summary w]
puts $fh "HyperBus timing report"
puts $fh "checkpoint       : $HYP_RPT_CHECKPOINT"
puts $fh "parasitics       : $HYP_RPT_PARASITICS"
puts $fh "report directory : $HYP_RPT_DIR"
puts $fh ""
puts $fh "Collection sizes:"
foreach item {
  HYP_DQ_PAD_PORTS HYP_RWDS_PAD_PORT HYP_DQ_IO HYP_RWDS_IO HYP_DQ_C2P
  HYP_RWDS_C2P HYP_WRITE_OUT HYP_WRITE_C2P HYP_WRITE_OE HYP_CK_OUT
  HYP_CKN_OUT HYP_CK_C2P
  HYP_CS_OUT HYP_RESET_OUT HYP_RESET_C2P HYP_BIDIR_PAD_PORTS HYP_TX_DLINE_IN HYP_TX90_PIN HYP_RX_DELAY_IN
  HYP_RX_DELAY_OUT
  HYP_RX_CAPTURE_CLK HYP_RX_CAPTURE_STOP HYP_RX_SAMPLE_CLK HYP_RWDS_SAMPLE_D HYP_RWDS_GATE_EN
  HYP_TX_CK_GATE_EN HYP_RX_SOFT_RST_PINS HYP_RWDS_CDC_ASYNC HYP_DDR_MUX_CELLS HYP_DDR_MUX_PINS
  HYP_DDR_MUX_OUT_PINS HYP_DDR_MUX_SEL_PINS
} {
  puts $fh [format "  %-24s %4d" $item [hyp_size [set $item]]]
}
puts $fh ""
puts $fh "Key objects:"
foreach item {HYP_DQ_PAD_PORTS HYP_RWDS_PAD_PORT HYP_DQ_IO HYP_RWDS_IO HYP_DQ_C2P HYP_RWDS_C2P HYP_WRITE_C2P HYP_WRITE_OE HYP_CK_C2P HYP_RESET_C2P HYP_TX90_PIN HYP_RX_DELAY_OUT HYP_RX_CAPTURE_CLK HYP_RX_SAMPLE_CLK HYP_RWDS_SAMPLE_D HYP_RWDS_GATE_EN HYP_TX_CK_GATE_EN HYP_RX_SOFT_RST_PINS HYP_DDR_MUX_OUT_PINS HYP_DDR_MUX_SEL_PINS} {
  puts $fh "$item:"
  foreach name [hyp_collection_names [set $item]] {
    puts $fh "  $name"
  }
  puts $fh ""
}
close $fh
puts "HyperBus report 000_summary -> $summary"

###############################################################################
# 0. Sanity and clock overview.
###############################################################################

hyp_run_cmd 001_check_setup "OpenSTA check_setup audit" [list check_setup -verbose]
hyp_report_clock_cmd 002_report_clocks "All clocks" [list report_clocks]
hyp_report_clock_cmd 003_clock_properties "Clock properties" [list report_clock_properties [all_clocks]]
hyp_run_cmd 004_wns "WNS by path group" [list report_wns]
hyp_run_cmd 005_tns "TNS by path group" [list report_tns]
hyp_report_checks 006_worst_setup_all "Worst setup paths, all groups" -path_delay max
hyp_report_checks 007_worst_hold_all "Worst hold paths, all groups" -path_delay min
hyp_report_checks 008_unconstrained_all "All unconstrained paths" -unconstrained -path_delay min_max

###############################################################################
# 1. Delay-line and generated clock phase probes.
###############################################################################

hyp_report_checks_expected_empty 100_tx_delay_line_setup "TX delay line Liberty-arc setup probe" \
  "The delay macro is modeled as generated-clock latency; no data timing arc is expected here." \
  -from $HYP_TX_DLINE_IN -to $HYP_TX90_PIN -path_delay max
hyp_report_checks_expected_empty 101_tx_delay_line_hold "TX delay line Liberty-arc hold probe" \
  "The delay macro is modeled as generated-clock latency; no data timing arc is expected here." \
  -from $HYP_TX_DLINE_IN -to $HYP_TX90_PIN -path_delay min
hyp_report_checks_expected_empty 102_rx_delay_line_setup "RX RWDS delay line Liberty-arc setup probe" \
  "The delay macro is modeled as generated-clock latency; no data timing arc is expected here." \
  -from $HYP_RX_DELAY_IN -to $HYP_RX_DELAY_OUT -path_delay max
hyp_report_checks_expected_empty 103_rx_delay_line_hold "RX RWDS delay line Liberty-arc hold probe" \
  "The delay macro is modeled as generated-clock latency; no data timing arc is expected here." \
  -from $HYP_RX_DELAY_IN -to $HYP_RX_DELAY_OUT -path_delay min
hyp_report_checks_expected_empty 104_rwds_pad_to_delay_in_setup_probe "RWDS pad to delay input setup probe" \
  "RWDS is modeled as a clock source at the pad core side, not as an unconstrained data path into the delay line." \
  -unconstrained -from $HYP_RWDS_IO -to $HYP_RX_DELAY_IN -path_delay max
hyp_report_checks_expected_empty 105_rwds_pad_to_delay_in_hold_probe "RWDS pad to delay input hold probe" \
  "RWDS is modeled as a clock source at the pad core side, not as an unconstrained data path into the delay line." \
  -unconstrained -from $HYP_RWDS_IO -to $HYP_RX_DELAY_IN -path_delay min

###############################################################################
# 2. RX read data path: DQ edge-aligned to RWDS, capture at delayed RWDS points.
###############################################################################

hyp_report_checks 200_rx_dq_to_capture_setup "RX DQ first-beat setup to delayed RWDS capture clock" \
  -from $HYP_DQ_IO -to [get_clocks clk_hyp_rwds_capture] -path_delay max
hyp_report_checks 201_rx_dq_to_capture_hold "RX DQ first-beat hold to delayed RWDS capture clock" \
  -from $HYP_DQ_IO -to [get_clocks clk_hyp_rwds_capture] -path_delay min
hyp_report_checks 202_rx_dq_to_sample_setup "RX DQ second-beat setup to post-inverter sample clock" \
  -from $HYP_DQ_IO -to [get_clocks clk_hyp_rwds_sample] -path_delay max
hyp_report_checks 203_rx_dq_to_sample_hold "RX DQ second-beat hold to post-inverter sample clock" \
  -from $HYP_DQ_IO -to [get_clocks clk_hyp_rwds_sample] -path_delay min
hyp_report_checks 204_rx_virtual_to_capture_setup "Virtual RWDS read launch to delayed capture setup" \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_capture] -path_delay max
hyp_report_checks 205_rx_virtual_to_capture_hold "Virtual RWDS read launch to delayed capture hold" \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_capture] -path_delay min
hyp_report_checks 206_rx_virtual_to_sample_setup "Virtual RWDS read launch to post-inverter sample setup" \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay max
hyp_report_checks 207_rx_virtual_to_sample_hold "Virtual RWDS read launch to post-inverter sample hold" \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay min

###############################################################################
# 3. RWDS latency-indicator role and RWDS-domain control.
###############################################################################

hyp_report_checks 300_rwds_latency_to_sys_setup "RWDS level sampled as additional-latency indicator setup" \
  -through $HYP_RWDS_IO -to $HYP_RWDS_SAMPLE_D -path_delay max
hyp_report_checks 301_rwds_latency_to_sys_hold "RWDS level sampled as additional-latency indicator hold" \
  -through $HYP_RWDS_IO -to $HYP_RWDS_SAMPLE_D -path_delay min
hyp_report_checks 302_rwds_gate_enable_setup "RWDS sample clock-gate enable setup, 25 percent budget" \
  -from [get_clocks clk_sys] -to $HYP_RWDS_GATE_EN -path_delay max
hyp_report_checks 303_rwds_gate_enable_hold "RWDS sample clock-gate enable hold" \
  -from [get_clocks clk_sys] -to $HYP_RWDS_GATE_EN -path_delay min
hyp_report_checks 304_rwds_clock_gate_check_setup "RWDS integrated clock-gating setup check" \
  -to $HYP_RWDS_GATE_EN -path_delay max
hyp_report_checks 305_rwds_clock_gate_check_hold "RWDS integrated clock-gating hold check" \
  -to $HYP_RWDS_GATE_EN -path_delay min
hyp_report_checks 306_tx_ck_gate_enable_setup "TX CK clock-gate enable setup, 25 percent budget" \
  -from [get_clocks clk_sys] -to $HYP_TX_CK_GATE_EN -path_delay max
hyp_report_checks 307_tx_ck_gate_enable_hold "TX CK clock-gate enable hold" \
  -from [get_clocks clk_sys] -to $HYP_TX_CK_GATE_EN -path_delay min
hyp_report_checks 308_rx_soft_reset_release_setup "RWDS soft-reset release setup, 25 percent budget" \
  -from [get_clocks clk_sys] -to $HYP_RX_SOFT_RST_PINS -path_delay max
hyp_report_checks_expected_empty 309_rx_soft_reset_release_hold "RWDS soft-reset release removal audit" \
  "The removal side is intentionally cut; report 308 is the governing soft-reset release check." \
  -from [get_clocks clk_sys] -to $HYP_RX_SOFT_RST_PINS -path_delay min

###############################################################################
# 4. RX CDC FIFO from RWDS sample clock back to clk_sys.
###############################################################################

hyp_report_checks 400_rwds_sample_to_sys_setup "RWDS sample domain to clk_sys setup" \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_sys] -path_delay max
hyp_report_checks 401_rwds_sample_to_sys_hold "RWDS sample domain to clk_sys hold" \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_sys] -path_delay min
hyp_report_checks 402_rwds_cdc_async_setup "RWDS CDC async nets setup budget" \
  -through $HYP_RWDS_CDC_ASYNC -path_delay max
hyp_report_checks 403_rwds_cdc_async_hold "RWDS CDC async nets hold budget" \
  -through $HYP_RWDS_CDC_ASYNC -path_delay min

###############################################################################
# 5. TX write/CA data, RWDS write strobe, OE, CK, CS, and reset.
###############################################################################

hyp_report_checks 500_tx_write_data_setup "TX DQ/RWDS write data setup to HyperBus CK" \
  -to $HYP_WRITE_OUT -path_delay max
hyp_report_checks 501_tx_write_data_hold "TX DQ/RWDS write data hold to HyperBus CK" \
  -to $HYP_WRITE_OUT -path_delay min
hyp_report_checks 502_tx_dq_write_setup "TX DQ-only write data setup" \
  -to $HYP_DQ_C2P -path_delay max
hyp_report_checks 503_tx_dq_write_hold "TX DQ-only write data hold" \
  -to $HYP_DQ_C2P -path_delay min
hyp_report_checks 504_tx_rwds_write_setup "TX RWDS write-strobe/data-mask setup" \
  -to $HYP_RWDS_C2P -path_delay max
hyp_report_checks 505_tx_rwds_write_hold "TX RWDS write-strobe/data-mask hold" \
  -to $HYP_RWDS_C2P -path_delay min
hyp_report_checks 506_tx_ddr_mux_to_pads_setup "TX DDR mux to pad outputs setup" \
  -through $HYP_DDR_MUX_OUT_PINS -to $HYP_WRITE_OUT -path_delay max
hyp_report_checks 507_tx_ddr_mux_to_pads_hold "TX DDR mux to pad outputs hold" \
  -through $HYP_DDR_MUX_OUT_PINS -to $HYP_WRITE_OUT -path_delay min
hyp_report_checks 508_tx_oe_setup "TX DQ/RWDS output-enable setup" \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OE -path_delay max
hyp_report_checks 509_tx_oe_hold "TX DQ/RWDS output-enable hold" \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OE -path_delay min
hyp_report_checks 510_tx_cs_setup "TX CS# setup relative to HyperBus CK" \
  -from [get_clocks clk_sys] -to $HYP_CS_OUT -path_delay max
hyp_report_checks 511_tx_cs_hold "TX CS# hold relative to HyperBus CK" \
  -from [get_clocks clk_sys] -to $HYP_CS_OUT -path_delay min
hyp_report_checks_expected_empty 512_tx90_to_ck_out_setup_probe "TX 90-degree clock to CK output probe" \
  "CK is modeled as a generated propagated clock; this data-path probe is only expected to populate if OpenSTA exposes that arc." \
  -unconstrained -from $HYP_TX90_PIN -to $HYP_CK_OUT -path_delay max
hyp_report_checks_expected_empty 513_tx90_to_ck_out_hold_probe "TX 90-degree clock to CK output probe hold" \
  "CK is modeled as a generated propagated clock; this data-path probe is only expected to populate if OpenSTA exposes that arc." \
  -unconstrained -from $HYP_TX90_PIN -to $HYP_CK_OUT -path_delay min
hyp_report_checks 514_reset_release_setup "HyperBus RESET# synchronized release setup budget" \
  -from [get_clocks clk_sys] -to $HYP_RESET_OUT -path_delay max
hyp_report_checks 515_reset_release_hold "HyperBus RESET# synchronized release min-delay audit" \
  -from [get_clocks clk_sys] -to $HYP_RESET_OUT -path_delay min

###############################################################################
# 6. Edge-filtered DDR sanity checks.
###############################################################################

hyp_report_checks 600_tx_write_rise_launch_setup "TX write rise-launch setup coverage" \
  -rise_to [get_clocks clk_hyp_ck_core] -to $HYP_WRITE_OUT -path_delay max
hyp_report_checks 601_tx_write_fall_launch_setup "TX write fall-launch setup coverage" \
  -fall_to [get_clocks clk_hyp_ck_core] -to $HYP_WRITE_OUT -path_delay max
hyp_report_checks 602_tx_write_rise_launch_hold "TX write rise-launch hold coverage" \
  -rise_to [get_clocks clk_hyp_ck_core] -to $HYP_WRITE_OUT -path_delay min
hyp_report_checks 603_tx_write_fall_launch_hold "TX write fall-launch hold coverage" \
  -fall_to [get_clocks clk_hyp_ck_core] -to $HYP_WRITE_OUT -path_delay min
hyp_report_checks 604_rx_read_rise_launch_setup "RX read virtual rise-launch setup coverage" \
  -rise_from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_capture] -path_delay max
hyp_report_checks 605_rx_read_fall_launch_setup "RX read virtual fall-launch setup coverage" \
  -fall_from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay max

###############################################################################
# 7. HyperBus-specific broad I/O audit.
###############################################################################

hyp_report_checks 700_hyperbus_inputs_audit "HyperBus input-side timing audit" \
  -from [concat $HYP_DQ_IO $HYP_RWDS_IO] -path_delay min_max
hyp_report_checks 701_hyperbus_outputs_audit "HyperBus output-side timing audit" \
  -to [concat $HYP_WRITE_OUT $HYP_CK_OUT $HYP_CKN_OUT $HYP_CS_OUT $HYP_RESET_OUT] -path_delay min_max

###############################################################################
# 8. DDR mux-select transition checks.
###############################################################################

hyp_report_checks 800_tx_ddr_mux_select_to_pads_setup "TX DDR mux select-to-pad setup" \
  -through $HYP_DDR_MUX_SEL_PINS -to $HYP_WRITE_OUT -path_delay max
hyp_report_checks 801_tx_ddr_mux_select_to_pads_hold "TX DDR mux select-to-pad hold" \
  -through $HYP_DDR_MUX_SEL_PINS -to $HYP_WRITE_OUT -path_delay min

utl::report "HyperBus report complete: $HYP_RPT_DIR"
