// neopixel_monitor.sv
//
// Testbench monitor for verifying the NeoPixel serialized output in simulation.
//
// It watches the single-wire NeoPixel data output, decodes each bit from its
// HIGH pulse width (long-high = '1', short-high = '0'), reassembles 24-bit GRB
// pixels, and prints them. A long idle gap (>= latch/reset time) ends a frame.
//
// This checks the ACTUAL bits the hardware serializes onto the wire -- the thing
// software cannot read back -- so it directly answers "are the RGB values coming
// out the ones I loaded?".
//
// HOW TO USE
//   1. Instantiate inside your testbench, binding .npx_d to the NeoPixel data
//      output net (top-level port or internal signal via hierarchical ref / bind).
//   2. Set the timing parameters to match your NeoPixel config registers and the
//      simulation time unit. Defaults below assume the header's 20 MHz / 25-cycle
//      bit settings: T0H=8, T1H=16 cycles, 50 ns/cycle.
//   3. (Optional) Drive expected pixels into the checker task to get pass/fail.
//
// The decoder keys on HIGH time only, which is the cleanest 0/1 discriminator
// and is insensitive to exact low-time jitter.

`timescale 1ns/1ps

module neopixel_monitor #(
  // --- Pulse-width thresholds (in ns) -------------------------------------
  // A bit is '1' if its high time exceeds T_HIGH_THRESH, else '0'.
  // From the header defaults @20 MHz (50 ns/cycle):
  //   T0H = 8 cycles  = 400 ns   (logic 0 high time)
  //   T1H = 16 cycles = 800 ns   (logic 1 high time)
  // Put the threshold between them.
  parameter real T_HIGH_THRESH = 600.0,

  // A high pulse longer than this is treated as illegal (glitch / wrong config).
  parameter real T_HIGH_MAX     = 2000.0,

  // Idle (line low) longer than this marks end-of-frame / latch. From the
  // header: NPX_TIMING_LATCH ~ 1100 cycles = 55 us. Use a value clearly above
  // a normal inter-bit low (T1L=9c=450ns, T0L=17c=850ns) but at/below latch.
  parameter real T_LATCH        = 10000.0,

  parameter int  BITS_PER_PIXEL = 24
)(
  input  logic npx_d   // NeoPixel serial data output under test
);

  // Captured pixels for the current frame
  localparam int MAX_PIXELS = 512;
  logic [23:0] rx_pixel  [0:MAX_PIXELS-1];
  int          rx_count;

  // Bit assembly state
  logic [23:0] shiftreg;
  int          bitcnt;

  time         t_rise;
  time         t_fall;
  real         high_ns;
  real         low_ns;

  initial begin
    rx_count = 0;
    bitcnt   = 0;
    shiftreg = '0;
  end

  // --- Per-bit decode: measure high time on each rising->falling pulse ------
  always @(posedge npx_d) begin
    t_rise = $time;
    // measure preceding low gap to detect frame boundary
    low_ns = real'(t_rise - t_fall);
    if (t_fall != 0 && low_ns >= T_LATCH) begin
      end_of_frame();
    end
  end

  always @(negedge npx_d) begin
    logic bitval;
    t_fall  = $time;
    high_ns = real'(t_fall - t_rise);

    if (high_ns > T_HIGH_MAX) begin
      $display("[NPX-MON] %0t WARNING: illegal high pulse %.1f ns (config/glitch?)",
               $time, high_ns);
    end

    // Decode the bit by high-time. GRB is sent MSB-first.
    bitval   = (high_ns >= T_HIGH_THRESH);
    shiftreg = {shiftreg[22:0], bitval};
    bitcnt++;

    if (bitcnt == BITS_PER_PIXEL) begin
      if (rx_count < MAX_PIXELS) begin
        rx_pixel[rx_count] = shiftreg;
        report_pixel(rx_count, shiftreg);
        rx_count++;
      end
      bitcnt   = 0;
      shiftreg = '0;
    end
  end

  // --- Reporting -----------------------------------------------------------
  // The wire order is GRB. Convert to the 0xRRGGBB convention used in the C
  // frame[] array so it's directly comparable.
  function automatic logic [23:0] grb_to_rgb(input logic [23:0] grb);
    logic [7:0] g, r, b;
    g = grb[23:16];
    r = grb[15:8];
    b = grb[7:0];
    return {r, g, b};
  endfunction

  task automatic report_pixel(input int idx, input logic [23:0] grb);
    logic [23:0] rgb;
    rgb = grb_to_rgb(grb);
    $display("[NPX-MON] %0t pixel %0d: wire GRB=%06h  -> RGB=0x%06h (R=%0d G=%0d B=%0d)",
             $time, idx, grb, rgb, rgb[23:16], rgb[15:8], rgb[7:0]);
  endtask

  task automatic end_of_frame();
    $display("[NPX-MON] %0t ---- end of frame: %0d pixels received ----",
             $time, rx_count);
    // reset for next frame
    rx_count = 0;
    bitcnt   = 0;
    shiftreg = '0;
  endtask

  // --- Optional self-check -------------------------------------------------
  // Call this from your testbench after a frame to compare against expected
  // RGB values (0xRRGGBB). Returns number of mismatches.
  function automatic int check_frame(input logic [23:0] expected [],
                                     input int n);
    int errors;
    errors = 0;
    for (int i = 0; i < n; i++) begin
      logic [23:0] got_rgb;
      got_rgb = grb_to_rgb(rx_pixel[i]);
      if (got_rgb !== expected[i]) begin
        $display("[NPX-MON] MISMATCH pixel %0d: got 0x%06h expected 0x%06h",
                 i, got_rgb, expected[i]);
        errors++;
      end
    end
    if (errors == 0)
      $display("[NPX-MON] FRAME OK: %0d pixels match expected", n);
    else
      $display("[NPX-MON] FRAME FAIL: %0d mismatches", errors);
    return errors;
  endfunction

endmodule
