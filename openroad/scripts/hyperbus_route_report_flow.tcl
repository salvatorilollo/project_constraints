# Copyright 2026 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51

# Report-oriented routing flow for HyperBus timing closure investigation.
#
# The normal 04_routing.tcl currently spends a long time cycling in full-chip
# setup repair on unrelated unused/debug outputs before it reaches hold repair
# and detailed routing.  This flow keeps the physical routing/parasitic steps
# needed for HyperBus signoff-style reports, but skips the non-HyperBus setup
# repair loop and saves a distinct checkpoint:
#
#   save/04_<proj_name>.hyp_report_routed.zip

source scripts/startup.tcl

load_checkpoint 03_${proj_name}.cts

setDefaultParasitics
set_dont_use $dont_use_cells

utl::report "###############################################################################"
utl::report "# HyperBus Report Routing Flow"
utl::report "###############################################################################"

set_global_routing_layer_adjustment TopMetal1 0.20
set_routing_layers -signal Metal2-TopMetal1 -clock Metal2-TopMetal1

utl::report "Global route"
global_route -guide_file ${report_dir}/04_${proj_name}_hyp_report_route.guide \
    -congestion_report_file ${report_dir}/04_${proj_name}_hyp_report_route_congestion.rpt \
    -allow_congestion

utl::report "Estimate parasitics"
estimate_parasitics -global_routing
report_metrics "04-01_${proj_name}.hyp_report_grt"
save_checkpoint 04-01_${proj_name}.hyp_report_grt

grt::set_verbose 0

utl::report "Repair design"
repair_design -verbose

utl::report "Skip full-chip setup repair for HyperBus report route"
utl::report "Repair hold"
repair_timing -hold -hold_margin 0.1 -verbose -repair_tns 100

utl::report "GRT incremental"
global_route -start_incremental -allow_congestion
detailed_placement
global_route -end_incremental \
    -guide_file ${report_dir}/04_${proj_name}_hyp_report_route.guide \
    -congestion_report_file ${report_dir}/04_${proj_name}_hyp_report_route_congestion.rpt \
    -allow_congestion

estimate_parasitics -global_routing
report_metrics "04-01_${proj_name}.hyp_report_grt_repaired"
save_checkpoint 04-01_${proj_name}.hyp_report_grt_repaired

utl::report "Repair antennas"
repair_antennas -ratio_margin 30 -iterations 5

utl::report "Detailed route"
set_thread_count 8
detailed_route -output_drc ${report_dir}/04_${proj_name}_hyp_report_route_drc.rpt \
    -drc_report_iter_step 5 \
    -save_guide_updates \
    -clean_patches \
    -droute_end_iter 20 \
    -verbose 1

utl::report "Saving HyperBus report routed checkpoint"
save_checkpoint 04_${proj_name}.hyp_report_routed
report_metrics "04_${proj_name}.hyp_report_routed"
estimate_parasitics -global_routing -spef_file out/${proj_name}_hyp_report.spef

utl::report "###############################################################################"
utl::report "# HyperBus report route complete: ${save_dir}/04_${proj_name}.hyp_report_routed.zip"
utl::report "###############################################################################"
