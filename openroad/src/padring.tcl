# Copyright (c) 2024 ETH Zurich and University of Bologna.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
#
# Authors:
# - Philippe Sauter <phsauter@iis.ee.ethz.ch>

# [QFN56 - 2.5x2mm]
#   LEFT/RIGHT edges:  14 pads each (2 power + 12 signal)
#   TOP/BOTTOM edges:  18 pads each (6 power + 12 signal)

set numPadsLR  14
set numPadsTB  18

set cornerToPad [expr {$padBond + $padD}]

make_io_sites -horizontal_site sg13cmos5l_ioSite \
    -vertical_site sg13cmos5l_ioSite \
    -corner_site sg13cmos5l_ioSite \
    -offset $padBond \
    -rotation_horizontal R0 \
    -rotation_vertical R0 \
    -rotation_corner R0

##########################################################################
# Edge: LEFT (top to bottom)                                             #
##########################################################################
set westSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set westPitch [expr {floor($westSpan / double($numPadsLR - 1))}]
set westStart [expr {$chipH - $cornerToPad - $padW}]

place_pad -row IO_WEST -location [expr {$westStart -  0*$westPitch}] "pad_vddio0"       ; # pin no:  1
place_pad -row IO_WEST -location [expr {$westStart -  1*$westPitch}] "pad_uart_rx_i"    ; # pin no:  2
place_pad -row IO_WEST -location [expr {$westStart -  2*$westPitch}] "pad_uart_tx_o"    ; # pin no:  3
place_pad -row IO_WEST -location [expr {$westStart -  3*$westPitch}] "pad_testmode_i"   ; # pin no:  4
place_pad -row IO_WEST -location [expr {$westStart -  4*$westPitch}] "pad_status_o"     ; # pin no:  5
place_pad -row IO_WEST -location [expr {$westStart -  5*$westPitch}] "pad_clk_i"        ; # pin no:  6
place_pad -row IO_WEST -location [expr {$westStart -  6*$westPitch}] "pad_ref_clk_i"    ; # pin no:  7
place_pad -row IO_WEST -location [expr {$westStart -  7*$westPitch}] "pad_rst_ni"       ; # pin no:  8
place_pad -row IO_WEST -location [expr {$westStart -  8*$westPitch}] "pad_jtag_tck_i"   ; # pin no:  9
place_pad -row IO_WEST -location [expr {$westStart -  9*$westPitch}] "pad_jtag_trst_ni" ; # pin no: 10
place_pad -row IO_WEST -location [expr {$westStart - 10*$westPitch}] "pad_jtag_tms_i"   ; # pin no: 11
place_pad -row IO_WEST -location [expr {$westStart - 11*$westPitch}] "pad_jtag_tdi_i"   ; # pin no: 12
place_pad -row IO_WEST -location [expr {$westStart - 12*$westPitch}] "pad_jtag_tdo_o"   ; # pin no: 13
place_pad -row IO_WEST -location [expr {$westStart - 13*$westPitch}] "pad_vdd0"         ; # pin no: 14

##########################################################################
# Edge: BOTTOM (left to right)                                           #
##########################################################################
set southSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set southPitch [expr {floor($southSpan / double($numPadsTB - 1))}]
set southStart $cornerToPad

place_pad -row IO_SOUTH -location [expr {$southStart +  0*$southPitch}] "pad_vss0"         ; # pin no:  1
place_pad -row IO_SOUTH -location [expr {$southStart +  1*$southPitch}] "pad_vssio0"       ; # pin no:  2
place_pad -row IO_SOUTH -location [expr {$southStart +  2*$southPitch}] "pad_vddio1"       ; # pin no:  3
place_pad -row IO_SOUTH -location [expr {$southStart +  3*$southPitch}] "pad_gpio0_io"     ; # pin no:  4
place_pad -row IO_SOUTH -location [expr {$southStart +  4*$southPitch}] "pad_gpio1_io"     ; # pin no:  5
place_pad -row IO_SOUTH -location [expr {$southStart +  5*$southPitch}] "pad_gpio2_io"     ; # pin no:  6
place_pad -row IO_SOUTH -location [expr {$southStart +  6*$southPitch}] "pad_gpio3_io"     ; # pin no:  7
place_pad -row IO_SOUTH -location [expr {$southStart +  7*$southPitch}] "pad_gpio4_io"     ; # pin no:  8
place_pad -row IO_SOUTH -location [expr {$southStart +  8*$southPitch}] "pad_gpio5_io"     ; # pin no:  9
place_pad -row IO_SOUTH -location [expr {$southStart +  9*$southPitch}] "pad_gpio6_io"     ; # pin no: 10
place_pad -row IO_SOUTH -location [expr {$southStart + 10*$southPitch}] "pad_gpio7_io"     ; # pin no: 11
place_pad -row IO_SOUTH -location [expr {$southStart + 11*$southPitch}] "pad_gpio8_io"     ; # pin no: 12
place_pad -row IO_SOUTH -location [expr {$southStart + 12*$southPitch}] "pad_gpio9_io"     ; # pin no: 13
place_pad -row IO_SOUTH -location [expr {$southStart + 13*$southPitch}] "pad_gpio10_io"    ; # pin no: 14
place_pad -row IO_SOUTH -location [expr {$southStart + 14*$southPitch}] "pad_gpio11_io"    ; # pin no: 15
place_pad -row IO_SOUTH -location [expr {$southStart + 15*$southPitch}] "pad_vdd1"         ; # pin no: 16
place_pad -row IO_SOUTH -location [expr {$southStart + 16*$southPitch}] "pad_vss1"         ; # pin no: 17
place_pad -row IO_SOUTH -location [expr {$southStart + 17*$southPitch}] "pad_vssio1"       ; # pin no: 18

