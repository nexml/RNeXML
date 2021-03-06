context("simmap")


## Make a simmap tree 
library(phytools)
set.seed(10) 
tree <- rbdtree(b = log(50), d = 0, Tmax = .5)
Q <- matrix(c(-2, 1, 1, 1, -2 ,1 ,1, 1, -2), 3, 3) 
rownames(Q) <- colnames(Q) <- c("A", "B", "C") 
mtree <- sim.history(tree, Q) 

cols <- c("red", "blue", "green")
names(cols) <- rownames(Q)

library(RNeXML)

test_that("we can coerce an ape::phylo tree with a 
          phytools:simmap extension into nexml", {
  nex <- simmap_to_nexml(mtree) 
  expect_is(nex, "nexml")

  phy <- nexml_to_simmap(nex) 

  orig <- plotSimmap(mtree,cols,ftype="off")
  roundtrip <- plotSimmap(phy,cols,ftype="off")

  # checks that the edge mappings are correct 
  expect_equal(mtree$maps, phy$maps)

  # checks that we got the states slot correct 
  expect_equal(mtree$states[sort(names(mtree$states))],
               phy$states[sort(names(phy$states))])
})


test_that("we have the right state ids in the NeXML", {

  
})




