# HyperBus synchronous PHY timing report deck for OpenSTA/OpenROAD.
# Source this AFTER loading/linking the netlist, reading parasitics, and sourcing
# constraints_hyperbus_synchronous.sdc.
#
# OpenSTA/OpenROAD report command is report_checks.  Synopsys PrimeTime's
# equivalent command name is report_timing.
#
# The deck writes one report per check to ./hyperbus_sta_reports/.
# For OpenSTA/OpenROAD older than the 2024/2025 option rename, the helper below
# automatically falls back from:
#   -group_path_count    -> -group_count
#   -endpoint_path_count -> -endpoint_count

set HYP_RPT_DIR hyperbus_sta_reports
file mkdir $HYP_RPT_DIR

set HYP_RPT_FORMAT full_clock_expanded
set HYP_RPT_FIELDS {capacitance slew input_pins nets fanout}
set HYP_RPT_DIGITS 4
set HYP_RPT_GROUP_PATH_COUNT 200
set HYP_RPT_ENDPOINT_PATH_COUNT 4

proc hyp_try_run {tag cmd} {
  global HYP_RPT_DIR
  set rpt [file join $HYP_RPT_DIR ${tag}.rpt]
  puts "\n### $tag -> $rpt"

  # First try modern OpenSTA option names.
  set cmd1 $cmd
  lappend cmd1 > $rpt
  if {![catch {uplevel 1 $cmd1} msg]} {
    return
  }

  # Fall back to older option names if report_checks rejected the new names.
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
  lappend cmd2 > $rpt
  if {[catch {uplevel 1 $cmd2} msg2]} {
    puts "WARNING: $tag failed."
    puts "  first error : $msg"
    puts "  retry error : $msg2"
  }
}

proc hyp_report_checks {tag args} {
  global HYP_RPT_FORMAT HYP_RPT_FIELDS HYP_RPT_DIGITS
  global HYP_RPT_GROUP_PATH_COUNT HYP_RPT_ENDPOINT_PATH_COUNT

  set cmd [list report_checks]
  lappend cmd -format $HYP_RPT_FORMAT
  lappend cmd -fields $HYP_RPT_FIELDS
  lappend cmd -digits $HYP_RPT_DIGITS
  lappend cmd -sort_by_slack
  lappend cmd -group_path_count $HYP_RPT_GROUP_PATH_COUNT
  lappend cmd -endpoint_path_count $HYP_RPT_ENDPOINT_PATH_COUNT
  foreach a $args { lappend cmd $a }
  hyp_try_run $tag $cmd
}

proc hyp_run_cmd {tag args} {
  set cmd {}
  foreach a $args { lappend cmd $a }
  hyp_try_run $tag $cmd
}

proc hyp_size {obj} {
  if {[catch {sizeof_collection $obj} n]} {
    return 0
  }
  return $n
}

proc hyp_nonempty {obj} {
  expr {[hyp_size $obj] > 0}
}

proc hyp_report_if {cond tag args} {
  if {$cond} {
    hyp_report_checks $tag {*}$args
  } else {
    puts "\n### SKIP $tag: empty object collection"
  }
}

proc hyp_run_if {cond tag args} {
  if {$cond} {
    hyp_run_cmd $tag {*}$args
  } else {
    puts "\n### SKIP $tag: empty object collection"
  }
}

proc hyp_clocks_exist {clock_names} {
  foreach clk $clock_names {
    if {[hyp_size [get_clocks -quiet $clk]] == 0} {
      return 0
    }
  }
  return 1
}

# Rebuild the same report collections used by the SDC, so this report deck also
# works if the SDC was read in a different Tcl scope.
set HYP_DQ_IN      [get_ports -quiet -filter {direction==in  && name=~hyper_dq_i*}]
set HYP_RWDS_IN    [get_ports -quiet -filter {direction==in  && name=~hyper_rwds_i*}]

set HYP_DQ_OUT     [get_ports -quiet -filter {direction==out && name=~hyper_dq_o* && !(name=~hyper_dq_oe_o*)}]
set HYP_RWDS_OUT   [get_ports -quiet -filter {direction==out && name=~hyper_rwds_o* && !(name=~hyper_rwds_oe_o*)}]
set HYP_WRITE_OUT  [get_ports -quiet -filter {direction==out && ((name=~hyper_dq_o* && !(name=~hyper_dq_oe_o*)) || (name=~hyper_rwds_o* && !(name=~hyper_rwds_oe_o*)))}]
set HYP_WRITE_OE   [get_ports -quiet -filter {direction==out && (name=~hyper_dq_oe_o* || name=~hyper_rwds_oe_o*)}]

