module hyperbus_delay_welltap (in_i,
    out_o,
    delay_i,
    VSS,
    VDD);
 input in_i;
 output out_o;
 input [7:0] delay_i;
 inout VSS;
 inout VDD;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire bypass_coarse;
 wire dline_coarse_out;
 wire dline_out;
 wire dline_out_lsb_dly;
 wire dline_out_noninv;
 wire dline_ret_mux0;
 wire dline_ret_mux1;
 wire \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_o ;
 wire \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.ret_i ;
 wire \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_n ;
 wire \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.fwd_mux ;
 wire \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_i ;
 wire \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_n ;
 wire [61:0] coarse_nets;

 WELLTAP EDGE_WELLTAP_L_0 ();
 WELLTAP EDGE_WELLTAP_L_1 ();
 WELLTAP EDGE_WELLTAP_L_10 ();
 WELLTAP EDGE_WELLTAP_L_2 ();
 WELLTAP EDGE_WELLTAP_L_3 ();
 WELLTAP EDGE_WELLTAP_L_4 ();
 WELLTAP EDGE_WELLTAP_L_5 ();
 WELLTAP EDGE_WELLTAP_L_6 ();
 WELLTAP EDGE_WELLTAP_L_7 ();
 WELLTAP EDGE_WELLTAP_L_8 ();
 WELLTAP EDGE_WELLTAP_L_9 ();
 WELLTAP EDGE_WELLTAP_R_0 ();
 WELLTAP EDGE_WELLTAP_R_1 ();
 WELLTAP EDGE_WELLTAP_R_10 ();
 WELLTAP EDGE_WELLTAP_R_2 ();
 WELLTAP EDGE_WELLTAP_R_3 ();
 WELLTAP EDGE_WELLTAP_R_4 ();
 WELLTAP EDGE_WELLTAP_R_5 ();
 WELLTAP EDGE_WELLTAP_R_6 ();
 WELLTAP EDGE_WELLTAP_R_7 ();
 WELLTAP EDGE_WELLTAP_R_8 ();
 WELLTAP EDGE_WELLTAP_R_9 ();
 INVX1 _05_ (.Y(_00_),
    .A(delay_i[3]));
 AND2X1 _06_ (.B(delay_i[4]),
    .A(delay_i[3]),
    .Y(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ));
 OA21X2 _07_ (.C(delay_i[4]),
    .B(delay_i[2]),
    .A(delay_i[3]),
    .Y(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X1 _08_ (.A(delay_i[3]),
    .Y(_01_),
    .B(delay_i[4]));
 INVX1 _09_ (.Y(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_i ),
    .A(_01_));
 NAND2BX1 _10_ (.B(_01_),
    .Y(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_i ),
    .AB(delay_i[2]));
 NOR2X1 _11_ (.A(delay_i[1]),
    .Y(_02_),
    .B(delay_i[2]));
 NAND2X1 _12_ (.A(_01_),
    .B(_02_),
    .Y(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_i ));
 NAND2X1 _13_ (.A(delay_i[1]),
    .B(delay_i[2]),
    .Y(_03_));
 AND2X1 _14_ (.B(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ),
    .A(delay_i[2]),
    .Y(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2BX1 _15_ (.AB(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ),
    .Y(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(_03_));
 AOI2B1X1 _16_ (.Y(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_i ),
    .C(_01_),
    .B(_02_),
    .AB(delay_i[4]));
 NOR2BX1 _17_ (.AB(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ),
    .Y(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(_02_));
 AO21X2 _18_ (.C(delay_i[4]),
    .Y(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(delay_i[2]),
    .A(delay_i[3]));
 NOR2X1 _19_ (.A(delay_i[5]),
    .Y(bypass_coarse),
    .B(delay_i[6]));
 NOR2BX1 _20_ (.AB(dline_out_noninv),
    .Y(coarse_nets[42]),
    .B(bypass_coarse));
 AOI21BX1 _21_ (.CB(delay_i[4]),
    .B(_02_),
    .A(_00_),
    .Y(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_i ));
 AOI21BX1 _22_ (.CB(delay_i[4]),
    .B(_03_),
    .A(_00_),
    .Y(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X1 _23_ (.A(_01_),
    .B(_03_),
    .Y(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_i ));
 AOI2B1X1 _24_ (.Y(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_i ),
    .C(_01_),
    .B(_03_),
    .AB(delay_i[4]));
 BUFX1 _25_ (.A(delay_i[4]),
    .Y(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_i ));
 TIELO _26_ (.Y(_04_));
 TIELO _27_ (.Y(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_i ));
 MUX2X1 coarse_mux_hi (.A0(coarse_nets[0]),
    .A1(coarse_nets[20]),
    .S0(delay_i[5]),
    .Y(dline_ret_mux1));
 MUX2X1 coarse_mux_lo (.A0(coarse_nets[42]),
    .A1(coarse_nets[21]),
    .S0(delay_i[5]),
    .Y(dline_ret_mux0));
 MUX2X1 coarse_mux_sel (.A0(dline_ret_mux0),
    .A1(dline_ret_mux1),
    .S0(delay_i[6]),
    .Y(dline_coarse_out));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[0].i_coarse_dly  (.A(coarse_nets[42]),
    .Y(coarse_nets[43]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[10].i_coarse_dly  (.A(coarse_nets[52]),
    .Y(coarse_nets[53]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[11].i_coarse_dly  (.A(coarse_nets[53]),
    .Y(coarse_nets[54]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[12].i_coarse_dly  (.A(coarse_nets[54]),
    .Y(coarse_nets[55]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[13].i_coarse_dly  (.A(coarse_nets[55]),
    .Y(coarse_nets[56]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[14].i_coarse_dly  (.A(coarse_nets[56]),
    .Y(coarse_nets[57]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[15].i_coarse_dly  (.A(coarse_nets[57]),
    .Y(coarse_nets[58]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[16].i_coarse_dly  (.A(coarse_nets[58]),
    .Y(coarse_nets[59]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[17].i_coarse_dly  (.A(coarse_nets[59]),
    .Y(coarse_nets[60]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[18].i_coarse_dly  (.A(coarse_nets[60]),
    .Y(coarse_nets[61]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[19].i_coarse_dly  (.A(coarse_nets[61]),
    .Y(coarse_nets[21]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[1].i_coarse_dly  (.A(coarse_nets[43]),
    .Y(coarse_nets[44]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[2].i_coarse_dly  (.A(coarse_nets[44]),
    .Y(coarse_nets[45]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[3].i_coarse_dly  (.A(coarse_nets[45]),
    .Y(coarse_nets[46]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[4].i_coarse_dly  (.A(coarse_nets[46]),
    .Y(coarse_nets[47]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[5].i_coarse_dly  (.A(coarse_nets[47]),
    .Y(coarse_nets[48]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[6].i_coarse_dly  (.A(coarse_nets[48]),
    .Y(coarse_nets[49]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[7].i_coarse_dly  (.A(coarse_nets[49]),
    .Y(coarse_nets[50]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[8].i_coarse_dly  (.A(coarse_nets[50]),
    .Y(coarse_nets[51]));
 DLY1X2 \gen_coarse_lines[0].gen_coarse_cells[9].i_coarse_dly  (.A(coarse_nets[51]),
    .Y(coarse_nets[52]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[0].i_coarse_dly  (.A(coarse_nets[21]),
    .Y(coarse_nets[22]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[10].i_coarse_dly  (.A(coarse_nets[31]),
    .Y(coarse_nets[32]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[11].i_coarse_dly  (.A(coarse_nets[32]),
    .Y(coarse_nets[33]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[12].i_coarse_dly  (.A(coarse_nets[33]),
    .Y(coarse_nets[34]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[13].i_coarse_dly  (.A(coarse_nets[34]),
    .Y(coarse_nets[35]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[14].i_coarse_dly  (.A(coarse_nets[35]),
    .Y(coarse_nets[36]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[15].i_coarse_dly  (.A(coarse_nets[36]),
    .Y(coarse_nets[37]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[16].i_coarse_dly  (.A(coarse_nets[37]),
    .Y(coarse_nets[38]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[17].i_coarse_dly  (.A(coarse_nets[38]),
    .Y(coarse_nets[39]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[18].i_coarse_dly  (.A(coarse_nets[39]),
    .Y(coarse_nets[40]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[19].i_coarse_dly  (.A(coarse_nets[40]),
    .Y(coarse_nets[0]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[1].i_coarse_dly  (.A(coarse_nets[22]),
    .Y(coarse_nets[23]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[2].i_coarse_dly  (.A(coarse_nets[23]),
    .Y(coarse_nets[24]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[3].i_coarse_dly  (.A(coarse_nets[24]),
    .Y(coarse_nets[25]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[4].i_coarse_dly  (.A(coarse_nets[25]),
    .Y(coarse_nets[26]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[5].i_coarse_dly  (.A(coarse_nets[26]),
    .Y(coarse_nets[27]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[6].i_coarse_dly  (.A(coarse_nets[27]),
    .Y(coarse_nets[28]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[7].i_coarse_dly  (.A(coarse_nets[28]),
    .Y(coarse_nets[29]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[8].i_coarse_dly  (.A(coarse_nets[29]),
    .Y(coarse_nets[30]));
 DLY1X2 \gen_coarse_lines[1].gen_coarse_cells[9].i_coarse_dly  (.A(coarse_nets[30]),
    .Y(coarse_nets[31]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[0].i_coarse_dly  (.A(coarse_nets[0]),
    .Y(coarse_nets[1]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[10].i_coarse_dly  (.A(coarse_nets[10]),
    .Y(coarse_nets[11]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[11].i_coarse_dly  (.A(coarse_nets[11]),
    .Y(coarse_nets[12]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[12].i_coarse_dly  (.A(coarse_nets[12]),
    .Y(coarse_nets[13]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[13].i_coarse_dly  (.A(coarse_nets[13]),
    .Y(coarse_nets[14]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[14].i_coarse_dly  (.A(coarse_nets[14]),
    .Y(coarse_nets[15]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[15].i_coarse_dly  (.A(coarse_nets[15]),
    .Y(coarse_nets[16]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[16].i_coarse_dly  (.A(coarse_nets[16]),
    .Y(coarse_nets[17]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[17].i_coarse_dly  (.A(coarse_nets[17]),
    .Y(coarse_nets[18]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[18].i_coarse_dly  (.A(coarse_nets[18]),
    .Y(coarse_nets[19]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[19].i_coarse_dly  (.A(coarse_nets[19]),
    .Y(coarse_nets[20]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[1].i_coarse_dly  (.A(coarse_nets[1]),
    .Y(coarse_nets[2]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[2].i_coarse_dly  (.A(coarse_nets[2]),
    .Y(coarse_nets[3]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[3].i_coarse_dly  (.A(coarse_nets[3]),
    .Y(coarse_nets[4]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[4].i_coarse_dly  (.A(coarse_nets[4]),
    .Y(coarse_nets[5]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[5].i_coarse_dly  (.A(coarse_nets[5]),
    .Y(coarse_nets[6]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[6].i_coarse_dly  (.A(coarse_nets[6]),
    .Y(coarse_nets[7]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[7].i_coarse_dly  (.A(coarse_nets[7]),
    .Y(coarse_nets[8]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[8].i_coarse_dly  (.A(coarse_nets[8]),
    .Y(coarse_nets[9]));
 DLY1X2 \gen_coarse_lines[2].gen_coarse_cells[9].i_coarse_dly  (.A(coarse_nets[9]),
    .Y(coarse_nets[10]));
 MUX2X2 i_coarse_mux (.A0(dline_coarse_out),
    .A1(dline_out_noninv),
    .S0(bypass_coarse),
    .Y(out_o));
 NOR2X2 \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(in_i),
    .Y(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_i ),
    .B(in_i),
    .C(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.ret_i ),
    .Y(dline_out));
 INVX1 \i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_o ));
 INVX1 \i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[11].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[12].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[13].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(_04_),
    .Y(\i_dline_16taps.dline_cells[14].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[15].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[0].genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[1].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[2].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[3].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[4].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[5].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[6].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.sel_i ));
 NOR2X2 \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_n ));
 OAI21X2 \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.gen_alt_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .C(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.ret_i ),
    .Y(\i_dline_16taps.dline_cells[7].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.sel_i ));
 NAND2X2 \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.gen_default_cell.i_fwd_gate  (.A(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_i ),
    .B(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .Y(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.fwd_mux ));
 AOI21X2 \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.gen_default_cell.i_ret_gate  (.A(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.fwd_mux ),
    .B(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_n ),
    .C(\i_dline_16taps.dline_cells[10].genblk1.genblk1.i_dly_cell.ret_o ),
    .Y(\i_dline_16taps.dline_cells[8].genblk1.genblk1.i_dly_cell.ret_i ));
 INVX1 \i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.i_sel_inv  (.Y(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_n ),
    .A(\i_dline_16taps.dline_cells[9].genblk1.genblk1.i_dly_cell.sel_i ));
 BUFX3 i_fine_lsb_buf (.A(dline_out),
    .Y(dline_out_lsb_dly));
 MUXI2X1 i_fine_lsb_mux (.A0(dline_out),
    .A1(dline_out_lsb_dly),
    .S0(delay_i[0]),
    .Y(dline_out_noninv));
endmodule
