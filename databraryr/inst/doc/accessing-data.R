## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::download_video()

## ----eval=FALSE---------------------------------------------------------------
#  nums_vid <- download_video()
#  system(paste0("open ", nums_vid))

## -----------------------------------------------------------------------------
databraryr::list_volume_assets()

## -----------------------------------------------------------------------------
databraryr::list_volume_assets(vb = TRUE)

## ----eval=FALSE---------------------------------------------------------------
#  databraryr::list_volume_assets(vol_id = `<SOME_OTHER_VOLUME_ID>`, rq = rq)

## -----------------------------------------------------------------------------
vol1_assets <- databraryr::list_volume_assets()
names(vol1_assets)

## -----------------------------------------------------------------------------
databraryr::list_volume_assets() |>
  names()

## -----------------------------------------------------------------------------
unique(vol1_assets$asset_format_id)

## -----------------------------------------------------------------------------
db_constants <- databraryr::assign_constants()

formats_df <- purrr::map(db_constants$format, as.data.frame) |>
  purrr::list_rbind()

formats_df

## -----------------------------------------------------------------------------
stats::xtabs(~ format_name, data = vol1_assets)

## -----------------------------------------------------------------------------
vol1_assets |>
  dplyr::filter(format_name == "MPEG-4 video") |>
  dplyr::select(asset_name, asset_duration) |>
  dplyr::mutate(hrs = asset_duration/(60*60*1000)) |>
  dplyr::select(asset_name, hrs) |>
  dplyr::arrange(desc(hrs)) |>
  head(n = 10) |>
  knitr::kable(format = 'html')

## -----------------------------------------------------------------------------
databraryr::list_volume_owners()

## -----------------------------------------------------------------------------
purrr::map(1:15, databraryr::list_volume_owners) |> 
  purrr::list_rbind()

## -----------------------------------------------------------------------------
vol1_list <- databraryr::get_volume_by_id()
names(vol1_list)

## -----------------------------------------------------------------------------
vol1_df <- tibble::tibble(id = vol1_list$id,
                          name = vol1_list$name,
                          doi = vol1_list$creation,
                          permission = vol1_list$permission)
vol1_df

## -----------------------------------------------------------------------------
db_constants <- databraryr::assign_constants()
db_constants$permission

## -----------------------------------------------------------------------------
databraryr::list_volume_funding()

## -----------------------------------------------------------------------------
databraryr::list_volume_links()

## -----------------------------------------------------------------------------
vol1_assets |> 
  dplyr::filter(format_extension == "csv") |>
  databraryr::download_session_assets_fr_df()

