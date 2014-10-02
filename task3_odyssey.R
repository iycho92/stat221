rm(list = ls())

source("poissonLogN_MCMC.R")
source("simYgivenTheta.R")

# Runtime estimate per simulation: 90s
# Target number of simulations: 400 per parameter setting = 20 unique thetas
# and 20 unique Ys per parameter setting

args <- as.numeric(commandArgs(trailingOnly = TRUE))

if(length(args) != 3) {
  stop("Not correct no. of args")
}


params <-  rbind(c(1.6,0.7^2),c(2.5,1.3^2),c(5.2,1.3^2),c(4.9,1.6^2))
numTotalThetadraws <- args[1]
numYdraws <- args[2]
job.id <- args[3]


# Set param for job
N <- 2
J <- 1000
w <- rep(1,J)
param <- params[ceiling(job.id/4),]
numThetadraws <- ceiling(numTotalThetadraws/3)

theta.and.coverage.68 = c()
theta.and.coverage.95 = c()

start.entire <- Sys.time()
runtime.simulations <- 0

for (j in 1:numThetadraws){
  # Draw theta from distribution given by mu and sigma2
  theta <- exp(rnorm(J,param[1],param[2]))
  
  # Vector of booleans of whether theta_j is in the posterior intervals for each draw of Y
  value.covered.68 = matrix(NA,J,numYdraws)
  value.covered.95 = matrix(NA,J,numYdraws)
  
  for (k in 1:numYdraws){
    # Draw Y for given theta
    Y <- simYgivenTheta(theta,w,N) 
    
    # Run mcmc algorithm for Y
    start.single <- Sys.time()
    sim <- poisson.logn.mcmc(Y,w)
    runtime.single <- Sys.time()- start.single
    
    runtime.simulations <- runtime.simulations + runtime.single
    sim.theta <- exp(sim$logTheta)
    
    # Get posterior intervals
    intervals.68 = apply(sim.theta,1,quantile,probs=c(0.16,0.84))
    intervals.95 = apply(sim.theta,1,quantile,probs=c(0.025,0.975))
    
    # Vector of booleans on whether theta_j is in the posterior intervals
    value.covered.68[,k] = (theta > intervals.68[1,]) & (theta < intervals.68[2,])
    value.covered.95[,k] = (theta > intervals.95[1,]) & (theta < intervals.95[2,])  
  }
  
  # Estimate coverage of each theta_j
  coverage.68 = rowSums(1*value.covered.68)/numYdraws
  coverage.95 = rowSums(1*value.covered.95)/numYdraws

  theta.and.coverage.68 = rbind(theta.and.coverage.68,cbind(theta,coverage.68))
  theta.and.coverage.95 = rbind(theta.and.coverage.95,cbind(theta,coverage.95))  
  
}

runtime.entire <- Sys.time()-start.entire
runtime.average.simulation <- runtime.simulations/(numThetadraws*numYdraws)

output = list("theta.and.coverage.68" = theta.and.coverage.68," theta.and.coverage.95" = theta.and.coverage.95,
           "runtime.average.simulation"= runtime.average.simulation,
           "runtime.entire" = runtime.entire,"total.num.simulations" = numThetadraws*numYdraws)
save(output,file=sprintf("odyssey/coverage_%d.rda",job.id))
write.table(c(runtime.entire,runtime.average.simulation,numThetadraws*numYdraws),paste("odyssey/runtimes_",job.id,".txt",collapse=NULL,sep=""))
