###############################################################################################
## Project: C++ master class 
## Script purpose: set up the workspace for C++ master class
## Date: 20-7-2020
## Author: David JP O'Sullivan and James Giller
###############################################################################################

rm(list = ls())
gc()
# what packages doe we want? 
list_of_packages <- c("Rcpp", # binding for R to C++ 
                      "RcppArmadillo", # install the linear algebra library for C++
                      'tidyverse',  # to read in data
                      'cowplot', # for nice looking plots
                      'gganimate'
)
# check if we already have them
new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]

# if non zero install the packages. 
if(length(new_packages)) install.packages(new_packages)

# load the libraries
library(Rcpp)
library(RcppArmadillo)
library(tidyverse)
library(cowplot)
library(gganimate)

theme_set(theme_cowplot()) # load the nice plotting theme


# work example --------------------------------------------------------------------------------

# use the Rcpp package to compile the document
Rcpp::sourceCpp('kalman_filter.cpp')
zs <- read_csv(file = './position_data_extend.csv', col_names = c('x', 'y'))

n <- length(zs$x) # now many measurement do we have?
dt <- 1

# create a data frame ot hold the results
res <- tibble(time = seq(from = 0, by = dt, length.out = n), # add time col 
              x_true = zs$x, y_true = zs$y, # add true position
              # for this example, create measurements by adding noise to true position
              x_mes = x_true + rnorm(n, sd = 0.25), y_mes = y_true + rnorm(n, sd = 0.25), 
              x_est = numeric(n), y_est = numeric(n),  # where we store the estimate of position
              x_residual = numeric(n), # store errors
              y_residual = numeric(n),
              x_sd = numeric(n), # store the std
              y_sd = numeric(n)) 

# what is the dimension of the model and measurements
x_dim <- 6
z_dim <- 2

kalman_filter <- new(KalmanFilter, x_dim, z_dim)

# where is the position at the start and how confident are we in it
x0 <- rep(0,6)
P0 <- diag(6)
diag(P0) <- c(1,1, rep(0,4))

kalman_filter$initialiseEstimate(x0, P0)

# how does the model state change between time steps
F_mat <- matrix(
  data = c(1.0, 0.0, dt, 0.0, 0.0, 0.0, # x
           0.0, 1.0, 0.0, dt, 0.0, 0.0, # y
           0.0, 0.0, 1.0, 0.0, dt, 0.0, # vx
           0.0, 0.0, 0.0, 1.0, 0.0, dt, # vy
           0.0, 0.0, 0.0, 0.0, 1.0, 0.0, # ax
           0.0, 0.0, 0.0, 0.0, 0.0, 1.0),
  ncol = 6, nrow = 6, byrow = TRUE
)

# how confident are we in the model?
Q_mat <- diag(6)

# add these to the kalman_filter object
kalman_filter$setProcessModel(F_mat, Q_mat)

H_mat <- matrix(
  data = c(1.0, 0.0, 0.0, 0.0, 0.0, 0.0, # select x
           0.0, 1.0, 0.0, 0.0, 0.0, 0.0),
  nrow = 2, ncol = 6, byrow = TRUE
)
R_mat <- 1000 * diag(2)
kalman_filter$setMeasurementModel(H_mat, R_mat)

# cycle through the two steps
for(row_i in 1:nrow(res)){ # row_i <- 1
  
  # Iterate the following
  prediction <- kalman_filter$predict()
  z <- array(c(res$x_mes[row_i], res$y_mes[row_i]), c(2, 1)) 
  estimate <- kalman_filter$update(z)
  
  res$x_est[row_i] <- prediction$prior[1]
  res$y_est[row_i] <- prediction$prior[2]
  
  res$x_residual[row_i] <- estimate$residual[1]
  res$y_residual[row_i] <- estimate$residual[2]
  
  res$x_sd[row_i] <- sqrt(estimate$posterior_covariance[1,1])
  res$y_sd[row_i] <- sqrt(estimate$posterior_covariance[2,2])
}

# plotting ------------------------------------------------------------------------------------

# plot x y positions
p1 <- ggplot(res, aes(x = x_mes, y = y_mes)) + geom_point() +
  geom_point(aes(x = x_est, y = y_est), color = 'red', pch = 1) + 
  geom_segment(aes(x = x_mes, y = y_mes, xend = x_est, yend = y_est), alpha = 0.5 , color = 'grey')
  ggtitle(
    label = 'Kalman Filter',
    subtitle = 'Test vector for the Kalman filtering with 2 sudden discontinuities '
  ) +
  xlab('x position') + ylab('y position')

