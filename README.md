# wos 

An R package for making windows-of-selection plots related to the evolution of insecticide resistance.

Development by Andy South, 2019.

Used in paper accepted to Evolutionary Applications, November 2019.

For script creating exact figures in paper see : https://github.com/AndySouth/windows-of-selection-paper


The code is licensed GPL-3, please cite the paper if you use it.


### Installation

    #install.packages("devtools")
    library(devtools)    
    install_github('AndySouth/wos')  
    library(wos)


### Using the package

Window of selection with just two genotypes, resistant and susceptible, RR & SS.

    wos_diagram(sr=FALSE)


Window of dominance, including heterozygotes

    wos_diagram()


Showing selective advantage.

    wos_diagram(adv=TRUE)


Showing simulation of time-to-resistance (takes a minute or so to run).

    wos_diagram(sim=TRUE, adv=TRUE)


Modifying window of dominance

    wos_diagram(win_dom_strt=0.2, adv=TRUE)


Illustrative polygenic window of selection.

    wos_diag_polygenic()
