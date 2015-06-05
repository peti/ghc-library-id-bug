# create-workspace.r

library(data.table)
library(foreach)
library(testthat)

# Import the data set and massage it into a nice table.

inputfiles <- Sys.glob("data/*/*/*/*.csv")
builds <- foreach(file = inputfiles, .combine=rbind, .multicombine=TRUE, .inorder=FALSE) %do% {
    seg <- strsplit(file, "/", fixed=TRUE)[[1]]
    expect_equal(seg[1], "data")
    system <- seg[2]
    compiler <- seg[3]
    build.id <- sub("^([a-z0-9]+)-(haskell-)?(.*)$", "\\1", seg[4])
    package <- sub("^([a-z0-9]+)-(haskell-)?(.*)$", "\\3", seg[4])
    machine <- sub("^(.+)-id\\.csv$", "\\1", seg[5])
    t <- as.data.table(read.csv(file, stringsAsFactors=FALSE))
    t$system <- system
    t$build.id <- build.id
    t$package <- package
    t$libraryid <- sapply(t$libraryid, sub, pattern=paste0("^",package,"-"), replacement="")
    expect_true(all(grepl("^[0-9a-z]+$", t$libraryid)))
    t$machine <- machine
    t
}
builds <- within(builds, {
    out <- sub("^/nix/store/([a-z0-9]+)-ghc-(.*)$", "\\1", storepath)
    ghc <- sub("^/nix/store/([a-z0-9]+)-ghc-(.*)$", "\\2", storepath)
    ghc <- factor(ghc, levels=ordered(unique(ghc)))
    storepath <- NULL
    system <- factor(system, levels=ordered(unique(system)))
    package <- factor(package, levels=ordered(unique(package)))
    build.id <- factor(build.id, levels=ordered(unique(build.id)))
    machine <- factor(machine, levels=ordered(unique(machine)))
})

# The 'out' path must be unique for every build.
expect_false(any(duplicated(builds$out)))

# The 'build.id' uniquely identifies the build type, i.e. the triple
# (system, package, ghc).
build.types <- unique(builds[,paste(system,package,ghc)])
build.hashes <- unique(builds$build.id)
expect_equal(length(build.types), length(build.hashes))

# The tuple (machine, iteration) must be unique per build type.
expect_false(any(duplicated(builds, by=c("build.id","machine","iteration"))))

# Drop fields we don't need and clean up the table.
builds$out <- NULL
builds$build.id <- NULL
builds$iteration <- NULL
setkey(builds, ghc, package, system, machine)

# Determine the library ID would expect per build type. The notion of an
# "expected id" is a little flaky, because we don't know what to expect,
# so we simply interpret the id that occurs strictly more often than any
# other as the "correct" one.

most_common_id <- function(libids) {
    expect_more_than(length(libids), 0)
    t <- as.data.table(as.data.frame(table(libids), stringsAsFactors=FALSE))
    t <- t[order(Freq, decreasing=TRUE)]
    if (nrow(t) > 1) expect_more_than(t[[1,2]], t[[2,2]])
    t[[1,1]]
}

t <- unique(builds[,list(expected=most_common_id(libraryid)),by=list(ghc,package,system)])
builds <- merge(builds, t, by=c("ghc","package","system"), all=TRUE)
builds[,correct := libraryid==expected]

# How to print a summary

print_summary <- function(heading, summary) {
    cat(paste("### Summary", heading, "\n\n"))
    summary[,"%" := round(correct/builds*100, 1)]
    cat("~~~~~~~~~~\n")
    print(summary)
    cat("~~~~~~~~~~\n\n")
}

print_summary("for GHC 7.10.1", builds[ghc=="7.10.1",list(builds=length(correct),correct=sum(correct))])
print_summary("for GHC 7.10.1 by package", builds[ghc=="7.10.1",list(builds=length(correct),correct=sum(correct)),by=package])
print_summary("for GHC 7.10.1 by package and system", builds[ghc=="7.10.1",list(builds=length(correct),correct=sum(correct)),by=list(package,system)])
print_summary("for GHC 7.10.1 by package, system, and build machine", builds[ghc=="7.10.1",list(builds=length(correct),correct=sum(correct)),by=list(package,system,machine)])
