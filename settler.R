install.packages(c("dplyr", "rlang", "jsonlite", "gert", "devtools", "renv"))

library(dplyr)
library(rlang)
library(jsonlite)
library(renv)
library(gert)
library(devtools)

# renv::activate()

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


pkg_info_df_git <- pkg_info_df %>% filter(Source == "GitHub")
pkg_info_df <- pkg_info_df %>% filter(Source %in% c("CRAN", "Repository", "Bioconductor", "URL"))

# install packages without github

lapply(seq(from = 1, to = nrow(pkg_info_df)), function(i) {
  Package <- pkg_info_df$Package[i]
  Source <- pkgs_info[[i]]$Source
  Link <- pkg_info_df$Link[i]
  Version <- pkg_info_df$Version[i]
  case_when(Source == "Repository" ~ devtools::install_version(Package, version = Version),
            Source == "Bioconductor" ~ devtools::install_bioc(Package, version = Version),
            Source == "URL" ~ devtools::install_url(Link)
            )
})


# clone github packages and install

dir.create(paste0(getwd(), "/source_pkg/"), showWarnings = FALSE)

lapply(seq(from = 1, to = nrow(pkg_info_df_git)), function(i) {
  Package <- pkg_info_df_git$Package[i]
  Link <- pkg_info_df_git$Link[i]
  git_dir <- file.path(paste0(getwd(), "/source_pkg/", Package))
  git_clone(paste0('https://github.com/', Link), git_dir)
  devtools::install(git_dir)
})

unlink(paste0(getwd(), "/source_pkg/"), recursive = TRUE, force = TRUE)
