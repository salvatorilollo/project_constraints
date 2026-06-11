// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Andrea Rosetti
// (Adapted from tb_croc_soc.sv by Philippe Sauter)

`define TRACE_WAVE

`timescale 1ps/1ps

module tb_hyperbus_croc_soc #(
  parameter int unsigned GpioCount = 19   // matches croc_chip's GpioCount
);

  import tb_croc_pkg::*;

  // --------------------------------------------------------------------------
  // Signals fully controlled by the VIP
  // --------------------------------------------------------------------------
  logic rst_n;
  logic sys_clk;
  logic ref_clk;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

  logic uart_rx;
  logic uart_tx;

  // GPIOs (split-direction, as croc_soc exposes them)
  logic [GpioCount-1:0] gpio_in;
  logic [GpioCount-1:0] gpio_out;
  logic [GpioCount-1:0] gpio_out_en;

  // NeoPixel — instantiated but unused for HyperBus testing
  logic neopixel_data;

  // --------------------------------------------------------------------------
  // HyperBus controller-level split signals (croc_soc exposes these)
  // --------------------------------------------------------------------------
  logic       hyper_reset_no;
  logic       hyper_cs_no;
  logic       hyper_ck_o;
  logic       hyper_ck_no;
  logic       hyper_rwds_o;
  logic       hyper_rwds_i;
  logic       hyper_rwds_oe_o;
  logic [7:0] hyper_dq_o;
  logic [7:0] hyper_dq_i;
  logic       hyper_dq_oe_o;

  // --------------------------------------------------------------------------
  // Pin-level bidirectional signals (what HyperRAM model expects)
  // --------------------------------------------------------------------------
  wire        hyper_rwds_pin;
  wire [7:0]  hyper_dq_pin;

  // HyperRAM convention: external pull-up on RWDS when nothing drives it
  pullup(hyper_rwds_pin);

  // --------------------------------------------------------------------------
  // Bidirectional glue: emulate pad-cell behavior at the testbench level
  // When OE=1, drive the pin from the controller's output
  // When OE=0, the pin is tri-stated; controller reads via _i signal
  // --------------------------------------------------------------------------

  // RWDS bidirectional glue
  assign hyper_rwds_pin = hyper_rwds_oe_o ? hyper_rwds_o : 1'bz;
  assign hyper_rwds_i   = hyper_rwds_pin;

  // DQ[7:0] bidirectional glue
  genvar i;
  generate
    for (i = 0; i < 8; i++) begin : gen_dq_glue
      assign hyper_dq_pin[i] = hyper_dq_oe_o ? hyper_dq_o[i] : 1'bz;
      assign hyper_dq_i[i]   = hyper_dq_pin[i];
    end
  endgenerate

  // --------------------------------------------------------------------------
  // Command line argument: which binary to run
  // --------------------------------------------------------------------------
  string binary_path;

  initial begin
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Defaulting to hyperbus.");
      binary_path = "../sw/bin/hyperbus.hex";
    end
  end

  // --------------------------------------------------------------------------
  // VIP: drives clocks, reset, JTAG, UART, GPIO
  // --------------------------------------------------------------------------
  croc_vip #(
    .GpioCount ( GpioCount )
  ) i_vip (
    .rst_no        ( rst_n       ),
    .sys_clk_o     ( sys_clk     ),
    .ref_clk_o     ( ref_clk     ),
    .jtag_tck_o    ( jtag_tck    ),
    .jtag_trst_no  ( jtag_trst_n ),
    .jtag_tms_o    ( jtag_tms    ),
    .jtag_tdi_o    ( jtag_tdi    ),
    .jtag_tdo_i    ( jtag_tdo    ),
    .uart_rx_o     ( uart_rx     ),
    .uart_tx_i     ( uart_tx     ),
    .gpio_out_en_i ( gpio_out_en ),
    .gpio_out_i    ( gpio_out    ),
    .gpio_in_o     ( gpio_in     )
  );

  // --------------------------------------------------------------------------
  // DUT: croc_soc (skips pad cells; we connect controller-level signals)
  // --------------------------------------------------------------------------
  croc_soc #(
    .GpioCount ( GpioCount )
  ) i_croc_soc (
    .clk_i         ( sys_clk     ),
    .rst_ni        ( rst_n       ),
    .ref_clk_i     ( ref_clk     ),
    .testmode_i    ( 1'b0        ),
    .status_o      (             ),

    .jtag_tck_i    ( jtag_tck    ),
    .jtag_tdi_i    ( jtag_tdi    ),
    .jtag_tdo_o    ( jtag_tdo    ),
    .jtag_tms_i    ( jtag_tms    ),
    .jtag_trst_ni  ( jtag_trst_n ),

    .uart_rx_i     ( uart_rx     ),
    .uart_tx_o     ( uart_tx     ),

    .gpio_i        ( gpio_in     ),
    .gpio_o        ( gpio_out    ),
    .gpio_out_en_o ( gpio_out_en ),

    // HyperBus — controller-level split signals
    .hyper_reset_no  ( hyper_reset_no  ),
    .hyper_cs_no     ( hyper_cs_no     ),
    .hyper_ck_o      ( hyper_ck_o      ),
    .hyper_ck_no     ( hyper_ck_no     ),
    .hyper_rwds_o    ( hyper_rwds_o    ),
    .hyper_rwds_i    ( hyper_rwds_i    ),
    .hyper_rwds_oe_o ( hyper_rwds_oe_o ),
    .hyper_dq_i      ( hyper_dq_i      ),
    .hyper_dq_o      ( hyper_dq_o      ),
    .hyper_dq_oe_o   ( hyper_dq_oe_o   ),

    .neopixel_data_o ( neopixel_data )
  );

  // --------------------------------------------------------------------------
  // HyperRAM model: Cypress/Infineon S27KS0641 (8 MB)
  // - Bidirectional pins (DQ, RWDS) connect to the pin-level signals
  // - Output-only signals (CK, CSn, RESETn) connect directly to controller
  // - Verify the actual port names against the model file:
  //     head -50 .bender/git/checkouts/hyperbus-*/models/s27ks0641/s27ks0641.v
  // --------------------------------------------------------------------------
  s27ks0641 #(
  .TimingModel ( "S27KS0641DPBHI020" )) 
  i_hyperram   (
    .DQ7      ( hyper_dq_pin[7] ),
    .DQ6      ( hyper_dq_pin[6] ),
    .DQ5      ( hyper_dq_pin[5] ),
    .DQ4      ( hyper_dq_pin[4] ),
    .DQ3      ( hyper_dq_pin[3] ),
    .DQ2      ( hyper_dq_pin[2] ),
    .DQ1      ( hyper_dq_pin[1] ),
    .DQ0      ( hyper_dq_pin[0] ),
    .RWDS     ( hyper_rwds_pin  ),
    .CSNeg    ( hyper_cs_no     ),
    .CK       ( hyper_ck_o      ),
    .CKNeg    ( hyper_ck_no     ),
    .RESETNeg ( hyper_reset_no  )
  );
  
  initial $sdf_annotate("../rtl/models/s27ks0641/s27ks0641.sdf", i_hyperram);


  // --------------------------------------------------------------------------
  // Test sequence
  // --------------------------------------------------------------------------
  logic [31:0] tb_data;

  initial begin
    $timeformat(-9, 0, "ns", 12);

    // Wait for reset to release
    #ClkPeriodSys;

    // ────────────────────────────────────────────────────────────────
    // Wait for HyperRAM model power-up (mirrors Cheshire's approach)
    // ────────────────────────────────────────────────────────────────
    $display("[TB] Waiting for HyperRAM power-up (600 us)...");
    for (int i = 1; i <= 6; i++) begin
      #100us;
      $display("[TB] - %0d/6 (%0d%%)", i, 100*i/6);
    end
    $display("[TB] HyperRAM ready");

    // Initialize JTAG
    i_vip.jtag_init();

    // Sanity: write a test value to SRAM, just like the original tb does
    i_vip.jtag_write_reg32(SramBaseAddr, 32'h1234_5678, 1'b1);

    // Load HyperBus test binary into SRAM
    i_vip.jtag_load_hex(binary_path);

    // Wake core via CLINT msip
    $display("@%t | [CORE] Waking core via CLINT msip", $time);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1);

    // Halt + resume to start execution
    i_vip.jtag_halt();
    i_vip.jtag_resume();

    // Wait for end-of-code
    $display("@%t | [CORE] Wait for end of code...", $time);
    i_vip.jtag_wait_for_eoc(tb_data);

    // Allow some final cycles
    repeat (50) @(posedge sys_clk);
    $finish();
  end

  // --------------------------------------------------------------------------
  // Waveform dump
  // --------------------------------------------------------------------------
  initial begin
    `ifdef TRACE_WAVE
      `ifdef VERILATOR
        $dumpfile("hyperbus_croc.fst");
        $dumpvars(0, i_croc_soc);
      `else
        $dumpfile("hyperbus_croc.vcd");
        $dumpvars(0, i_croc_soc);
      `endif
    `endif
  end

  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule