#' 'windows of selection' diagram for polygenic
#'
#' much simpler than the monogenic one
#'
#' @import ggplot2 patchwork
#'
#' @examples
#' wos_diag_polygenic()
#'
#' @return ggplot object
#' @export


wos_diag_polygenic <- function() {


#library(ggplot2) library(patchwork)

# normal plot
gg1 <- ggplot(data = data.frame(x = c(-1, 1)), aes(x)) +
  stat_function(fun = dnorm, n = 101, args = list(mean = 0, sd = 1)) +
  ylab("frequency") +
  xlab("resistance\nlevel") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks=c(-1,1),labels=c('low','high')) +
  theme_minimal() +
  theme( panel.grid = element_blank() ) +
  labs(tag="A.") +
  NULL
#gg1

# mortality at t1,t2,t3
df2 <- data.frame(mortality=c( 0,0,0, 1, 1,1),
                     resist=c(-1,1,1,-1,-1,1),
                       time=c('t3','t3','t2','t2','t1','t1')  )

gg2 <- ggplot(df2, aes(x=resist, y=mortality, colour=time)) +
       geom_line() +
      xlab("resistance\nlevel") +
      scale_y_continuous(breaks = NULL) +
      scale_x_continuous(breaks=c(-1,1),labels=c('low','high')) +
      theme_minimal() +
      theme( panel.grid = element_blank() ) +
      labs(tag="B.") +
      NULL
#gg2


# selection gradient at t1,t2,t3
df3 <- data.frame(selection=c(0,1,0),
                  time=c(3,2,1)  )
                  #time=c('t3','t2','t1')  )

gg3 <- ggplot(df3, aes(x=time, y=selection)) +
  geom_point() +
  geom_line(linetype='dashed') +
  ylab("selection\ngradient") +
  scale_y_continuous(breaks = NULL) +
  scale_x_continuous(breaks=c(3,2,1),labels=c('t3','t2','t1')) +
  theme_minimal() +
  theme( panel.grid = element_blank() ) +
  labs(tag="C.") +
  NULL
#gg3


plot( gg1 | gg2 | gg3)

}