set HYP_CK_OUT     [get_ports -quiet -filter {direction==out && name=~hyper_ck_o*}]
set HYP_CKN_OUT    [get_ports -quiet -filter {direction==out && name=~hyper_ck_no*}]
set HYP_CS_OUT     [get_ports -quiet -filter {direction==out && name=~hyper_cs_no*}]
set HYP_RESET_OUT  [get_ports -quiet -filter {direction==out && name=~hyper_reset_no*}]

set HYP_TX90_PIN [get_pins -quiet {
  i_tx_clk_delay/i_delay_tx_clk_90/out_o
  i_tx_clk_delay/out_o
}]

set HYP_RX_DELAY_IN [get_pins -quiet {
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/i_delay_rx_rwds_90/in_i
  i_backend/i_phy/i_phy/i_trx/i_delay_rx_rwds_90/in_i
}]

set HYP_RX_SAMPLE_CLK [get_pins -quiet {
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/i_delay_rx_rwds_90/out_o
  i_backend/i_phy/i_phy/i_trx/i_delay_rx_rwds_90/out_o
}]

set HYP_RWDS_GATE_EN [get_pins -quiet {
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/i_rwds_in_clk_gate/en_i
  i_backend/i_phy/i_phy/i_trx/i_rwds_in_clk_gate/en_i
}]

set HYP_RWDS_CDC_ASYNC [get_nets -quiet {
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/i_rx_rwds_cdc_fifo/async*
  i_backend/i_phy/i_phy/i_trx/i_rx_rwds_cdc_fifo/async*
}]

set HYP_DDR_MUX_CELLS [get_cells -quiet {
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/gen_ddr_tx_data*/i_ddr_tx_data/i_ddrmux*
  i_backend/i_phy/phy_wrap/phy_unroll*/i_phy/i_trx/i_ddr_tx_rwds/i_ddrmux*
  i_backend/i_phy/i_phy/i_trx/gen_ddr_tx_data*/i_ddr_tx_data/i_ddrmux*
  i_backend/i_phy/i_phy/i_trx/i_ddr_tx_rwds/i_ddrmux*
}]

set HYP_DATA_IN  [add_to_collection $HYP_DQ_IN $HYP_RWDS_IN]
set HYP_DATA_OUT [add_to_collection $HYP_DQ_OUT $HYP_RWDS_OUT]

puts "\n### HyperBus STA report collection sizes"
puts "HYP_DQ_IN           [hyp_size $HYP_DQ_IN]"
puts "HYP_RWDS_IN         [hyp_size $HYP_RWDS_IN]"
puts "HYP_DQ_OUT          [hyp_size $HYP_DQ_OUT]"
puts "HYP_RWDS_OUT        [hyp_size $HYP_RWDS_OUT]"
puts "HYP_WRITE_OUT       [hyp_size $HYP_WRITE_OUT]"
puts "HYP_WRITE_OE        [hyp_size $HYP_WRITE_OE]"
puts "HYP_CK_OUT          [hyp_size $HYP_CK_OUT]"
puts "HYP_CS_OUT          [hyp_size $HYP_CS_OUT]"
puts "HYP_RESET_OUT       [hyp_size $HYP_RESET_OUT]"
puts "HYP_TX90_PIN        [hyp_size $HYP_TX90_PIN]"
puts "HYP_RX_DELAY_IN     [hyp_size $HYP_RX_DELAY_IN]"
puts "HYP_RX_SAMPLE_CLK   [hyp_size $HYP_RX_SAMPLE_CLK]"
puts "HYP_RWDS_GATE_EN    [hyp_size $HYP_RWDS_GATE_EN]"
puts "HYP_RWDS_CDC_ASYNC  [hyp_size $HYP_RWDS_CDC_ASYNC]"
puts "HYP_DDR_MUX_CELLS   [hyp_size $HYP_DDR_MUX_CELLS]"

###############################################################################
# 0. Global sanity and unconstrained-path checks.
###############################################################################

hyp_run_cmd 000_units report_units

if {[llength [info commands check_setup]] > 0} {
  hyp_run_cmd 001_check_setup check_setup
}

if {[llength [info commands report_clocks]] > 0} {
  hyp_run_cmd 002_clocks report_clocks
}

if {[llength [info commands report_clock_properties]] > 0} {
  hyp_run_cmd 003_clock_properties report_clock_properties [all_clocks]
}

