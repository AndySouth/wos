#' plot idealised diagram to illustrate 'windows of selection'
#'
#' mortality over time or declining concentration for RR,SR,SS
#'
#' @param conc_n number of x intervals default 50, will influence smoothness of lines, converted to 0-1
#' @param conc_rr_mort0 concentration killing none of rr
#' @param conc_ss_mort0 concentration killing none of ss
#' @param mort_slope = 3 slope of mortality curves
#' @param sr whether to include heterozygotes
#' @param win_dom_strt dominance of resistance 0-1 determines position of sr between rr & ss but it's not really dominance
#' @param rr_cost cost of resistance to rr (simply added to rr mort)
#' @param dom_cost dominance of cost
#' @param exposure proportion of popn exposed to insecticide only used in the simulations
#' @param max_gen maximum generations to use in the simulations
#' @param startfreq starting frequency to use in the simulations
#' @param title title for ggplot
#' @param addwindow whether to add dotted lines for opening and shutting of window
#' @param addshading whether to shade window
#' @param addlabels whether to add labels
#' @param legendpos where to add legend
#' @param plot whether to plot
#' @param sim whether to run simulation across the window of selection
#' @param adv whether to calculate and output selective advantage
#' @param logadv whether to use log scale in selective advantage plots
#' @param lab_dom whether to add labels of dominance values
# @param xreverse whether to reverse x axis for declining concentration
#'
#' @import ggplot2 dplyr patchwork
#'
#' @examples
#' wos_diagram(mort_slope=3, win_dom_strt=0.9)
#' dfsim <- wos_diagram(sim=TRUE, rr_cost=0)
#' wos_diagram(adv=TRUE,win_dom_strt=0.1)
#'
#' @return ggplot object
#' @export


wos_diagram <- function( conc_n = 50,
                      #conc_rr_mort1 <- 0.7 # concentration killing all of rr
                      #conc_ss_mort1 <- 0.3 # concentration killing all of ss
                      #or try mort 0 because fits better in y=mx+c
                      conc_rr_mort0 = 0.6, # concentration killing none of rr
                      conc_ss_mort0 = 0.1, # concentration killing none of ss
                      mort_slope = 3, #0.5 # slope of mortality curves
                      sr = TRUE, # whether to include heterozygotes
                      win_dom_strt = 0.5, #1 # dominance of resistance 0-1, it's not really dominance
                      rr_cost = 0, #.1, #cost of resistance to rr (simply added to rr mort)
                      dom_cost = 0, #dominance of cost
                      exposure = 0.5, #only used in the simulation
                      max_gen = 1000, #used in simulations
                      startfreq = 0.001,
                      title = "Window of selection",
                      addwindow = TRUE,
                      addshading = TRUE,
                      addlabels = TRUE,
                      legendpos = 'bottom', #'right'
                      plot = TRUE,
                      sim = FALSE,
                      adv = FALSE,
                      logadv = TRUE,
                      lab_dom = FALSE
                      #xreverse = TRUE now xreverse is fixed
) {

  if (rr_cost > 0 & sim) warning('running simulation with rr_cost>0 can cause it to crash')

  concs <- seq(0,1,length=conc_n)
  #trying (and failing) to base directly on helps2017
  #mort_rr <- -log(1+ 10^conc_rr_mort1 * concs^mort_slope)
  #mort_ss <- -log(1+ 10^conc_ss_mort1 * concs^mort_slope)
  #try simpler version based on my own logic to find points based on where they cross y axis
  mort_rr <- mort_slope * (concs-conc_rr_mort0) #+0 #y=m(x-x1)+y1 slope and a point where y=0
  mort_ss <- mort_slope * (concs-conc_ss_mort0)
  #mort_ss <- mort_slope * concs + conc_ss_mort0 #y=mx+c

  #could use ifelse to constrain at 0 & 1 (but must be better way)
  mort_rr <- ifelse(mort_rr>1,1,ifelse(mort_rr<0,0,mort_rr))
  mort_ss <- ifelse(mort_ss>1,1,ifelse(mort_ss<0,0,mort_ss))

  #add cost of resistance : the (1-mort_rr) is a bit of a hack to stop it going above 1
  mort_rr <- mort_rr + rr_cost*(1-mort_rr)

  #sr
  #set where it crosses mort0 to be between ss & rr according to win_dom_strt
  conc_sr_mort0 <- conc_ss_mort0 + win_dom_strt*(conc_rr_mort0-conc_ss_mort0)
  mort_sr <- mort_slope * (concs-conc_sr_mort0) #+0 #y=m(x-x1)+y1 slope and a point where y=0
  mort_sr <- ifelse(mort_sr>1,1,ifelse(mort_sr<0,0,mort_sr))
  #this creates a different pattern from the science paper when dom=0.5
  #i.e. the SR crosses mort1 at same position as RR and mort0 as SS
  #mort_sr <- (win_dom_strt*mort_rr)+((1-win_dom_strt)*mort_ss)

  #remember selection is greatest when heterozygotes survive

  #to calculate where window opens and closes for labels
  #min conc where ssmort1 & rrmort1 == 1
  #win_opens <- min(which(mort_rr==1)) #beware vulnerable if either not 1
  win_opens <- concs[max(which(mort_ss > mort_rr))]
  #min conc where mort_ss > mort_rr
  win_closes <- concs[min(which(mort_ss > mort_rr))]

  sr_win_opens <- concs[max(which(mort_ss > mort_sr))]
  sr_win_closes <- concs[min(which(mort_ss > mort_sr))]

  dfdiag <- dplyr::data_frame( conc = c(concs,concs,concs),
                        genotype = c(rep('rr',conc_n),
                                     rep('ss',conc_n),
                                     rep('sr',conc_n)),
                        #1st line for resistant, 2nd for susceptible
                        mortality = c(mort_rr,
                                      mort_ss,
                                      mort_sr))
  # calc dominance
  #  # 4. Dominance of resistance | (SR-SS)/(RR-SS)
  #beware this relies on being same number of RR,SR,SS all in same order
  #just fills for RR
  dfdiag$dominance <- NA
  dfdiag$dominance[1:length(mort_rr)] <- (mort_sr-mort_ss)/(mort_rr-mort_ss)

  #to allow window polygon plotting
  win_indices <- which(mort_ss > mort_rr)
  dfwindow <- data_frame( conc = concs[win_indices],
                          rr = mort_rr[win_indices],
                          ss = mort_ss[win_indices])
  #experimenting with window for sr
  win_indices <- which(mort_ss > mort_sr)
  dfwin_sr <- data_frame( conc = concs[win_indices],
                          sr = mort_sr[win_indices],
                          ss = mort_ss[win_indices])

  #if not plotting sr just filter it out here
  if (!sr) dfdiag <- filter(dfdiag, genotype!='sr')

  gg <- dfdiag %>%

    ggplot(aes(x=conc, y=mortality, col=genotype, linetype=genotype))+
    geom_line(lwd=2,alpha=0.6) +
    theme_minimal() +
    labs(title = title) +
    #labs(x='Time or declining insecticide concentration') +
    scale_x_continuous(trans = 'reverse',
                       breaks = c(0.2,0.8),
                       labels = c('Low concentration\nLong time after application',
                                  'High concentration\nShort time after application')) +
    scale_y_continuous( limits = c(0,1),
                        breaks = c(0,0.5,1)) +
                        #labels = c(0,50,100)) +

    #make plot cleaner
    theme( legend.position = legendpos,
           legend.title = element_text(size = rel(1.3)),
           legend.text = element_text(size = rel(1.3)),
           legend.key.size = unit(1, "cm"),
           #panel.grid = element_blank(),
           #axis.text.x = element_blank(),
           axis.text.x = element_text(size = rel(1.3)),
           axis.ticks.length = unit(0.5, "cm"), #move labels away from axis
           axis.title.x = element_blank(),
           axis.line.x = element_line(arrow = arrow(length = unit(0.1, "inches"))),
           #plot.title = element_text(hjust = 0.5),
           axis.line.y = element_line())
           #panel.background = element_rect(colour = 'grey60', fill=NA, size=0.5))

  #shading window of selection, i'm not sure whether helpful to shade between
  #the curves or vertically
  #experimenting with changing dfwindow above just to show sr window
  if (addshading) gg <- gg + geom_ribbon(data=dfwindow,aes(x=conc, ymin=rr, ymax=ss),inherit.aes=FALSE, fill = "orange", alpha = .1, show.legend = FALSE)
  #polygon way didn't work
  #geom_polygon(data=filter(dfdiag,genotype!='sr' & conc<=win_opens & conc>=win_closes),aes(x=conc, y=mortality),inherit.aes=FALSE, fill = "orange", alpha = .1, show.legend = FALSE) +

  if (addshading & sr ) gg <- gg + geom_ribbon(data=dfwin_sr,aes(x=conc, ymin=sr, ymax=ss),inherit.aes=FALSE, fill = "red", alpha = .1, show.legend = FALSE)

  #vertical lines for window opening and closing
  if (addwindow) gg <- gg + geom_vline( xintercept = c(win_opens,win_closes), linetype='dotted', lwd=2)


  if (addlabels)
  {
    gg <- gg +
      annotate("text", x = win_opens+0.05, y = 0.75, label = "window opens", angle=90) +
      annotate("text", x = win_closes+0.05, y = 0.75, label = "window closes", angle=90) +
      annotate("text", x = 0.5, y = 0.55, label = "selection for\nresistance", col='red') +
      annotate("text", x = win_opens+0.1, y = 0.5, label = "S & R killed no selection", cex=3, angle=90) +
      annotate("text", x = win_closes-0.1, y = 0.5, label = "selection against resistance (if a cost)", cex=3, angle=90)
    #annotate("text", x = win_opens+0.1, y = 0.9, label = "S & R killed\nno selection", cex=2.5) +
    #annotate("text", x = win_closes-0.1, y = 0.07, label = "selection against\nresistance (if\na cost)", cex=2.5)
  }

  if (lab_dom)
  {
    #may need to sort lab_dom pos depenedent on xreverse, but xreverse may not be needed for wos_diagram
    #if (xreverse)

    gg <- gg +scale_y_continuous( limits=c(0,1.2), breaks=c(0,0.5,1)) +
    #adding dominance values as text
    geom_text(aes(y=1.1, label=signif(dominance,1), col=NULL), size=2.6, col='grey40', angle=45, show.legend=FALSE) +
    annotate("text", x=Inf, y=1.2, hjust=0, label = "dominance", cex=2.6, col='grey40')
  }

  #if (xreverse) gg <- gg + scale_x_continuous(trans='reverse')

  # add calculations of inputs for resistance model
  # not quite sure how I'm going to get out yet ...
  # effectivess, resistance_restoraion and dominance
  # if I do for all elements of conc that will facilitate creating a time-to-resistance plot on same scale
  # these eqs from paper2 based on fitness so need 1-mort, but for dom at least -ves cancel & give same result
  # 1. Effectiveness | 1 - SS
  # 2. Exposure, can't be claculated will need to be provided
  # 3. Resistance restoration  | (RR-SS) / Effectiveness
  # 4. Dominance of resistance | (SR-SS)/(RR-SS)

  #to allow adv to be run without sim (adv is always added to sim)
  if (adv | sim)
  {
    dfadv <- wos_advantage(concs = concs,
                           mort_rr = mort_rr,
                           mort_sr = mort_sr,
                           mort_ss = mort_ss,
                           exposure = exposure,
                           #max_gen = max_gen,
                           startfreq = startfreq)
    if (plot)
    {
      #selective advantage
      # gg_adv <- wos_plot_sim(dfadv, x='conc', y='relative_fitness', ylab='relative\nfitness',
      #                        title=paste0("relative fitness, exposure=",exposure," starting resistance frequency=",startfreq),
      #                        plot=FALSE)
      gg_adv <- wos_plot_sim(dfadv, x='conc', y='selective_advantage', ylab='log selective\nadvantage',
                             xreverse=TRUE, xlog=FALSE, ylog=TRUE, xtxt=FALSE,plot=FALSE,
                             title=paste0("selective advantage, exposure=",exposure," starting resistance frequency=",startfreq))
                             #title=paste0("selective advantage")) #, shape='start_frequency')

      #log selective advantage
      if (logadv) gg_adv <- gg_adv + scale_y_continuous(trans='log')
    }

  }

  if (sim)
  {
     dfsim <- wos_sim(concs = concs,
                     mort_rr = mort_rr,
                     mort_sr = mort_sr,
                     mort_ss = mort_ss,
                     exposure = exposure,
                     max_gen = max_gen,
                     startfreq = startfreq,
                     plot = FALSE
                     )

    if (plot)
    {
      gg_timetor <- wos_plot_sim(dfsim,
                                     title=paste0("simulation, exposure=",exposure," starting resistance frequency=",startfreq),
                                     plot=FALSE)

      gg_dom <- wos_plot_input(dfsim, y='dom_resist', ylab='dominance', plot=FALSE)
      gg_rr <- wos_plot_input(dfsim, y='resist_restor', ylab='resistance restoration', title=NULL, plot=FALSE)
      gg_ef <- wos_plot_input(dfsim, y='effectiveness', ylab='effectiveness', title=NULL, plot=FALSE)

      #plot(gg / gg_timetor / gg_dom / gg_rr / gg_ef + plot_layout(ncol = 1, heights = c(5,5,1,1,1)))
      #plot(gg / gg_timetor / gg_adv / gg_dom / gg_rr / gg_ef + plot_layout(ncol = 1, heights = c(5,5,5,1,1,1)))

      #missing out input plots for now
      plot(gg / gg_timetor / gg_adv + plot_layout(ncol = 1, heights = c(5,5,5)))

    }
    return(dfsim)
  }

  if (adv)
  {
    if (plot) plot(gg / gg_adv)

    #beware having invisible here caused problem with null getting returned
    return(dfadv)
  }


  if ( !adv & !sim )
  {
    if (plot) plot(gg)

    invisible(gg)
  }



}
