v2lvs::set_warning_level -level 4
#v2lvs::set_warning_level -level 1
v2lvs::override_globals -default_not_connected
# needed that the bus connections are correct and
# the spice.inc is also taken in account, it is needed for the VNW VPW connection
v2lvs::combine_interface_info  -enable
v2lvs::load_verilog -filename ../../openroad/out/croc_lvs.v
v2lvs::load_verilog -filename ./verilog.inc -lib_mode
v2lvs::load_spice   -filename ./spice.inc -range_mode
v2lvs::set_includes -filename ./spice.inc
v2lvs::override_globals -supply0 VSS
v2lvs::override_globals -supply1 VDD
#from Oscar ez library to connect VNW/VPW and VDD/VSS respectively:
v2lvs::add_actual_port -module * -inst * -connect_formal_actual { VNW VDD }
v2lvs::add_actual_port -module * -inst * -connect_formal_actual { VPW VSS }
v2lvs::write_output -filename croc_chip.spi
exit