hyp_report_checks 004_worst_setup_all -path_delay max
hyp_report_checks 005_worst_hold_all  -path_delay min
hyp_report_checks 006_unconstrained_all -unconstrained -path_delay min_max

if {[llength [info commands report_wns]] > 0} {
  hyp_run_cmd 007_wns_setup report_wns -max -digits $HYP_RPT_DIGITS
  hyp_run_cmd 008_wns_hold  report_wns -min -digits $HYP_RPT_DIGITS
}

if {[llength [info commands report_tns]] > 0} {
  hyp_run_cmd 009_tns_setup report_tns -max -digits $HYP_RPT_DIGITS
  hyp_run_cmd 010_tns_hold  report_tns -min -digits $HYP_RPT_DIGITS
}

if {[llength [info commands report_check_types]] > 0} {
  hyp_run_cmd 011_check_type_violators report_check_types \
    -max_slew -max_capacitance -max_fanout -min_pulse_width -violators
}

if {[llength [info commands report_disabled_edges]] > 0} {
  hyp_run_cmd 012_disabled_edges report_disabled_edges
}

###############################################################################
# 1. Shortest/longest paths from all HyperBus input data pads and RWDS.
###############################################################################

hyp_report_if [hyp_nonempty $HYP_DQ_IN] \
  100_dq_in_to_any_setup \
  -from $HYP_DQ_IN -path_delay max

hyp_report_if [hyp_nonempty $HYP_DQ_IN] \
  101_dq_in_to_any_hold \
  -from $HYP_DQ_IN -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_sample}]}] \
  102_dq_in_to_rwds_sample_setup \
  -from $HYP_DQ_IN -to [get_clocks clk_hyp_rwds_sample] -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_sample}]}] \
  103_dq_in_to_rwds_sample_hold \
  -from $HYP_DQ_IN -to [get_clocks clk_hyp_rwds_sample] -path_delay min

hyp_report_if [hyp_nonempty $HYP_RWDS_IN] \
  104_rwds_in_to_any_setup \
  -from $HYP_RWDS_IN -path_delay max

hyp_report_if [hyp_nonempty $HYP_RWDS_IN] \
  105_rwds_in_to_any_hold \
  -from $HYP_RWDS_IN -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_IN] && [hyp_clocks_exist {clk_sys}]}] \
  106_rwds_latency_level_to_sys_setup \
  -from $HYP_RWDS_IN -to [get_clocks clk_sys] -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_IN] && [hyp_clocks_exist {clk_sys}]}] \
  107_rwds_latency_level_to_sys_hold \
  -from $HYP_RWDS_IN -to [get_clocks clk_sys] -path_delay min

hyp_report_if [hyp_nonempty $HYP_DATA_IN] \
  108_all_data_in_unconstrained \
  -unconstrained -from $HYP_DATA_IN -path_delay min_max

###############################################################################
# 2. Shortest/longest paths to all HyperBus output data pads and RWDS.
###############################################################################

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  200_sys_to_dq_out_setup \
  -from [get_clocks clk_sys] -to $HYP_DQ_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  201_sys_to_dq_out_hold \
  -from [get_clocks clk_sys] -to $HYP_DQ_OUT -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  202_sys_to_rwds_out_setup \
  -from [get_clocks clk_sys] -to $HYP_RWDS_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  203_sys_to_rwds_out_hold \
  -from [get_clocks clk_sys] -to $HYP_RWDS_OUT -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_hyp_ck_out}]}] \
  204_write_out_ck_setup \
  -to $HYP_WRITE_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_hyp_ck_out}]}] \
  205_write_out_ck_hold \
  -to $HYP_WRITE_OUT -path_delay min

hyp_report_if [hyp_nonempty $HYP_DATA_OUT] \
  206_all_data_out_unconstrained \
  -unconstrained -to $HYP_DATA_OUT -path_delay min_max

###############################################################################
# 3. RWDS path up to the RWDS delay line and generated sample clock.
###############################################################################

# These reports are intentionally unconstrained.  They are meant to expose the
# raw routed path from the RWDS input pad/port to the delay-line input pin, which
# is usually an internal probe point rather than a normal timing endpoint.
hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_IN] && [hyp_nonempty $HYP_RX_DELAY_IN]}] \
  300_rwds_pad_to_delay_in_longest_probe \
  -unconstrained -from $HYP_RWDS_IN -to $HYP_RX_DELAY_IN -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_IN] && [hyp_nonempty $HYP_RX_DELAY_IN]}] \
  301_rwds_pad_to_delay_in_shortest_probe \
  -unconstrained -from $HYP_RWDS_IN -to $HYP_RX_DELAY_IN -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_RX_SAMPLE_CLK] && [hyp_clocks_exist {clk_hyp_rwds_sample}]}] \
  302_rwds_sample_clock_pin_to_sinks_setup \
  -from $HYP_RX_SAMPLE_CLK -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RX_SAMPLE_CLK] && [hyp_clocks_exist {clk_hyp_rwds_sample}]}] \
  303_rwds_sample_clock_pin_to_sinks_hold \
  -from $HYP_RX_SAMPLE_CLK -path_delay min

