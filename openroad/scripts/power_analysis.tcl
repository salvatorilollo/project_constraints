###############################################################################
# STATIC POWER ANALYSIS                                                       #
###############################################################################

# Set uniform switching activity rate for all input ports, you may also replace <code>-input</code> with -global<code></code> to set activity rate for all pins
set_power_activity -input -activity 0.1

# Set known static inputs (e.g., reset) to zero activity
set_power_activity -input_port rst_ni -activity 0.01

 # set_power_activity -input_port clk_i -activity 1

# Generate the statistical power report for the typical corner
report_power -corner tt > reports/post_layout_static_power.rpt

###############################################################################
# IR DROP                                                                     #
###############################################################################

set_pdnsim_net_voltage -net VDD -voltage 1.2
analyze_power_grid -vsrc src/Vsrc_croc_vdd.loc -net VDD -corner tt

#Visualization
gui::set_display_controls "Heat Maps/IR Drop" visible true
gui::set_heatmap IRDrop Layer Metal1
gui::set_heatmap IRDrop ShowLegend 1


# set_pdnsim_net_voltage -net VSS -voltage 0
# analyze_power_grid -vsrc src/Vsrc_croc_vss.loc -net VSS -corner tt