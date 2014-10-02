simYgivenTheta <- function(theta,w,N) {
  J <- length(theta)
  if( J != length(w) ) {
    error("Error -- need length(w) == J")
  }
  Y <- matrix(NA,J,N)
  for (j in 1:J){
    lambda = w[j]*theta[j]
    Y[j,]=rpois(N,lambda)
  }
  return(Y)
}
