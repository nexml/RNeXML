# simmap.R

# if(!is.null(phy$maps))
## FIXME write the characters/states block (but not matrix block) as well.  

## FIXME support writing multiphylos, list of multiphylos to nexml 

#' @export 
#' @import XML
simmap_to_nexml <- function(phy, state_ids = NULL){

  
  ## Create the NeXML object
  nexml <- as(phy, "nexml")

  if(!is.null(phy$states)){
    nexml <- add_characters(as.data.frame(phy$states, stringsAsFactors=TRUE), nexml)
    chars_ids <- get_state_maps(nexml)[[1]]
    char_id <- names(chars_ids)
    state_ids <-  reverse_map(chars_ids[[1]]) 
    # can assume no other states added yet since works on a phy, not nexml  
  }


  if(!is.null(phy$maps))
    nexml <- simmap_edge_annotations(phy$maps, nexml, state_ids, char_id)
  
 
  nexml
}


simmap_edge_annotations <- function(maps, nexml, state_ids = NULL, char_id = "simmaped_trait"){

  
  ## if state ids are not given
  if(is.null(state_ids)){
    state_ids <- levels(as.factor(names(unlist(maps))))
    names(state_ids) <- state_ids
  }


  # Loop over all edges, adding the simmap annotation to each: 
  for(i in 1:length(nexml@trees[[1]]@tree[[1]]@edge)){
   ## FIXME check to assure this is always the correct order??

    ## Read the mapping of the current edge 
    edge_map <- maps[[i]]

    ## Generate the list of XML "stateChange" nodes 
    mapping <- lapply(1:length(edge_map), function(j){
      ##  A node has an id, a length and a state 
      meta(property = "simmap:stateChange", 
           children = list(meta(propery = "simmap:order",
                                content = j),
                           meta(property = "simmap:length", 
                                content = edge_map[[j]]),
                           meta(property = "simmap:state", 
                                content = state_ids[[names(edge_map[j])]] )
                           )
           )
    })

    reconstruction <-meta(property = "simmap:reconstruction", 
                          children = c(meta(property="simmap:char", 
                                            content = char_id),
                                       mapping))
  
  ## Insert the reconstructions into a <meta> element in each nexml edge
    nexml@trees[[1]]@tree[[1]]@edge[[i]]@meta <- 
      c(meta(type = "LiteralMeta",
             property = "simmap:reconstructions",
             children = list(reconstruction)))
  }

  ## Return the entire nexml object
 nexml <- add_namespaces(c(simmap = "https://github.com/ropensci/RNeXML/tree/master/inst/simmap"),
                        nexml)
 nexml 
}





## Returns list of multiPhylo ...
#' @export 
nexml_to_simmap <- function(nexml){

  ## Get the statemap, if available

  characters <- get_characters(nexml)

  ## loop over trees blocks
  lapply(nexml@trees, function(trees){
    phys <- lapply(trees@tree, 
                   tree_to_simmap, 
                   get_otu_maps(nexml)[[trees@otus]],
                   get_state_maps(nexml)[[1]][[1]]
                  )
    phys <- lapply(phys, characters_to_simmap, characters)

    names(phys) <- NULL
    class(phys) <- "multiPhylo"
    phys 
  })

}

characters_to_simmap <- function(phy, characters){
  out <- as.character(characters[[1]]) # coerce factor to string
  names(out) <- rownames(characters) 
  phy$states <- out
  phy
}


# given the nexml tree:
tree_to_simmap <- function(tree, otus, state_maps = NULL){
  maps <- lapply(tree@edge, function(edge){

    reconstructions <- sapply(edge@meta, function(x) x@property == "simmap:reconstructions")
    if(any(reconstructions))
      reconstruction <- edge@meta[[which(reconstructions)]]@children 

    else {  # handle exceptions 
      warning("no simmap data found")
      return(toPhylo(tree, otus)) ## no simmap found
    }


#    lapply(reconstruction, function(reconstruction){ # for each reconstruction
          stateChange <- sapply(reconstruction[[1]]@children, function(x) x@property == "simmap:stateChange")

          values <- sapply(reconstruction[[1]]@children[[which(stateChange)]], function(stateChange){ 
                           # phytools only supports one reconstruction of one character per phy object
                        property <- sapply(stateChange@children, function(x) x@property)
                        names(stateChange@children) <- property # clean labels
                        sapply(stateChange@children, function(x) x@content)
          })
          out <- as.numeric(values["simmap:length", ])
          ordering <- as.numeric(values["simmap:order",])
          if(!is.null(state_maps))
            states <- state_maps[values["simmap:state", ]]
          else 
            states <- values["simmap:state", ]

          names(out) <- states
          out <- out[ordering] # sort according to explicit order

          out
 #   })
   
  })
  names(maps) <- NULL
  
  phy <- toPhylo(tree, otus)
  phy$maps <- maps

  ## create the rest of the maps elements


  ## Return phylo object
  phy
}


## Extend directly with XML representation instead of S4

#setClass("simmap:reconstructions",
#         slots = c(reconstruction = "ListOfreconstruction"))
#setClass("ListOfreconstruction", contains = "list")
#setClass("simmap:stateChange", contains = "IDTagged") 
#