##########################################################################
# Edge: RIGHT (bottom to top)                                            #
##########################################################################
set eastSpan  [expr {$chipH - 2*$cornerToPad - $padW}]
set eastPitch [expr {floor($eastSpan / double($numPadsLR - 1))}]
set eastStart $cornerToPad

place_pad -row IO_EAST  -location [expr {$eastStart +  0*$eastPitch}] "pad_vddio2"           ; # pin no:  1
place_pad -row IO_EAST  -location [expr {$eastStart +  1*$eastPitch}] "pad_gpio12_io"        ; # pin no:  2
place_pad -row IO_EAST  -location [expr {$eastStart +  2*$eastPitch}] "pad_gpio13_io"        ; # pin no:  3
place_pad -row IO_EAST  -location [expr {$eastStart +  3*$eastPitch}] "pad_gpio14_io"        ; # pin no:  4
place_pad -row IO_EAST  -location [expr {$eastStart +  4*$eastPitch}] "pad_gpio15_io"        ; # pin no:  5
place_pad -row IO_EAST  -location [expr {$eastStart +  5*$eastPitch}] "pad_gpio16_io"        ; # pin no:  6
place_pad -row IO_EAST  -location [expr {$eastStart +  6*$eastPitch}] "pad_gpio17_io"        ; # pin no:  7
place_pad -row IO_EAST  -location [expr {$eastStart +  7*$eastPitch}] "pad_gpio18_io"        ; # pin no:  8
place_pad -row IO_EAST  -location [expr {$eastStart +  8*$eastPitch}] "pad_neopixel_data_o"  ; # pin no:  9
place_pad -row IO_EAST  -location [expr {$eastStart +  9*$eastPitch}] "pad_hyper_rwds_io"    ; # pin no: 10
place_pad -row IO_EAST  -location [expr {$eastStart + 10*$eastPitch}] "pad_hyper_cs_no"      ; # pin no: 11
place_pad -row IO_EAST  -location [expr {$eastStart + 11*$eastPitch}] "pad_hyper_reset_no"   ; # pin no: 12
place_pad -row IO_EAST  -location [expr {$eastStart + 12*$eastPitch}] "pad_unused0_o"             ; # pin no: 13
place_pad -row IO_EAST  -location [expr {$eastStart + 13*$eastPitch}] "pad_vdd2"             ; # pin no: 14

##########################################################################
# Edge: TOP (right to left)                                              #
##########################################################################
set northSpan  [expr {$chipW - 2*$cornerToPad - $padW}]
set northPitch [expr {floor($northSpan / double($numPadsTB - 1))}]
set northStart [expr {$chipW - $cornerToPad - $padW}]

place_pad -row IO_NORTH -location [expr {$northStart -  0*$northPitch}] "pad_vss2"          ; # pin no:  1
place_pad -row IO_NORTH -location [expr {$northStart -  1*$northPitch}] "pad_vssio2"            ; # pin no:  2
place_pad -row IO_NORTH -location [expr {$northStart -  2*$northPitch}] "pad_vddio3"            ; # pin no:  3
place_pad -row IO_NORTH -location [expr {$northStart -  3*$northPitch}] "pad_hyper_dq_0_io"   ; # pin no:  4
place_pad -row IO_NORTH -location [expr {$northStart -  4*$northPitch}] "pad_hyper_dq_1_io"   ; # pin no:  5
place_pad -row IO_NORTH -location [expr {$northStart -  5*$northPitch}] "pad_hyper_dq_2_io"   ; # pin no:  6
place_pad -row IO_NORTH -location [expr {$northStart -  6*$northPitch}] "pad_hyper_dq_3_io"   ; # pin no:  7cd 
place_pad -row IO_NORTH -location [expr {$northStart -  7*$northPitch}] "pad_hyper_dq_4_io"   ; # pin no:  8
place_pad -row IO_NORTH -location [expr {$northStart -  8*$northPitch}] "pad_hyper_dq_5_io"   ; # pin no:  9
place_pad -row IO_NORTH -location [expr {$northStart -  9*$northPitch}] "pad_hyper_dq_6_io"   ; # pin no: 10
place_pad -row IO_NORTH -location [expr {$northStart - 10*$northPitch}] "pad_hyper_dq_7_io"   ; # pin no: 11
place_pad -row IO_NORTH -location [expr {$northStart - 11*$northPitch}] "pad_hyper_ck_o"      ; # pin no: 12
place_pad -row IO_NORTH -location [expr {$northStart - 12*$northPitch}] "pad_hyper_ck_no"     ; # pin no: 13
place_pad -row IO_NORTH -location [expr {$northStart - 13*$northPitch}] "pad_unused1_o"          ; # pin no: 14
place_pad -row IO_NORTH -location [expr {$northStart - 14*$northPitch}] "pad_unused2_o"          ; # pin no: 15
place_pad -row IO_NORTH -location [expr {$northStart - 15*$northPitch}] "pad_vdd3"            ; # pin no: 16
place_pad -row IO_NORTH -location [expr {$northStart - 16*$northPitch}] "pad_vss3"            ; # pin no: 17
place_pad -row IO_NORTH -location [expr {$northStart - 17*$northPitch}] "pad_vssio3"          ; # pin no: 18

# Fill in the rest of the padring
place_corners $iocorner

place_io_fill -row IO_NORTH {*}$iofill
place_io_fill -row IO_SOUTH {*}$iofill
place_io_fill -row IO_WEST  {*}$iofill
place_io_fill -row IO_EAST  {*}$iofill

# Connect built-in power rings
connect_by_abutment

# Bondpad as separate cell placed in OpenROAD
place_bondpad -bond $bondPadCell -offset {5.0 -70.0} pad_*

# remove rows created by via make_io_sites as they are no longer needed
remove_io_rows