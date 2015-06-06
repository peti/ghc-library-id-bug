# create-report.r

library(data.table)
library(foreach)
library(testthat)

# Import the data set and massage it into a nice table.

inputfiles <- Sys.glob("data/*/*/*/*/*.csv")
builds <- foreach(file = inputfiles, .combine=rbind, .multicombine=TRUE, .inorder=FALSE) %do% {
    seg <- strsplit(file, "/", fixed=TRUE)[[1]]
    expect_equal(seg[1], "data")
    config <- seg[2]
    expect_true(config %in% c("multi-threaded","single-threaded"))
    system <- seg[3]
    compiler <- seg[4]
    build.id <- sub("^([a-z0-9]+)-(haskell-)?(.*)$", "\\1", seg[5])
    package <- sub("^([a-z0-9]+)-(haskell-)?(.*)$", "\\3", seg[5])
    machine <- sub("^(.+)-id\\.csv$", "\\1", seg[6])
    t <- as.data.table(read.csv(file, stringsAsFactors=FALSE))
    t$config <- config
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
expect_false(any(duplicated(builds, by=c("config","build.id","machine","iteration"))))

# Drop fields we don't need and clean up the table.
builds$out <- NULL
builds$build.id <- NULL
builds$iteration <- NULL
setkey(builds, config, ghc, package, system, machine)

# Determine the expected library ID per build type. The notion of an
# "expected id" is a little flaky, because in all honesty we don't know
# what to expect. So we simply interpret the id that occurs strictly
# more often than any other as the "correct" one.

most_common_id <- function(libids) {
    expect_more_than(length(libids), 0)
    t <- as.data.table(as.data.frame(table(libids), stringsAsFactors=FALSE))
    t <- t[order(Freq, decreasing=TRUE)]
    if (nrow(t) > 1) expect_more_than(t[[1,2]], t[[2,2]])
    t[[1,1]]
}

# Assign every build the ID we would have expected, where the expected ID is
# assumed to depend on the configuration, the package, the system, and the
# version of GHC. Note that this convention makes sense from a rational point
# of view, but in fact the expected ID (a.k.a. the ID generated most
# frequently) varies between machines! Looking at the set of all builds, an ID
# 'x' may be the most frequent one, but it happens that build machines to never
# generate 'x' in 100 builds and more. What to make of this? Those IDs are
# truely non-determinstic.
t <- unique(builds[,list(expected=most_common_id(libraryid)),by=list(config,ghc,package,system)])
builds <- merge(builds, t, by=c("config","ghc","package","system"), all=TRUE)
builds[,correct := libraryid==expected]

# Print summaries

print_summary <- function(heading, summary) {
    cat(paste("###", heading, "\n\n"))
    summary[,"%" := round(correct/builds*100, 1)]
    cat("~~~~~~~~~~\n")
    print(summary[order(correct / builds, decreasing=TRUE)])
    cat("~~~~~~~~~~\n\n")
}

print_summary("Summary", builds[ghc=="7.10.1",list(builds=length(correct),correct=sum(correct)),by=config])
print_summary("Summary by package", builds[,list(builds=length(correct),correct=sum(correct)),by=list(config,package)])
print_summary("Summary by package and system", builds[,list(builds=length(correct),correct=sum(correct)),by=list(config,package,system)])
print_summary("Summary by package and build machine", builds[,list(builds=length(correct),ids=length(unique(libraryid)),correct=sum(correct)),by=list(package,machine,config)])
