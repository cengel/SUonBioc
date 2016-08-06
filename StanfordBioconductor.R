library(rvest)

# get package list (3.3) from here https://www.bioconductor.org/packages/3.3/bioc/
version <- "3.3" # Bioconductor Version
Bioc <- read_html(paste0("https://www.bioconductor.org/packages/", version, "/bioc/"))
BiocMaint <- html_table(Bioc)[[1]]

# helps us to extract Maintainer from each package page:
getMntEmail <- function(packageName) {
  # compose URL with this: https://www.bioconductor.org/packages/3.3/bioc/html/[pckgname].html
  u <- paste0("https://www.bioconductor.org/packages/", version, "/bioc/html/", packageName, ".html") 
  pg <- read_html(u)
  # On each page, find the div and retrieve the line that list Maintainer like:
  # Maintainer: Tobias Verbeke <tobias.verbeke at openanalytics.eu>...
  pg.node <- html_nodes(pg, "div.do_not_rebase p")
  mnt <- html_text(pg.node[grep("Maintainer: ", pg.node)]) # look for "Maintainer" string
  mnt <- sub("Maintainer: ", "", mnt) # clean up
  return(mnt)
}

# retreiving 1200+ pages takes a while..
#BiocMaint$Email <- do.call("rbind", sapply(BiocMaint$Package, function(p) getMnt(p), simplify = F))
BiocMaint$Email <- unlist(sapply(BiocMaint$Package, function(p) getMntEmail(p)))

# List Stanford only and their packages:
su <- BiocMaint[grep("stanford", tolower(BiocMaint$Email)),]
su[order(su$Package),]
write.csv(su[order(su$Package),], "SUMaintainers.csv", row.names = F)

  
