install.packages(c("dplyr", "rlang", "jsonlite", "gert", "renv"))

library(dplyr)
library(jsonlite)
library(gert)
library(rlang)
library(renv)

lockfile <- fromJSON("renv.lock", simplifyVector = F)
pkgs_info <- lockfile$Packages
failed <- character()
pkg_names <- names(pkgs_info)

pkg_info_df <- lapply(pkg_names, function(i) {
  Package <- pkgs_info[[i]]$Package
  Source <- pkgs_info[[i]]$Source
  Version <- pkgs_info[[i]]$Version
  Link <- dplyr::case_when(
    Source == "Repository" ~ paste0(Package, "@", Version),
    # Source == "GitHub" ~ pkgs_info[[i]]$RemotePkgRef %||% NA_character_,
    Source == "GitHub" ~  paste0(pkgs_info[[i]]$RemoteUsername, "/", pkgs_info[[i]]$RemoteRepo),
    Source == "Bioconductor" ~ paste0("bioc::", Package),
    Source == "URL" & length(pkgs_info[[i]]$RemotePkgRef) > 0 ~ pkgs_info[[i]]$RemotePkgRef %||% NA_character_,
    Source == "URL" & length(pkgs_info[[i]]$RemotePkgRef) == 0 ~ pkgs_info[[i]]$RemoteUrl %||% NA_character_
  )
  data.frame(Package = Package, Source = Source, Version = Version, Link = Link, stringsAsFactors = FALSE)
}) %>% do.call(rbind, .)

lapply(pkg_info_df$Link, function(i) {
  renv::install(i, dependencies = "all", prompt = FALSE)
})
