# ro_puf:my_ro_puf|ring_oscillator:\ro_chain:13:ro0|ro_nodes[1]

proc compute_x { chain } {
	return [ expr 54 + (${chain} % 8) ]
}

proc compute_y { chain } {
	return [ expr 53 - (${chain} / 8) ] 
}

for { set ro_chain 0 } { ${ro_chain} < 16} { incr ro_chain } {
	for { set ro_link 0 } { ${ro_link} < 13 } { incr ro_link } {
		set x_coord [ compute_x ${ro_chain} ]
		set y_coord [ compute_y ${ro_chain} ]
		set n_coord [ expr 2 * ${ro_link} ]
		set_location_assignment LCCOMB_X${x_coord}_Y${y_coord}_N${n_coord} \
			-to "ro_puf:my_ro_puf|ring_oscillator:\\ro_chain:${ro_chain}:ro0|ro_nodes\[${ro_link}\]"
	}
}

# clock assignment to chip clock
set_location_assignment PIN_P11 -to clock
set_instance_assignment -name IO_STANDARD "3.3V LVTTL" -to clock
# done assignment to LED
set_location_assignment PIN_A8 -to done
set_instance_assignment -name IO_STANDARD "3.3V LVTTL" -to done
# reset assignment to push button
set_location_assignment PIN_B8 -to reset
set_instance_assignment -name IO_STANDARD "3.3V Schmitt Trigger" -to reset