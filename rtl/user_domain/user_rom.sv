// Copyright 2023 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Cyril Koenig <cykoenig@iis.ee.ethz.ch>
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

// Simple ROM
module user_rom #(
  // The OBI configuration for all ports
  parameter obi_pkg::obi_cfg_t ObiCfg    = obi_pkg::ObiDefaultConfig,
  parameter type               obi_req_t = logic,
  parameter type               obi_rsp_t = logic
) (
  input  logic     clk_i,
  input  logic     rst_ni,
  input  obi_req_t obi_req_i,
  output obi_rsp_t obi_rsp_o
);

  // Define some registers to hold the requests fields
  logic req_d, req_q, req_w;                          // Request valid
  logic we_d, we_q, we_w;                            // Write enable
  logic [ObiCfg.AddrWidth-1:0] addr_d, addr_q, addr_w; // Internal address of the word to read
  logic [ObiCfg.IdWidth-1:0] id_d, id_q,id_w ;       // Id of the request, must be same for the response

  // Signals used to create the response
  logic [ObiCfg.DataWidth-1:0] rsp_data; // Data field of the obi response
  logic rsp_err;                         // Error field of the obi response

  // Wire the registers holding the request
  // TODO 1: Modify the code such that the ROM will respond after 2 cycles instead of 1
  // Hint: You might want to add some additional registers to hold the request fields for 2 cycles instead of 1
  assign req_d  = obi_req_i.req;
  assign id_d   = obi_req_i.a.aid;
  assign we_d   = obi_req_i.a.we;
  assign addr_d = obi_req_i.a.addr;

  // Flip-flops
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      req_w  <= '0;
      id_w   <= '0;
      we_w   <= '0;
      addr_w <= '0;
    end else begin
      req_w  <= req_d;
      id_w   <= id_d;
      we_w   <= we_d;
      addr_w <= addr_d;
    end
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (~rst_ni) begin
      req_q  <= '0;
      id_q   <= '0;
      we_q   <= '0;
      addr_q <= '0;
    end else begin
      req_q  <= req_w;
      id_q   <= id_w;
      we_q   <= we_w;
      addr_q <= addr_w;
    end
  end
  // // Assign the OBI response data
  // TODO 2: Modify the code such that the ROM will contain (up to) 32 ASCII chars
  // hold in your initials in the form: "JD&JD's ASIC\0"
  logic [4:0] word_addr;
  always_comb begin
    rsp_data = '0;
    rsp_err  = '0;
    word_addr = addr_q[6:2];

    if(req_q) begin
      if(~we_q) begin
        // "Lorenzo & Andrea\0"
        case (word_addr)
          5'h00: rsp_data = 32'h4C; // 'L'
          5'h01: rsp_data = 32'h6F; // 'o'
          5'h02: rsp_data = 32'h72; // 'r'
          5'h03: rsp_data = 32'h65; // 'e'
          5'h04: rsp_data = 32'h6E; // 'n'
          5'h05: rsp_data = 32'h7A; // 'z'
          5'h06: rsp_data = 32'h6F; // 'o'
          5'h07: rsp_data = 32'h20; // ' '
          5'h08: rsp_data = 32'h26; // '&'
          5'h09: rsp_data = 32'h20; // ' '
          5'h0A: rsp_data = 32'h41; // 'A'
          5'h0B: rsp_data = 32'h6E; // 'n'
          5'h0C: rsp_data = 32'h64; // 'd'
          5'h0D: rsp_data = 32'h72; // 'r'
          5'h0E: rsp_data = 32'h65; // 'e'
          5'h0F: rsp_data = 32'h61; // 'a'
          5'h10: rsp_data = 32'h00; // '\0'
          default: rsp_data = 32'h0;
        endcase
      end else begin
        rsp_err = '1;
      end
    end
  end

  // Assign the OBI response signals
  // A channel
  assign obi_rsp_o.gnt = obi_req_i.req;
  // R channel
  assign obi_rsp_o.rvalid       = req_q;
  assign obi_rsp_o.r.rdata      = rsp_data;
  assign obi_rsp_o.r.rid        = id_q;
  assign obi_rsp_o.r.err        = rsp_err;
  assign obi_rsp_o.r.r_optional = '0;

endmodule
