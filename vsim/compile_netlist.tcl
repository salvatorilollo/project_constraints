# This script was generated automatically by bender.
set ROOT ".."

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "$ROOT/rtl/common_verification/src/clk_rst_gen.sv" \
    "$ROOT/rtl/common_verification/src/sim_timeout.sv" \
    "$ROOT/rtl/common_verification/src/stream_watchdog.sv" \
    "$ROOT/rtl/common_verification/src/signal_highlighter.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "$ROOT/rtl/common_verification/src/rand_id_queue.sv" \
    "$ROOT/rtl/common_verification/src/rand_stream_mst.sv" \
    "$ROOT/rtl/common_verification/src/rand_synch_holdable_driver.sv" \
    "$ROOT/rtl/common_verification/src/rand_verif_pkg.sv" \
    "$ROOT/rtl/common_verification/src/rand_synch_driver.sv" \
    "$ROOT/rtl/common_verification/src/rand_stream_slv.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "$ROOT/rtl/common_verification/test/tb_clk_rst_gen.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "$ROOT/rtl/tech_cells_generic/tc_sram.sv" \
    "$ROOT/rtl/tech_cells_generic/tc_sram_impl.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "$ROOT/rtl/tech_cells_generic/tc_clk.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/common_cells/binary_to_gray.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/common_cells/cb_filter_pkg.sv" \
    "$ROOT/rtl/common_cells/cc_onehot.sv" \
    "$ROOT/rtl/common_cells/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/rtl/common_cells/cf_math_pkg.sv" \
    "$ROOT/rtl/common_cells/clk_int_div.sv" \
    "$ROOT/rtl/common_cells/credit_counter.sv" \
    "$ROOT/rtl/common_cells/delta_counter.sv" \
    "$ROOT/rtl/common_cells/ecc_pkg.sv" \
    "$ROOT/rtl/common_cells/edge_propagator_tx.sv" \
    "$ROOT/rtl/common_cells/exp_backoff.sv" \
    "$ROOT/rtl/common_cells/fifo_v3.sv" \
    "$ROOT/rtl/common_cells/gray_to_binary.sv" \
    "$ROOT/rtl/common_cells/heaviside.sv" \
    "$ROOT/rtl/common_cells/isochronous_4phase_handshake.sv" \
    "$ROOT/rtl/common_cells/isochronous_spill_register.sv" \
    "$ROOT/rtl/common_cells/lfsr.sv" \
    "$ROOT/rtl/common_cells/lfsr_16bit.sv" \
    "$ROOT/rtl/common_cells/lfsr_8bit.sv" \
    "$ROOT/rtl/common_cells/lossy_valid_to_stream.sv" \
    "$ROOT/rtl/common_cells/mv_filter.sv" \
    "$ROOT/rtl/common_cells/onehot_to_bin.sv" \
    "$ROOT/rtl/common_cells/plru_tree.sv" \
    "$ROOT/rtl/common_cells/passthrough_stream_fifo.sv" \
    "$ROOT/rtl/common_cells/popcount.sv" \
    "$ROOT/rtl/common_cells/ring_buffer.sv" \
    "$ROOT/rtl/common_cells/rr_arb_tree.sv" \
    "$ROOT/rtl/common_cells/rstgen_bypass.sv" \
    "$ROOT/rtl/common_cells/serial_deglitch.sv" \
    "$ROOT/rtl/common_cells/shift_reg.sv" \
    "$ROOT/rtl/common_cells/shift_reg_gated.sv" \
    "$ROOT/rtl/common_cells/spill_register_flushable.sv" \
    "$ROOT/rtl/common_cells/stream_demux.sv" \
    "$ROOT/rtl/common_cells/stream_filter.sv" \
    "$ROOT/rtl/common_cells/stream_fork.sv" \
    "$ROOT/rtl/common_cells/stream_intf.sv" \
    "$ROOT/rtl/common_cells/stream_join_dynamic.sv" \
    "$ROOT/rtl/common_cells/stream_mux.sv" \
    "$ROOT/rtl/common_cells/stream_throttle.sv" \
    "$ROOT/rtl/common_cells/sub_per_hash.sv" \
    "$ROOT/rtl/common_cells/sync.sv" \
    "$ROOT/rtl/common_cells/sync_wedge.sv" \
    "$ROOT/rtl/common_cells/unread.sv" \
    "$ROOT/rtl/common_cells/read.sv" \
    "$ROOT/rtl/common_cells/addr_decode_dync.sv" \
    "$ROOT/rtl/common_cells/boxcar.sv" \
    "$ROOT/rtl/common_cells/cdc_2phase.sv" \
    "$ROOT/rtl/common_cells/cdc_4phase.sv" \
    "$ROOT/rtl/common_cells/clk_int_div_static.sv" \
    "$ROOT/rtl/common_cells/trip_counter.sv" \
    "$ROOT/rtl/common_cells/addr_decode.sv" \
    "$ROOT/rtl/common_cells/addr_decode_napot.sv" \
    "$ROOT/rtl/common_cells/multiaddr_decode.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/common_cells/cb_filter.sv" \
    "$ROOT/rtl/common_cells/cdc_fifo_2phase.sv" \
    "$ROOT/rtl/common_cells/clk_mux_glitch_free.sv" \
    "$ROOT/rtl/common_cells/counter.sv" \
    "$ROOT/rtl/common_cells/ecc_decode.sv" \
    "$ROOT/rtl/common_cells/ecc_encode.sv" \
    "$ROOT/rtl/common_cells/edge_detect.sv" \
    "$ROOT/rtl/common_cells/lzc.sv" \
    "$ROOT/rtl/common_cells/max_counter.sv" \
    "$ROOT/rtl/common_cells/rstgen.sv" \
    "$ROOT/rtl/common_cells/spill_register.sv" \
    "$ROOT/rtl/common_cells/stream_delay.sv" \
    "$ROOT/rtl/common_cells/stream_fifo.sv" \
    "$ROOT/rtl/common_cells/stream_fork_dynamic.sv" \
    "$ROOT/rtl/common_cells/stream_join.sv" \
    "$ROOT/rtl/common_cells/cdc_reset_ctrlr.sv" \
    "$ROOT/rtl/common_cells/cdc_fifo_gray.sv" \
    "$ROOT/rtl/common_cells/fall_through_register.sv" \
    "$ROOT/rtl/common_cells/id_queue.sv" \
    "$ROOT/rtl/common_cells/stream_to_mem.sv" \
    "$ROOT/rtl/common_cells/stream_arbiter_flushable.sv" \
    "$ROOT/rtl/common_cells/stream_fifo_optimal_wrap.sv" \
    "$ROOT/rtl/common_cells/stream_register.sv" \
    "$ROOT/rtl/common_cells/stream_xbar.sv" \
    "$ROOT/rtl/common_cells/cdc_fifo_gray_clearable.sv" \
    "$ROOT/rtl/common_cells/cdc_2phase_clearable.sv" \
    "$ROOT/rtl/common_cells/mem_to_banks_detailed.sv" \
    "$ROOT/rtl/common_cells/stream_arbiter.sv" \
    "$ROOT/rtl/common_cells/stream_omega_net.sv" \
    "$ROOT/rtl/common_cells/mem_to_banks.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/apb/apb_pkg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_demux_id_counters.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_intf.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_burst_splitter_gran.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_burst_unwrap.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_bus_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_cdc_dst.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_cdc_src.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_cut.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_demux_simple.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_fifo_delay_dyn.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_id_remap.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_id_prepend.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_inval_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_mux.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_rw_join.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_rw_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_slave_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_throttle.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_detailed_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_burst_splitter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_demux.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_from_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_id_serialize.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lfsr.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_multicut.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_zero_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_interleaved_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_xbar_unmuxed.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_mem_interleaved.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_to_mem_split.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_xp.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_chan_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_dumper.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/src/axi_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_dw_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_xbar_pkg.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_addr_test.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_atop_filter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_bus_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_cdc.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_delayer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_dw_downsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_dw_upsizer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_fifo.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_isolate.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_dw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_mailbox.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_regs.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_iw_converter.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_lite_xbar.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_modify_address.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_serializer.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_sim_mem.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_slave_compare.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_to_axi_lite.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_to_mem_banked.sv" \
    "$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/test/tb_axi_xbar.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/obi/obi_pkg.sv" \
    "$ROOT/rtl/obi/obi_intf.sv" \
    "$ROOT/rtl/obi/obi_rready_converter.sv" \
    "$ROOT/rtl/obi/apb_to_obi.sv" \
    "$ROOT/rtl/obi/obi_to_apb.sv" \
    "$ROOT/rtl/obi/obi_atop_resolver.sv" \
    "$ROOT/rtl/obi/obi_cut.sv" \
    "$ROOT/rtl/obi/obi_demux.sv" \
    "$ROOT/rtl/obi/obi_err_sbr.sv" \
    "$ROOT/rtl/obi/obi_mux.sv" \
    "$ROOT/rtl/obi/obi_sram_shim.sv" \
    "$ROOT/rtl/obi/obi_xbar.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_intf.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/vendor/lowrisc_opentitan/src/prim_subreg_arb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/vendor/lowrisc_opentitan/src/prim_subreg_ext.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/apb_to_reg_v2.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/axi_lite_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/axi_to_reg_v2.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/periph_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_cdc.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_cut.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_demux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_err_slv.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_filter_empty_writes.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_mux.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_to_apb.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_to_tlul.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_to_axi.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_uniform.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/vendor/lowrisc_opentitan/src/prim_subreg_shadow.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/vendor/lowrisc_opentitan/src/prim_subreg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/deprecated/apb_to_reg.sv" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/deprecated/axi_to_reg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/src/reg_test.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/.bender/git/checkouts/axi_obi-7b5474ddc0a2b9f4/src/axi_to_detailed_mem_user.sv" \
    "$ROOT/.bender/git/checkouts/axi_obi-7b5474ddc0a2b9f4/src/axi_to_obi.sv" \
    "$ROOT/.bender/git/checkouts/axi_obi-7b5474ddc0a2b9f4/src/obi_to_axi.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/cve2/include" \
    "$ROOT/rtl/cve2/cve2_pkg.sv" \
    "$ROOT/rtl/cve2/cve2_alu.sv" \
    "$ROOT/rtl/cve2/cve2_branch_predict.sv" \
    "$ROOT/rtl/cve2/cve2_compressed_decoder.sv" \
    "$ROOT/rtl/cve2/cve2_controller.sv" \
    "$ROOT/rtl/cve2/cve2_counter.sv" \
    "$ROOT/rtl/cve2/cve2_csr.sv" \
    "$ROOT/rtl/cve2/cve2_decoder.sv" \
    "$ROOT/rtl/cve2/cve2_fetch_fifo.sv" \
    "$ROOT/rtl/cve2/cve2_load_store_unit.sv" \
    "$ROOT/rtl/cve2/cve2_multdiv_fast.sv" \
    "$ROOT/rtl/cve2/cve2_multdiv_slow.sv" \
    "$ROOT/rtl/cve2/cve2_pmp.sv" \
    "$ROOT/rtl/cve2/cve2_register_file_ff.sv" \
    "$ROOT/rtl/cve2/cve2_wb.sv" \
    "$ROOT/rtl/cve2/cve2_cs_registers.sv" \
    "$ROOT/rtl/cve2/cve2_ex_block.sv" \
    "$ROOT/rtl/cve2/cve2_id_stage.sv" \
    "$ROOT/rtl/cve2/cve2_prefetch_buffer.sv" \
    "$ROOT/rtl/cve2/cve2_if_stage.sv" \
    "$ROOT/rtl/cve2/cve2_core.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+RVFI=true" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/cve2/include" \
    "$ROOT/rtl/cve2/cve2_tracer_pkg.sv" \
    "$ROOT/rtl/cve2/cve2_tracer.sv" \
    "$ROOT/rtl/cve2/cve2_core_tracing.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/models/configurable_delay.behav.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_delay.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_tx_clk_delay.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_pkg.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_clk_gen.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_clock_diff_out.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_w2phy.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_phy2r.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_ddr_out.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_trx.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_cfg_regs.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_phy.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_phy_if.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_axi.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_frontend.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_async_bridge.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_iso_bridge.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_backend.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_synchronous.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_asynchronous.sv" \
    "$ROOT/.bender/git/checkouts/hyperbus-d20b59e5a581ace5/src/hyperbus_isochronous.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/idma/idma_pkg.sv" \
    "$ROOT/rtl/idma/idma_channel_coupler.sv" \
    "$ROOT/rtl/idma/idma_dataflow_element.sv" \
    "$ROOT/rtl/idma/idma_obi_read.sv" \
    "$ROOT/rtl/idma/idma_obi_write.sv" \
    "$ROOT/rtl/idma/idma_init_read.sv" \
    "$ROOT/rtl/idma/idma_init_write.sv" \
    "$ROOT/rtl/idma/idma_nd_midend.sv" \
    "$ROOT/rtl/idma/idma_transfer_id_gen.sv" \
    "$ROOT/rtl/idma/idma_legalizer_page_splitter.sv" \
    "$ROOT/rtl/idma/idma_transport_layer_rw_obi.sv" \
    "$ROOT/rtl/idma/idma_transport_layer_r_obi_w_init.sv" \
    "$ROOT/rtl/idma/idma_legalizer_rw_obi.sv" \
    "$ROOT/rtl/idma/idma_legalizer_r_obi_w_init.sv" \
    "$ROOT/rtl/idma/idma_backend_rw_obi.sv" \
    "$ROOT/rtl/idma/idma_backend_r_obi_w_init.sv" \
    "$ROOT/rtl/idma/croc_idma.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/obi_uart/obi_uart_pkg.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_baudgen.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_interrupts.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_modem.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_rx.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_tx.sv" \
    "$ROOT/rtl/obi_uart/obi_uart_register.sv" \
    "$ROOT/rtl/obi_uart/obi_uart.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/dm_pkg.sv" \
    "$ROOT/rtl/riscv-dbg/debug_rom/debug_rom.sv" \
    "$ROOT/rtl/riscv-dbg/debug_rom/debug_rom_one_scratch.sv" \
    "$ROOT/rtl/riscv-dbg/dm_csrs.sv" \
    "$ROOT/rtl/riscv-dbg/dm_mem.sv" \
    "$ROOT/rtl/riscv-dbg/dmi_cdc.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/dmi_jtag_tap.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/dm_sba.sv" \
    "$ROOT/rtl/riscv-dbg/dm_top.sv" \
    "$ROOT/rtl/riscv-dbg/dmi_jtag.sv" \
    "$ROOT/rtl/riscv-dbg/dm_obi_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/dmi_test.sv" \
    "$ROOT/rtl/riscv-dbg/tb/jtag_test_simple.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/dmi_intf.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "$ROOT/rtl/riscv-dbg/tb/jtag_test_simple.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/ihp13/tc_clk.sv" \
    "$ROOT/ihp13/tc_sram_impl.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/croc_pkg.sv" \
    "$ROOT/rtl/user_pkg.sv" \
    "$ROOT/rtl/soc_ctrl/soc_ctrl_regs_pkg.sv" \
    "$ROOT/rtl/gpio/gpio_reg_pkg.sv" \
    "$ROOT/rtl/clint/clint_reg_pkg.sv" \
    "$ROOT/rtl/obi_timer/obi_timer_reg_pkg.sv" \
    "$ROOT/rtl/neopixel/neopixel_pkg.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/croc_chip.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/yosys/out/netlist_debug.v" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat \
    "+define+TARGET_IHP13" \
    "+define+TARGET_NETLIST_YOSYS" \
    "+define+TARGET_SIMULATION" \
    "+define+TARGET_TEST" \
    "+define+TARGET_VERILATOR" \
    "+define+TARGET_VSIM" \
    "+define+SYNTHESIS" \
    "+define+SIMULATION" \
    "+incdir+$ROOT/.bender/git/checkouts/axi-4ecab47b5e77b28c/include" \
    "+incdir+$ROOT/.bender/git/checkouts/register_interface-8146d26ca39e5d02/include" \
    "+incdir+$ROOT/rtl/apb/include" \
    "+incdir+$ROOT/rtl/common_cells/include" \
    "+incdir+$ROOT/rtl/idma/include" \
    "+incdir+$ROOT/rtl/obi/include" \
    "$ROOT/rtl/test/tb_croc_pkg.sv" \
    "$ROOT/rtl/test/croc_vip.sv" \
    "$ROOT/rtl/test/tb_croc_soc.sv" \
    "$ROOT/rtl/test/neopixel_monitor.sv" \
    "$ROOT/rtl/test/tb_hyperbus_croc_soc.sv" \
    "$ROOT/rtl/models/s27ks0641/s27ks0641.v" \
    "$ROOT/rtl/riscv-dbg/tb/jtag_test_simple.sv" \
}]} {return 1}

