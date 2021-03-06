#####################
# Function chooseCN
#####################
chooseCN <- function(xy,ask=TRUE, type=NULL, result.type="nb", d1=NULL, d2=NULL, k=NULL,
                     a=NULL, dmin=NULL, plot.nb=TRUE, edit.nb=FALSE){
  
  if(is.data.frame(xy)) xy <- as.matrix(xy)
  if(ncol(xy) != 2) stop("xy does not have two columns.")
  if(any(is.na(xy))) stop("NA entries in xy.")
  result.type <- tolower(result.type)
  
  if(!require(spdep, quiet=TRUE)) stop("spdep library is required.")

  res <- list()
  d1.first <- d1
  d2.first <- d2
  k.first <- k
  
  ## check for uniqueness of coordinates
  x <- xy[,1]
  y <- xy[,2]
  temp <- table(x,y)
  if(any(temp>1) & (!is.null(type) && type!=7)){ # coords need not be unique if type==7 (inverse distances)
    xy <- jitter(xy)
    warning("Random noise was added to xy as duplicated coordinates existed.")
  }
  
  ## handle type argument
  if(!is.null(type)){
      type <- as.integer(type)
      if(type < 1 |type > 7) stop("type must be between 1 and 7")
      ask <- FALSE
  }

  if(is.null(type) & !ask) { type <- 1 }
  
  ### begin large while ###
  chooseAgain <- TRUE
  while(chooseAgain){
    # re-initialisation of some variables
    d1 <- d1.first
    d2 <- d2.first
    k <- k.first    
    
  ## read type from console
    if(ask){
      temp <- TRUE
      while(temp){
        cat("\nChoose a connection network:\n")
        cat("\t Delaunay triangulation (type 1)\n")
        cat("\t Gabriel graph (type 2)\n")
        cat("\t Relative neighbours (type 3)\n")
        cat("\t Minimum spanning tree (type 4)\n")
        cat("\t Neighbourhood by distance (type 5)\n")
        cat("\t K nearest neighbours (type 6)\n")
        cat("\t Inverse distances (type 7)\n")
        cat("Answer: ")
        
        type <- as.integer(readLines(n = 1))
        temp <- type < 1 |type > 7
        if(temp) cat("\nWrong answer\n")
      } # end while
    }
    ## 
    
    ## graph types
    ## type 1: Delaunay
    if(type==1){
      if(!require(tripack, quiet=TRUE)) stop("tripack library is required.")
      cn <- tri2nb(xy)
    }
    
    # type 2: Gabriel
    if(type==2){
      cn <- gabrielneigh(xy)
      cn <- graph2nb(cn, sym=TRUE)
    }
    
    ## type 3: Relative neighbours
    if(type==3){
      cn <- relativeneigh(xy)
      cn <- graph2nb(cn, sym=TRUE)
    }
  
    ## type 4: Minimum spanning tree
    if(type==4){
      if(!require(ade4, quiet=TRUE)) stop("ade4 library is required.")
      cn <- mstree(dist(xy))
      cn <- neig2nb(cn)
    }
  
    ## type 5: Neighbourhood by distance
    if(type==5){
      if(is.null(d1) |is.null(d2)){
        tempmat <- as.matrix(dist(xy))
        d2min <- max(apply(tempmat, 1, function(r) min(r[r>1e-12])))
        d2max <- max(dist(xy))
        dig <- options("digits")
        options("digits=5")
        cat("\n Enter minimum distance: ")
        d1 <- as.numeric(readLines(n = 1))
        cat("\n Enter maximum distance \n(dmin=", d2min, ", dmax=", d2max, "): ")
        d2 <- as.numeric(readLines(n = 1))
        options(dig)
      }
    # avoid that a point is its neighbour
      dmin <- mean(dist(xy))/100000
      if(d1<dmin) d1 <- dmin
      if(d2<d1) stop("d2 < d1")
      cn <- dnearneigh(x=xy, d1=d1, d2=d2)
    }
  
    ## type 6: K nearests
    if(type==6){
      if(is.null(k)) {
        cat("\n Enter the number of neighbours: ")
        k <- as.numeric(readLines(n = 1))
      }
      cn <- knearneigh(x=xy, k=k)
      cn <- knn2nb(cn, sym=TRUE)
    }
    
    ## type 7: inverse distances
    if(type==7){
        if(is.null(a)) {
            cat("\n Enter the exponent: ")
            a <- as.numeric(readLines(n = 1))
        }
        cn <- as.matrix(dist(xy))
        if(is.null(dmin)) {
            cat("\n Enter the minimum distance \n(range = 0 -", max(cn),"): ")
            dmin <- as.numeric(readLines(n = 1))
        }
        if(a<1) { a <- 1 }
        thres <- mean(cn)/1e8
        if(dmin > thres) dmin <- thres
        cn[cn < dmin] <- dmin
        cn <- 1/(cn^a)
        diag(cn) <- 0
        cn <- prop.table(cn,1)
        plot.nb <- FALSE
        edit.nb <- FALSE
        result.type <- "listw"
    } # end type 7
 
## end graph types

    if(ask & plot.nb) {
      plot(cn,xy)
      cat("\nKeep this graph (y/n)? ")
    ans <- tolower(readLines(n=1))
      if(ans=="n") {chooseAgain <- TRUE} else {chooseAgain <- FALSE}
    }
    else if(plot.nb){
      plot(cn,xy)
      chooseAgain <- FALSE
    }
  else {chooseAgain <- FALSE}
    
  }
### end large while
  
  if(edit.nb) {cn <- edit(cn,xy)}
  
  if(result.type == "listw") {
      if(type!=7) {
          cn <- nb2listw(cn, style="W", zero.policy=TRUE)
      } else {
          cn <- mat2listw(cn)
          cn$style <- "W"
      }
  }

  res <- cn

  attr(res,"xy") <- xy
  
  return(res)
  
} # end chooseCN