if {[llength [info commands report_clock_latency]] > 0} {
  hyp_run_if [hyp_clocks_exist {clk_hyp_rwds_sample}] \
    304_clock_latency_rwds_sample \
    report_clock_latency -clock [get_clocks clk_hyp_rwds_sample]

  hyp_run_if [hyp_clocks_exist {clk_hyp_rwds_edge}] \
    305_clock_latency_rwds_edge \
    report_clock_latency -clock [get_clocks clk_hyp_rwds_edge]
}

if {[llength [info commands report_clock_skew]] > 0} {
  hyp_run_if [hyp_clocks_exist {clk_hyp_rwds_sample}] \
    306_clock_skew_rwds_sample_setup \
    report_clock_skew -setup -clock [get_clocks clk_hyp_rwds_sample] -digits $HYP_RPT_DIGITS

  hyp_run_if [hyp_clocks_exist {clk_hyp_rwds_sample}] \
    307_clock_skew_rwds_sample_hold \
    report_clock_skew -hold -clock [get_clocks clk_hyp_rwds_sample] -digits $HYP_RPT_DIGITS
}

###############################################################################
# 4. All paths after the delayed RWDS sample clock.
###############################################################################

hyp_report_if [hyp_clocks_exist {clk_hyp_rwds_sample}] \
  400_rwds_sample_domain_internal_setup \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_hyp_rwds_sample] -path_delay max

hyp_report_if [hyp_clocks_exist {clk_hyp_rwds_sample}] \
  401_rwds_sample_domain_internal_hold \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_hyp_rwds_sample] -path_delay min

hyp_report_if [expr {[hyp_clocks_exist {clk_hyp_rwds_sample clk_sys}]}] \
  402_rwds_sample_to_sys_setup \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_sys] -path_delay max

hyp_report_if [expr {[hyp_clocks_exist {clk_hyp_rwds_sample clk_sys}]}] \
  403_rwds_sample_to_sys_hold \
  -from [get_clocks clk_hyp_rwds_sample] -to [get_clocks clk_sys] -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_CDC_ASYNC] && [hyp_clocks_exist {clk_hyp_rwds_sample clk_sys}]}] \
  404_rwds_cdc_async_setup \
  -from [get_clocks clk_hyp_rwds_sample] -through $HYP_RWDS_CDC_ASYNC -to [get_clocks clk_sys] -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RWDS_CDC_ASYNC] && [hyp_clocks_exist {clk_hyp_rwds_sample clk_sys}]}] \
  405_rwds_cdc_async_hold \
  -from [get_clocks clk_hyp_rwds_sample] -through $HYP_RWDS_CDC_ASYNC -to [get_clocks clk_sys] -path_delay min

hyp_report_if [hyp_nonempty $HYP_RWDS_GATE_EN] \
  406_rwds_gate_enable_setup \
  -through $HYP_RWDS_GATE_EN -path_delay max

hyp_report_if [hyp_nonempty $HYP_RWDS_GATE_EN] \
  407_rwds_gate_enable_hold \
  -through $HYP_RWDS_GATE_EN -path_delay min

###############################################################################
# 5. DDR-specific read and write edge coverage.
###############################################################################

# DDR read input: HyperRAM launches DQ from the virtual RWDS read clock and the
# PHY captures with the delayed RWDS sample clock.
hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_read_virt clk_hyp_rwds_sample}]}] \
  500_ddr_read_dq_setup \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_read_virt clk_hyp_rwds_sample}]}] \
  501_ddr_read_dq_hold \
  -from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_read_virt clk_hyp_rwds_sample}]}] \
  502_ddr_read_dq_rise_launch_setup \
  -rise_from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_DQ_IN] && [hyp_clocks_exist {clk_hyp_rwds_read_virt clk_hyp_rwds_sample}]}] \
  503_ddr_read_dq_fall_launch_setup \
  -fall_from [get_clocks clk_hyp_rwds_read_virt] -to [get_clocks clk_hyp_rwds_sample] -path_delay max

