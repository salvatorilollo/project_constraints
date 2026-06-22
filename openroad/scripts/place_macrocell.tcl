# Place a multirow standard-cell-like macro on the row/site grid.
#
# Usage:
#   place_macrocell <instance-name-or-dbInst> <rough-llx-um> <rough-lly-um> ?orient? ?status?
#
# Coordinates are in microns.  The Y coordinate is snapped to the closest
# non-mirrored row, so the instance starts on the normal VSS-at-bottom rail
# phase.  The X coordinate is snapped to the nearest legal site in that row and
# clamped so the instance still fits.
proc place_macrocell {inst_ref rough_llx rough_lly {orient R0} {status FIRM}} {
  set block [ord::get_db_block]
  if {$block eq "" || $block eq "NULL"} {
    error "No OpenDB block is loaded"
  }

  if {[catch {$inst_ref getName}]} {
    set inst [$block findInst $inst_ref]
    if {$inst eq "" || $inst eq "NULL"} {
      error "Could not find instance '$inst_ref'"
    }
  } else {
    set inst $inst_ref
  }

  set master [$inst getMaster]
  set inst_width_dbu [$master getWidth]
  set rough_x_dbu [ord::microns_to_dbu $rough_llx]
  set rough_y_dbu [ord::microns_to_dbu $rough_lly]

  set best_row ""
  set best_x_dbu 0
  set best_y_delta 0
  set best_x_delta 0

  foreach row [$block getRows] {
    set row_orient [$row getOrient]
    if {$row_orient ne "R0" && $row_orient ne "N"} {
      continue
    }

    set row_origin [$row getOrigin]
    set row_x [lindex $row_origin 0]
    set row_y [lindex $row_origin 1]
    set site_step [$row getSpacing]
    set site_count [$row getSiteCount]
    if {$site_step <= 0 || $site_count <= 0} {
      continue
    }

    set inst_sites [expr {int(ceil(double($inst_width_dbu) / $site_step))}]
    set max_site [expr {$site_count - $inst_sites}]
    if {$max_site < 0} {
      continue
    }

    set site_idx [expr {int(floor((double($rough_x_dbu - $row_x) / $site_step) + 0.5))}]
    if {$site_idx < 0} {
      set site_idx 0
    } elseif {$site_idx > $max_site} {
      set site_idx $max_site
    }

    set x_dbu [expr {$row_x + $site_idx * $site_step}]
    set y_delta [expr {abs($row_y - $rough_y_dbu)}]
    set x_delta [expr {abs($x_dbu - $rough_x_dbu)}]
    if {$best_row eq "" ||
        $y_delta < $best_y_delta ||
        ($y_delta == $best_y_delta && $x_delta < $best_x_delta)} {
      set best_row $row
      set best_x_dbu $x_dbu
      set best_y_dbu $row_y
      set best_y_delta $y_delta
      set best_x_delta $x_delta
    }
  }

  if {$best_row eq ""} {
    error "Could not find a non-mirrored row that can fit instance [$inst getName]"
  }

  $inst setOrient $orient
  $inst setLocation $best_x_dbu $best_y_dbu
  $inst setPlacementStatus $status

  set x_um [ord::dbu_to_microns $best_x_dbu]
  set y_um [ord::dbu_to_microns $best_y_dbu]
  set msg [format "place_macrocell %s at %.3f %.3f %s on %s" \
    [$inst getName] $x_um $y_um $orient [$best_row getName]]
  if {[llength [info commands utl::report]]} {
    utl::report $msg
  } else {
    puts $msg
  }

  return [dict create \
    instance [$inst getName] \
    master [$master getName] \
    row [$best_row getName] \
    row_orient [$best_row getOrient] \
    x $x_um \
    y $y_um \
    x_dbu $best_x_dbu \
    y_dbu $best_y_dbu \
    orient $orient \
    status $status]
}