# plots the x and y with time
p2 <- ggplot(res, aes(x = time, y = x_true)) + 
  geom_line(size = 1.2) +
  geom_line(aes(y = x_est), color = 'blue') +
  geom_point(aes(y = x_mes, group = seq_along(time)), pch = 1, color = 'red') +
  ggtitle(
    label = 'Kalman Filter',
    subtitle = 'Test vector for the Kalman filtering with 2 sudden discontinuities '
  ) +
  xlab('time') + ylab('x position')

p3 <- ggplot(res, aes(x = time, y = y_true)) + 
  geom_line(size = 1.2) +
  geom_line(aes(y = y_est), color = 'blue') +
  geom_point(aes(y = y_mes, group = seq_along(time)), pch = 1, color = 'red') +
  xlab('time') + ylab('y position')


pg1 <- plot_grid(p2, p3, nrow = 2)

p1
pg1
ggsave(filename = './xy_post.png', plot = p1)
ggsave(filename = './xy_overtime.png', plot = pg1)


# create the residuals plots
p4 <- ggplot(res, aes(x = time, y = x_residual)) + 
  geom_hline(yintercept = 0, color = 'grey') +
  geom_line(aes(y = x_sd), linetype = 'dashed', color = 'grey') + 
  geom_line(aes(y = -x_sd), linetype = 'dashed', color = 'grey') +
  geom_ribbon(aes(ymin = -x_sd, ymax = x_sd), fill = 'yellow', alpha = 0.5) + 
  geom_line() +
  ylab('x residual') +
  ggtitle(label = 'filter residual plot')

p5 <- ggplot(res, aes(x = x_residual)) +
  geom_histogram(color = 'black', fill = 'steelblue') +
  xlim(-2,2) + 
  xlab('x residual') + 
  ggtitle(label = 'distribution of residuals')


p6 <- ggplot(res, aes(x = time, y = y_residual)) + 
  geom_ribbon(aes(ymin = -y_sd, ymax = y_sd), fill = 'yellow', alpha = 0.5) + 
  geom_hline(yintercept = 0, color = 'grey') + 
  geom_line(aes(y = y_sd), linetype = 'dashed', color = 'grey') + 
  geom_line(aes(y = -y_sd), linetype = 'dashed', color = 'grey') +
  geom_line() +
  ylab('y residual')

p7 <- ggplot(res, aes(x = x_residual)) +
  geom_histogram(color = 'black', fill = 'steelblue') +
  xlim(-2,2) + 
  xlab('y residual')  

# plots the residuals in one plot
pg2 <- plot_grid(p4,p5,p6,p7, nrow = 2, rel_widths = c(2 , 1.5))
pg2

ggsave(filename = './filter_residuals.png', plot = pg2, width = 9, height = 6)
# animation -----------------------------------------------------------------------------------

p_ani_1 <- 
  ggplot(res, aes(x = time, y = x_true)) + 
  geom_line(size = 1.2) +
  geom_line(aes(y = x_est), color = 'blue') +
  geom_point(aes(y = x_mes, group = seq_along(time)), pch = 1, color = 'red') +
  ggtitle(
    label = 'Kalman Filter',
    subtitle = 'Test vector for the Kalman filtering with 2 sudden discontinuities '
  ) +
  xlab('time') + ylab('y position') + 
  scale_color_viridis_d(end = 0.8)


gif_ani_1 <- p_ani_1 + 
  transition_reveal(time) +
  # labs(subtitle = "Time: {frame_time}") + 
  # ease_aes('linear', interval = 0.001) + 
  view_follow(fixed_y = TRUE, fixed_x = TRUE)

# duration = 40, fps = 50
animate(gif_ani_1, height = 500, width = 800)
anim_save("filter_x.gif")

p_ani_2 <- 
  ggplot(res, aes(x = time, y = y_true)) + 
  geom_line(size = 1.2) +
  geom_line(aes(y = y_est), color = 'blue') +
  geom_point(aes(y = y_mes, group = seq_along(time)), pch = 1, color = 'red') +
  ggtitle(
    label = 'Kalman Filter',
    subtitle = 'Test vector for the Kalman filtering with 2 sudden discontinuities '
  ) +
  xlab('time') + ylab('y position') + 
  scale_color_viridis_d(end = 0.8)


gif_ani_2 <- p_ani_2 + 
  transition_reveal(time) +
  # labs(subtitle = "Time: {frame_time}") + 
  ease_aes('linear', interval = 0.001) + 
  view_follow(fixed_y = TRUE, fixed_x = TRUE)

# duration = 40, fps = 50
animate(gif_ani_2, height = 500, width = 800)
anim_save("filter_y.gif")