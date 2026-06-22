// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "axi/typedef.svh"
`include "axi/assign.svh"
`include "register_interface/typedef.svh"


module user_domain import user_pkg::*; import croc_pkg::*; #(
  parameter int unsigned GpioCount = 16,
  parameter int unsigned NumExternalIrqs = 4
) (
  input  logic      clk_i,
  input  logic      ref_clk_i,
  input  logic      rst_ni,
  input  logic      testmode_i,
  
  input  sbr_obi_req_t user_sbr_obi_req_i, // User Sbr (rsp_o), Croc Mgr (req_i)
  output sbr_obi_rsp_t user_sbr_obi_rsp_o,

  output mgr_obi_req_t user_mgr_obi_req_o, // User Mgr (req_o), Croc Sbr (rsp_i)
  input  mgr_obi_rsp_t user_mgr_obi_rsp_i,

  input  logic [      GpioCount-1:0] gpio_in_sync_i, // synchronized GPIO inputs
  output logic [NumExternalIrqs-1:0] interrupts_o, // interrupts to core

  output logic neopixel_data_o,

  // ---- HyperBus PHY interface (1 PHY, 1 chip) ----
  output logic        hyper_cs_no,
  output logic        hyper_ck_o,
  output logic        hyper_ck_no,
  output logic        hyper_rwds_o,
  input  logic        hyper_rwds_i,
  output logic        hyper_rwds_oe_o,
  input  logic [7:0]  hyper_dq_i,
  output logic [7:0]  hyper_dq_o,
  output logic        hyper_dq_oe_o,
  output logic        hyper_reset_no

);

   // -------------------------------------------------------------------------
  // AXI types for the HyperBus path
  // -------------------------------------------------------------------------
  localparam int unsigned HypAxiIdWidth   = 1;   // single master
  localparam int unsigned HypAxiAddrWidth = 32; 
  localparam int unsigned HypAxiDataWidth = 64;
  localparam int unsigned HypAxiUserWidth = 1;   // unused, but >=1 to avoid empty struct

  typedef logic [HypAxiAddrWidth-1:0] hyp_axi_addr_t;
  typedef logic [HypAxiDataWidth-1:0] hyp_axi_data_t;
  typedef logic [HypAxiDataWidth/8-1:0] hyp_axi_strb_t;
  typedef logic [HypAxiIdWidth-1:0]   hyp_axi_id_t;
  typedef logic [HypAxiUserWidth-1:0] hyp_axi_user_t;

  `AXI_TYPEDEF_ALL(hyp_axi, hyp_axi_addr_t, hyp_axi_id_t, hyp_axi_data_t,
                   hyp_axi_strb_t, hyp_axi_user_t)
  // → defines: hyp_axi_aw_chan_t, hyp_axi_w_chan_t, hyp_axi_b_chan_t,
  //            hyp_axi_ar_chan_t, hyp_axi_r_chan_t, hyp_axi_req_t, hyp_axi_resp_t

  // Hyperbus address rules
  typedef struct packed {
    int unsigned idx;
    logic [HypAxiAddrWidth-1:0] start_addr;
    logic [HypAxiAddrWidth-1:0] end_addr;
  } hyper_addr_rule_t;

  // REGISTER types for HyperBus config
  typedef logic [31:0] hyp_reg_addr_t;
  typedef logic [31:0] hyp_reg_data_t;
  typedef logic [3:0]  hyp_reg_strb_t;   // 32 bits / 8 = 4 byte strobes

  `REG_BUS_TYPEDEF_ALL(hyp_reg, hyp_reg_addr_t, hyp_reg_data_t, hyp_reg_strb_t)
  // → defines: hyp_reg_req_t, hyp_reg_rsp_t

  //logic irq;
  //logic irq_n;
  logic neopixel_fifo_interrupt;

  always_comb begin
     interrupts_o = '0;  
     interrupts_o[0] = neopixel_fifo_interrupt;
  end

  //OBI cut signals
  sbr_obi_req_t user_sbr_obi_req_cut;
  sbr_obi_rsp_t user_sbr_obi_rsp_cut;


  //////////////////////
  // User Manager MUX //
  /////////////////////

  // No manager so we don't need a obi_mux module and just terminate the request properly

  // Neopixel (DMA) Manager Bus
  mgr_obi_req_t user_mgr_dma_obi_req; 
  mgr_obi_rsp_t user_mgr_dma_obi_rsp;
  assign user_mgr_obi_req_o = user_mgr_dma_obi_req;


  ////////////////////////////
  // User Subordinate DEMUX //
  ////////////////////////////

  // ----------------------------------------------------------------------------------------------
  // User Subordinate Buses
  // ----------------------------------------------------------------------------------------------
  // collection of signals from the demultiplexer
  sbr_obi_req_t [NumDemuxSbr-1:0] all_user_sbr_obi_req;
  sbr_obi_rsp_t [NumDemuxSbr-1:0] all_user_sbr_obi_rsp; 

  //ho spostato queste 2 righe qua sopra (stavano sotto queste due righe qua sotto) 
