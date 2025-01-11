
# this script runs the commands and creates errors when they don't work
# not as optimal as unit testing but it quickly informs us if the package
# isn't working

library(PVplr)

# Data Cleaning
test_var_list <- plr_build_var_list(time_var = "timestamp", power_var = "power", irrad_var = "g_poa", temp_var = "mod_temp", wind_var = NA)
test_dfc <- plr_cleaning(test_df, test_var_list)

# PLR Determining Tests
test_xbx_dbd_res <- plr_xbx_model(test_dfc, test_var_list, by = "day")
test_xbx_wbw_res <- plr_xbx_model(test_dfc, test_var_list, by = "week")
test_xbx_mbm_res <- plr_xbx_model(test_dfc, test_var_list, by = "month")

test_pvusa_dbd_res <- plr_pvusa_model(test_dfc, test_var_list, by = "day")
test_pvusa_wbw_res <- plr_pvusa_model(test_dfc, test_var_list, by = "week")
test_pvusa_mbm_res <- plr_pvusa_model(test_dfc, test_var_list, by = "month")

# 6K model struggles with low data inputs for fitting 
# daily time segment cannot be used without higher data resolution
test_6k_dbd_res <- plr_6k_model(test_dfc, test_var_list, by = "week", nameplate_power = 230)
test_6k_dbd_res <- plr_6k_model(test_dfc, test_var_list, by = "month", nameplate_power = 230)

test_predutc_dbd_res <- plr_xbx_utc_model(test_dfc, test_var_list, by = "day")
test_predutc_wbw_res <- plr_xbx_utc_model(test_dfc, test_var_list, by = "week")
test_predutc_mbm_res <- plr_xbx_utc_model(test_dfc, test_var_list, by = "month")

# remove outliers (just one)
test_xbx_dbd_res_no_outliers <- plr_remove_outliers(test_xbx_dbd_res)
