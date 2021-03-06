context("Comparative analysis")


library(RNeXML)
library(geiger)


test_that("We can extract tree and trait data to run fitContinuous and fitDiscrete", {
  nexml <- read.nexml(system.file("examples", "comp_analysis.xml", package="RNeXML"))
  traits <- get_characters_list(nexml)
  tree <- get_trees(nexml)
  expect_is(tree, "phylo")
  cts <- fitContinuous(tree, traits[[1]], ncores=1)
  dte <- fitDiscrete(tree, traits[[2]], ncores=1)
})


test_that("We can serialize tree and trait data for a comparative analysis", {
  data(geospiza)
  add_trees(geospiza$phy)
  nexml <- add_characters(geospiza$dat)
  write.nexml(nexml, file = "geospiza.xml")
  expect_true_or_null(nexml_validate("geospiza.xml"))
  unlink("geospiza.xml")
})

