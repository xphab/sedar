`xytrend` <-
function(xy)
{
    require(vegan)
    if(ncol(xy)!=2)
        stop(xy, "'xy' must have exactly 2 columns")
    x <- decostand(xy[,1], method="standardize")
    y <- decostand(xy[,2], method="standardize")
    out <- data.frame(x,y,x^2,x*y,y^2,x^3,x^2*y,x*y^2,y^3)
    colnames(out) <- c("x","y","x2","x.y","y2","x3","x2.y","x.y2","y3")
    return(out)
}

#`xytrend` <-
#function(x, y = NULL, degree = 3)
#{
#    
#    if (is.null(y) && NCOL(x) == 2) {
#        y <- scale(x[,2])
#        x <- scale(x[,1])
#    } else {
#        if (NCOL(x) > 2)
#            stop("x can have max 2 columns")
#        x <- scale(x)
#        y <- scale(y)
#    }
#    out <- data.frame(x,y,x^2,x*y,y^2,x^3,x^2*y,x*y^2,y^3)
#    colnames(out) <- c("x","y","x2","x.y","y2","x3","x2.y","x.y2","y3")
#    out
#}
