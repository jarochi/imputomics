# Run from the repository root: Rscript --vanilla update-dependencies.R
options(repos = c(CRAN = "https://cloud.r-project.org"), timeout = 600)
Sys.setenv(RENV_PATHS_LIBRARY = "renv/library",
           RENV_CONFIG_CACHE_ENABLED = "FALSE")
source("renv/activate.R")
renv::upgrade(prompt = FALSE)
renv::settings$use.cache(FALSE)
renv::settings$snapshot.type("explicit")
renv::settings$snapshot.dev(TRUE)
renv::install("BiocManager", prompt = FALSE)
bioc <- as.character(BiocManager::version())
renv::settings$bioconductor.version(bioc)
options(repos = BiocManager::repositories(version = bioc))
renv::install("bioc::BiocVersion", prompt = FALSE)
# These GitHub revisions were verified when this update was prepared.
# Avoid API requests for already installed, pinned revisions.
pinned <- c(DreamAI = "2cc86d1487227e8215a716459a984b49c4aaac84",
            MetabImpute = "7c656be78b096b9015e7d762a9704b4948655cef")
installed_pins <- names(pinned)[vapply(names(pinned), function(pkg) {
  desc <- suppressWarnings(utils::packageDescription(pkg))
  is.list(desc) && identical(desc$RemoteSha, unname(pinned[pkg]))
}, logical(1))]
# The archived missCompare tarball requires these dependencies explicitly.
renv::install(c("ggdendro", "mi"), prompt = FALSE)
renv::install(exclude = installed_pins, prompt = FALSE, transactional = FALSE)
renv::install(c("roxygen2", "testthat", "pkgbuild"), prompt = FALSE)
renv::update(all = TRUE, exclude = names(pinned), prompt = FALSE)
required <- renv::dependencies("DESCRIPTION", dev = TRUE)$Package
missing <- setdiff(required, c(rownames(installed.packages()), "R"))
if (length(missing)) stop("Missing dependencies: ", paste(missing, collapse = ", "))
renv::snapshot(prompt = FALSE)
