// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>

`include "obi/typedef.svh"

package user_pkg;

  //////////////////
  // User Manager //
  //////////////////
  
  // None


  ///////////////////////
  // User Subordinates //
  ///////////////////////

  // The base address of the user domain can be retrived from `croc_pkg::UserBaseAddr`
  // Recommended: place subordinates at 4KB boundaries (32'hXXXX_X000)

  //aggiungo la base della ROM
  localparam logic [31:0] UserRomBase = croc_pkg::UserBaseAddr;
  localparam logic [31:0] UserRomSize = 32'h0000_1000;

  localparam logic [31:0] UserNeoPixelBase   = 32'h2000_1000;
  localparam logic [31:0] UserNeoPixelSize    = 32'h0000_1000;

  // HyperRAM data window — what the CPU sees as RAM
  localparam logic [31:0] HyperRamBase = 32'h3000_0000;
  localparam logic [31:0] HyperRamSize = 32'h0080_0000; // 8 MB — adjust to actual device

  // HyperBus controller config registers (regbus interface)
  localparam logic [31:0] HyperCfgBase = 32'h4000_0000;
  localparam logic [31:0] HyperCfgSize = 32'h0000_1000;


  /// Enum with user domain demultiplexer subordinate idxs
  /*typedef enum int {
    UserError  = 0,
    UserNeoPixel = 1,
    UserHyperRam = 2,
    UserHyperCfg = 3
  } user_demux_outputs_e;*/ //vecchio

  typedef enum int {
    UserError    = 0,
    UserRom      = 1,
    UserNeoPixel = 2,
    UserHyperRam = 3,
    UserHyperCfg = 4
  } user_demux_outputs_e; // nuovo


  /// Address rules given to user domain demultiplexer (see croc_pkg.sv for examples)
  //localparam croc_pkg::addr_map_rule_t [0:0] user_addr_map = '{
  localparam croc_pkg::addr_map_rule_t [3:0] user_addr_map = '{
    '{ idx: UserRom,      start_addr: UserRomBase,      end_addr: UserRomBase + UserRomSize       }, // nuova riga + [2:0] -> [3:0]
    '{ idx: UserNeoPixel,  start_addr: UserNeoPixelBase,  end_addr: UserNeoPixelBase + UserNeoPixelSize   },
    '{ idx: UserHyperRam,  start_addr: HyperRamBase,           end_addr: HyperRamBase + HyperRamSize                     },
    '{ idx: UserHyperCfg,  start_addr: HyperCfgBase,           end_addr: HyperCfgBase + HyperCfgSize                     }
  };
  // All addresses outside the defined address rules go to the error subordinate

  // +1 for additional OBI error
  localparam int unsigned NumDemuxSbr = $size(user_addr_map) + 1; 

endpackage