// Neopixel Subordinate Bus
  sbr_obi_req_t user_neopixel_obi_req;
  sbr_obi_rsp_t user_neopixel_obi_rsp;

  assign user_neopixel_obi_req                = all_user_sbr_obi_req[UserNeoPixel];
  assign all_user_sbr_obi_rsp[UserNeoPixel]   = user_neopixel_obi_rsp;
 

 //aggiunto
  sbr_obi_req_t user_rom_obi_req;
  sbr_obi_rsp_t user_rom_obi_rsp;
  assign user_rom_obi_req              = all_user_sbr_obi_req[UserRom];
  assign all_user_sbr_obi_rsp[UserRom] = user_rom_obi_rsp;

  user_rom #(
    .ObiCfg    ( SbrObiCfg    ),
    .obi_req_t ( sbr_obi_req_t ),
    .obi_rsp_t ( sbr_obi_rsp_t )
  ) i_user_rom (
    .clk_i     ( clk_i            ),
    .rst_ni    ( rst_ni           ),
    .obi_req_i ( user_rom_obi_req ),
    .obi_rsp_o ( user_rom_obi_rsp )
  );
 //fine aggiunto
  //Hyperbus Subordinate Bus
  //RAM
  sbr_obi_req_t user_hyperbus_ram_obi_req;
  sbr_obi_rsp_t user_hyperbus_ram_obi_rsp;



  assign user_hyperbus_ram_obi_req  = all_user_sbr_obi_req[UserHyperRam];

  
  assign all_user_sbr_obi_rsp[UserHyperRam]      = user_hyperbus_ram_obi_rsp;

  //Config
  sbr_obi_req_t user_hyperbus_cfg_obi_req;
  sbr_obi_rsp_t user_hyperbus_cfg_obi_rsp;

  assign user_hyperbus_cfg_obi_req                = all_user_sbr_obi_req[UserHyperCfg];
  assign all_user_sbr_obi_rsp[UserHyperCfg]      = user_hyperbus_cfg_obi_rsp;



  // Error Subordinate Bus
  sbr_obi_req_t user_error_obi_req;
  sbr_obi_rsp_t user_error_obi_rsp;

  // Fanout into more readable signals
  assign user_error_obi_req               = all_user_sbr_obi_req[UserError];
  assign all_user_sbr_obi_rsp[UserError]  = user_error_obi_rsp;


  //-----------------------------------------------------------------------------------------------
  // Demultiplex to User Subordinates according to address map
  //-----------------------------------------------------------------------------------------------

  logic [cf_math_pkg::idx_width(NumDemuxSbr)-1:0] user_idx;

  addr_decode #(
    .NoIndices ( NumDemuxSbr                    ),
    .NoRules   ( $size(user_addr_map)           ),
    .addr_t    ( logic[SbrObiCfg.DataWidth-1:0] ),
    .rule_t    ( addr_map_rule_t                ),
    .Napot     ( 1'b0                           )
  ) i_addr_decode_periphs (
    .addr_i           ( user_sbr_obi_req_cut.a.addr ),
    .addr_map_i       ( user_addr_map             ),
    .idx_o            ( user_idx                  ),
    .dec_valid_o      ( ),
    .dec_error_o      ( ),
    .en_default_idx_i ( 1'b1      ),
    .default_idx_i    ( UserError )
  );

  obi_demux #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t ),
    .NumMgrPorts ( NumDemuxSbr   ),
    .NumMaxTrans ( 4             )
  ) i_obi_demux (
    .clk_i,
    .rst_ni,

    .sbr_port_select_i ( user_idx             ),
    .sbr_port_req_i    ( user_sbr_obi_req_cut   ),
    .sbr_port_rsp_o    ( user_sbr_obi_rsp_cut   ),

    .mgr_ports_req_o   ( all_user_sbr_obi_req ),
    .mgr_ports_rsp_i   ( all_user_sbr_obi_rsp )
  );


