
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name BlockyRoads -dir "C:/Users/fairy/Documents/Computer Science/Digital Logic Design/Project/BlockyRoads/src/BlockyRoads/planAhead_run_2" -part xc7a100tcsg324-1
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "C:/Users/fairy/Documents/Computer Science/Digital Logic Design/Project/BlockyRoads/src/BlockyRoads/BR_Top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/fairy/Documents/Computer Science/Digital Logic Design/Project/BlockyRoads/src/BlockyRoads} {ipcore_dir} }
add_files [list {ipcore_dir/background.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "Nexys4DDR_Master.ucf" [current_fileset -constrset]
add_files [list {Nexys4DDR_Master.ucf}] -fileset [get_property constrset [current_run]]
link_design
