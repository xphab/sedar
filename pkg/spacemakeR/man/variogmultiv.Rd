\name{variogmultiv}
\alias{variogmultiv}
\title{ Function to compute multivariate empirical variogram. }
\description{
  Compute a multivariate empirical variogram. It is strictly equivalent to summing univariate variograms.
}
\usage{
variogmultiv(Y,xy, dmin=0,dmax=max(dist(xy)),nclass=20)
}

\arguments{
  \item{Y}{ A matrix with numeric data. }
  \item{xy}{ A matrix with coordinates of samples. }
  \item{dmin}{ The minimum distance value at which the variogram is computed (i.e. lower bound of the first class). }
  \item{dmax}{ The maximum distance value at which the variogram is computed (i.e. higher bound of the last class). }
  \item{nclass}{ Number of classes of distances. }
}

\value{
  A list:
  \item{d }{Distances (i.e. centers of distance classes).}
  \item{var }{Empirical semi-variances.}
  \item{n.w }{Number of connections between samples for a given distance.}
  \item{n.c }{Number of samples used for the computation of the variogram.}
  \item{dclass }{Character vector with the names of the distance classes.}
}
\references{ Wagner H. H. (2003) Spatial covariance in plant communities: integrating ordination, geostatistics, and variance testing. \emph{Ecology} \bold{84}, 1045--1057. }
\author{ Stephane Dray }
\examples{
data(oribatid)
fau <- sqrt(oribatid$fau/outer(apply(oribatid$fau,1,sum),rep(1,ncol(oribatid$fau)),"*")) # Hellinger transformation
faudt <- resid(lm(as.matrix(fau)~as.matrix(oribatid$xy))) # Removing linear effect
mvspec<-variogmultiv(faudt,oribatid$xy,nclass=20)
mvspec
plot(mvspec$d,mvspec$var,ty='b',pch=20,xlab="Distance", ylab="C(distance)")

}
\keyword{ spatial }
