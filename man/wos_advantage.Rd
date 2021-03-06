% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wos_advantage.r
\name{wos_advantage}
\alias{wos_advantage}
\title{wos_advantage calculate selective advantage through 'window of selection'}
\usage{
wos_advantage(dfmortbygen = NULL, x = "concentration",
  y = "mortality", concs = c(1:5), mort_rr = c(0, 0, 0, 0.5, 1),
  mort_sr = c(0, 0, 0.5, 1, 1), mort_ss = c(0, 0.5, 1, 1, 1),
  exposure = 0.5, startfreq = 0.001)
}
\arguments{
\item{dfmortbygen}{dataframe of mortality by genotype, an alternative way of initialising function, needs genotype column}

\item{x}{column name of x in dfmortbygen}

\item{y}{column name of y in dfmortbygen}

\item{concs}{concentration or time}

\item{mort_rr}{rr mortalities}

\item{mort_sr}{sr mortalities}

\item{mort_ss}{ss mortalities}

\item{exposure}{proportion of popn exposed to insecticide}

\item{startfreq}{starting frequency to use in the simulations}
}
\value{
dataframe of simulation outputs
}
\description{
Similar to wos_sim() which simulates time-to-resistance.
Requires either a dataframe with columns for genotype, x (e.g. time) and y (e.g.mortality)
or vectors of x, and yrr,ysr,yss.
}
\examples{
wos_advantage()

}