# DDR write output: DQ and RWDS are launched from clk_sys and checked at CK.
hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys clk_hyp_ck_out}]}] \
  504_ddr_write_data_setup \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys clk_hyp_ck_out}]}] \
  505_ddr_write_data_hold \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_DDR_MUX_CELLS] && [hyp_nonempty $HYP_WRITE_OUT]}] \
  506_ddr_tx_mux_to_pads_setup \
  -through $HYP_DDR_MUX_CELLS -to $HYP_WRITE_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_DDR_MUX_CELLS] && [hyp_nonempty $HYP_WRITE_OUT]}] \
  507_ddr_tx_mux_to_pads_hold \
  -through $HYP_DDR_MUX_CELLS -to $HYP_WRITE_OUT -path_delay min

# Explicit rise/fall launch filters.  These help confirm the DDR muxes expose both
# halves of the write datapath.  The SDC false paths decide which launch/capture
# edge pair is valid; these reports should therefore not show the cut edge pair as
# the active worst path.
hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  508_ddr_write_rise_launch_setup \
  -rise_from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  509_ddr_write_fall_launch_setup \
  -fall_from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  510_ddr_write_rise_launch_hold \
  -rise_from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  511_ddr_write_fall_launch_hold \
  -fall_from [get_clocks clk_sys] -to $HYP_WRITE_OUT -path_delay min

###############################################################################
# 6. CK generation, controls, reset passthrough, and misc forgotten corners.
###############################################################################

hyp_report_if [expr {[hyp_nonempty $HYP_TX90_PIN] && [hyp_clocks_exist {clk_sys}]}] \
  600_clk_sys_to_tx90_probe_setup \
  -unconstrained -from [get_clocks clk_sys] -to $HYP_TX90_PIN -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_TX90_PIN] && [hyp_clocks_exist {clk_sys}]}] \
  601_clk_sys_to_tx90_probe_hold \
  -unconstrained -from [get_clocks clk_sys] -to $HYP_TX90_PIN -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_CK_OUT] && [hyp_clocks_exist {clk_hyp_tx_90}]}] \
  602_tx90_to_ck_out_setup \
  -unconstrained -from [get_clocks clk_hyp_tx_90] -to $HYP_CK_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_CK_OUT] && [hyp_clocks_exist {clk_hyp_tx_90}]}] \
  603_tx90_to_ck_out_hold \
  -unconstrained -from [get_clocks clk_hyp_tx_90] -to $HYP_CK_OUT -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OE] && [hyp_clocks_exist {clk_sys}]}] \
  604_write_oe_setup \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OE -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_WRITE_OE] && [hyp_clocks_exist {clk_sys}]}] \
  605_write_oe_hold \
  -from [get_clocks clk_sys] -to $HYP_WRITE_OE -path_delay min

hyp_report_if [expr {[hyp_nonempty $HYP_CS_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  606_cs_out_setup \
  -from [get_clocks clk_sys] -to $HYP_CS_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_CS_OUT] && [hyp_clocks_exist {clk_sys}]}] \
  607_cs_out_hold \
  -from [get_clocks clk_sys] -to $HYP_CS_OUT -path_delay min

set HYP_RST_IN [get_ports -quiet rst_sys_ni]
hyp_report_if [expr {[hyp_nonempty $HYP_RST_IN] && [hyp_nonempty $HYP_RESET_OUT]}] \
  608_reset_passthrough_setup \
  -from $HYP_RST_IN -to $HYP_RESET_OUT -path_delay max

hyp_report_if [expr {[hyp_nonempty $HYP_RST_IN] && [hyp_nonempty $HYP_RESET_OUT]}] \
  609_reset_passthrough_hold \
  -from $HYP_RST_IN -to $HYP_RESET_OUT -path_delay min

set HYP_TEST_MODE [get_ports -quiet test_mode_i]
hyp_report_if [expr {[hyp_nonempty $HYP_TEST_MODE] && [hyp_clocks_exist {clk_sys}]}] \
  610_test_mode_to_sys_setup \
  -from $HYP_TEST_MODE -to [get_clocks clk_sys] -path_delay max

# Top-level all-I/O sweeps catch accidental missed I/O constraints after pad wrap.
# They are intentionally broad and should be noisy only if the constraint mapping
# is incomplete.
hyp_report_checks 700_all_inputs_unconstrained  -unconstrained -from [all_inputs]  -path_delay min_max
hyp_report_checks 701_all_outputs_unconstrained -unconstrained -to   [all_outputs] -path_delay min_max

puts "\n### HyperBus STA report deck complete. Reports are in $HYP_RPT_DIR/"