transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/ritvi/OneDrive/UIUC/2020\ Spring/ECE\ 385/Lab\ 4/Carry_Select_Adder {C:/Users/ritvi/OneDrive/UIUC/2020 Spring/ECE 385/Lab 4/Carry_Select_Adder/HexDriver.sv}
vlog -sv -work work +incdir+C:/Users/ritvi/OneDrive/UIUC/2020\ Spring/ECE\ 385/Lab\ 4/Carry_Select_Adder {C:/Users/ritvi/OneDrive/UIUC/2020 Spring/ECE 385/Lab 4/Carry_Select_Adder/carry_select_adder.sv}
vlog -sv -work work +incdir+C:/Users/ritvi/OneDrive/UIUC/2020\ Spring/ECE\ 385/Lab\ 4/Carry_Select_Adder {C:/Users/ritvi/OneDrive/UIUC/2020 Spring/ECE 385/Lab 4/Carry_Select_Adder/lab4_adders_toplevel.sv}