//-------------------------------------------------------------------------------------------------
// User Subordinates
//-------------------------------------------------------------------------------------------------

  //OBI CUT module to cut longest path

 obi_cut #(
  .ObiCfg       ( SbrObiCfg        ),
  .obi_a_chan_t ( sbr_obi_a_chan_t ),   // type of req.a  — verify name in croc_pkg
  .obi_r_chan_t ( sbr_obi_r_chan_t ),   // type of rsp.r  — verify name in croc_pkg
  .obi_req_t    ( sbr_obi_req_t    ),
  .obi_rsp_t    ( sbr_obi_rsp_t    ),
  .Bypass       ( 1'b0             )
) i_user_sbr_cut (
  .clk_i,
  .rst_ni,
  .sbr_port_req_i ( user_sbr_obi_req_i   ),  // from croc
  .sbr_port_rsp_o ( user_sbr_obi_rsp_o   ),  // to croc
  .mgr_port_req_o ( user_sbr_obi_req_cut ),  // into your decode/demux
  .mgr_port_rsp_i ( user_sbr_obi_rsp_cut )   // from your demux
);
  // -------------------------------------------------------------------------
  // OBI → AXI bridge for HyperRAM data
  // -------------------------------------------------------------------------
  hyp_axi_req_t  hyp_axi_req;
  hyp_axi_resp_t hyp_axi_rsp;



  obi_to_axi #(
    .ObiCfg       ( croc_pkg::SbrObiCfg ),
    .obi_req_t    ( sbr_obi_req_t       ),
    .obi_rsp_t    ( sbr_obi_rsp_t       ),
    .AxiLite      ( 1'b0                ), //because Hyperbus expects normal AXI
    .AxiAddrWidth ( HypAxiAddrWidth     ),
    .AxiDataWidth ( HypAxiDataWidth     ),
    .AxiUserWidth ( HypAxiUserWidth     ),
    .axi_req_t    ( hyp_axi_req_t       ),
    .axi_rsp_t    ( hyp_axi_resp_t      ),
    .MaxRequests  ( 4                   )
  ) i_obi_to_axi_hyp (
    .clk_i  ( clk_i  ),
    .rst_ni ( rst_ni ),

    .obi_req_i ( user_hyperbus_ram_obi_req ),
    .obi_rsp_o ( user_hyperbus_ram_obi_rsp ),
    .user_i    ( '0 ),

    .axi_req_o ( hyp_axi_req ),
    .axi_rsp_i ( hyp_axi_rsp ),

    // Tie off optional user-channel reassignment
    .axi_rsp_channel_sel ( /* leave open */ ),
    .axi_rsp_b_user_o    ( /* leave open */ ),
    .axi_rsp_r_user_o    ( /* leave open */ ),
    .obi_rsp_user_i      ( '0 )
  );

  // -------------------------------------------------------------------------
  // OBI → Reg bridge for HyperBus config
  // -------------------------------------------------------------------------
  hyp_reg_req_t hyp_reg_req;
  hyp_reg_rsp_t hyp_reg_rsp;

  assign hyp_reg_req.addr  = user_hyperbus_cfg_obi_req.a.addr;
  assign hyp_reg_req.write = user_hyperbus_cfg_obi_req.a.we;
  assign hyp_reg_req.wdata = user_hyperbus_cfg_obi_req.a.wdata;
  assign hyp_reg_req.wstrb = user_hyperbus_cfg_obi_req.a.be;
  assign hyp_reg_req.valid = user_hyperbus_cfg_obi_req.req;

  //assign user_hyperbus_cfg_obi_rsp.r.rid   = user_hyperbus_cfg_obi_req.a.aid; // pass through ID for potential future use

  assign user_hyperbus_cfg_obi_rsp.gnt    = hyp_reg_rsp.ready & user_hyperbus_cfg_obi_req.req; //handshake is not the same, the idea is that we treat both grant and valid as the ready signal

  logic rvalid_q;
  logic [31:0] rdata_q;
  logic error_q;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_q <= 1'b0;
      rdata_q <= 32'b0;
      error_q <= 1'b0;
    end else begin
      // Capture response state when an OBI request is granted
      rvalid_q <= user_hyperbus_cfg_obi_req.req & hyp_reg_rsp.ready;
      rdata_q <= hyp_reg_rsp.rdata;
      error_q <= hyp_reg_rsp.error;
    end
  end

  assign user_hyperbus_cfg_obi_rsp.r.rdata = rdata_q;
  assign user_hyperbus_cfg_obi_rsp.r.err   = error_q;
  assign user_hyperbus_cfg_obi_rsp.rvalid = rvalid_q; //Hopefully it works

  // -------------------------------------------------------------------------
  // HyperBus controller
  // -------------------------------------------------------------------------
  hyperbus_synchronous #(
    .NumChips         ( 1                 ),
    .NumPhys          ( 1                 ),
    .AxiAddrWidth     ( HypAxiAddrWidth   ),
    .AxiDataWidth     ( HypAxiDataWidth   ),
    .AxiIdWidth       ( HypAxiIdWidth     ),
    .AxiUserWidth     ( HypAxiUserWidth   ),
    .axi_req_t        ( hyp_axi_req_t     ),
    .axi_rsp_t        ( hyp_axi_resp_t    ),
    .axi_w_chan_t     ( hyp_axi_w_chan_t  ),
    .axi_b_chan_t     ( hyp_axi_b_chan_t  ),
    .axi_ar_chan_t    ( hyp_axi_ar_chan_t ),
    .axi_r_chan_t     ( hyp_axi_r_chan_t  ),
    .axi_aw_chan_t    ( hyp_axi_aw_chan_t ),
    .RegAddrWidth     ( 32                ),
    .RegDataWidth     ( 32                ),
    .MinFreqMHz       ( 100               ),  // TO CHECK IF OK
    .reg_req_t        ( hyp_reg_req_t         ),
    .reg_rsp_t        ( hyp_reg_rsp_t         ),
    .axi_rule_t       ( hyper_addr_rule_t        ),
    .RstChipBase      ( 'h0               ),
    .RstChipSpace     ( HyperRamSize      ),  // tell the controller the device size
    .PhyStartupCycles ( 300 * 200         ),
    .SyncStages       ( 2                 )
  ) i_hyperbus (
    .clk_sys_i   ( clk_i       ),
    .rst_sys_ni  ( rst_ni      ),
    .test_mode_i ( testmode_i  ),

    .axi_req_i   ( hyp_axi_req ),
    .axi_rsp_o   ( hyp_axi_rsp ),

    .reg_req_i   ( hyp_reg_req ),
    .reg_rsp_o   ( hyp_reg_rsp ),

    // Physical interface — 1 PHY, 1 chip
    .hyper_cs_no     ( hyper_cs_no     ), // [0][0]
    .hyper_ck_o      ( hyper_ck_o      ), // [0]
    .hyper_ck_no     ( hyper_ck_no     ),
    .hyper_rwds_o    ( hyper_rwds_o    ),
    .hyper_rwds_i    ( hyper_rwds_i    ),
    .hyper_rwds_oe_o ( hyper_rwds_oe_o ),
    .hyper_dq_i      ( hyper_dq_i      ), // [0][7:0]
    .hyper_dq_o      ( hyper_dq_o      ),
    .hyper_dq_oe_o   ( hyper_dq_oe_o   ),
    .hyper_reset_no  ( hyper_reset_no  )
  );

  // Error Subordinate
  obi_err_sbr #(
    .ObiCfg      ( SbrObiCfg     ),
    .obi_req_t   ( sbr_obi_req_t ),
    .obi_rsp_t   ( sbr_obi_rsp_t ),
    .NumMaxTrans ( 1             ),
    .RspData     ( 32'hBADCAB1E  )
  ) i_user_err (
    .clk_i,
    .rst_ni,
    .testmode_i ( testmode_i         ),
    .obi_req_i  ( user_error_obi_req ),
    .obi_rsp_o  ( user_error_obi_rsp )
  );

  // Neopixel Subordinate (+ Manager Port)
  neopixel #(
    .SbrObiCfg      ( SbrObiCfg           ),
    .sbr_obi_req_t  ( sbr_obi_req_t       ),
    .sbr_obi_rsp_t  ( sbr_obi_rsp_t       ),
    .MgrObiCfg      ( MgrObiCfg           ),
    .mgr_obi_req_t  ( mgr_obi_req_t       ),
    .mgr_obi_rsp_t  ( mgr_obi_rsp_t       )
  ) i_neopixel (
    .clk_i,
    .rst_ni,
    .testmode_i ( testmode_i ),

    .obi_req_i  ( user_neopixel_obi_req ),
    .obi_rsp_o  ( user_neopixel_obi_rsp ),

    .mgr_obi_req_o ( user_mgr_dma_obi_req ),
    .mgr_obi_rsp_i ( user_mgr_dma_obi_rsp ),

    .fifo_interrupt_o ( neopixel_fifo_interrupt ),
    
    .data_o ( neopixel_data_o )
  );

endmodule

