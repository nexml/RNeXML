Instructions for compiling manuscripts
======================================

Install dependencies
--------------------

Note that `rmarkdown` requires `pandoc` (>= 0.12) and `pandoc-citeproc` be installed. See [installing pandoc](http://johnmacfarlane.net/pandoc/installing.html). Then from R (with `devtools` R package installed):

```r
devtools::install_github("cboettig/knitcitations@v1")
devtools::install_github("ropensci/RNeXML@devel", dependencies = c("Depends", "Imports", "Suggests"))
devtools::install_github("rstudio/rmarkdown")
```


Build the manuscript
--------------------


If you have the [RStudio Preview release](www.rstudio.com/ide/download/preview) (>= 0.98.932), just open the manuscript.Rmd file in RStudio and try pressing the 'knit pdf' button.

Otherwise, make sure you set the `manuscripts/` as your working directory and then do:

```r
rmarkdown::render("manuscript.Rmd")
```
