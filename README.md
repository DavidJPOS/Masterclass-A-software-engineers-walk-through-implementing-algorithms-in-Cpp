# Masterclass: A software engineers  walkthrough on implementing algorithms in  C++

Here is the companion repo that contains links to software and additional resources that you may find useful.

- Here is the link to [live event](https://teams.microsoft.com/l/meetup-join/19%3ameeting_YWNmMThmZTItMzIxNS00ZGIwLTg1MjYtNWVkYjM2MjlkMDM2%40thread.v2/0?context=%7b%22Tid%22%3a%220084b924-3ab4-4116-9251-9939f695e54c%22%2c%22Oid%22%3a%223d118b9f-3781-4f76-bba6-8a49e4481cf2%22%2c%22IsBroadcastMeeting%22%3atrue%7d).
- R studio cloud instance with the code and packages installed for the talk [here](https://rstudio.cloud/project/1471581). 

## Outline

For academics working in a computationally intensive field, writing code in C++ can drastically reduce the execution times of algorithms. The modern C++ language and standard library enable programmers to write expressive code efficiently, and have many useful features of scripting languages, such as Python, while maintaining the benefits of safety, and runtime speed.

In this talk, [James Giller](https://www.linkedin.com/in/jamesgiller/) will lead us through a simple implementation of a Kalman Filter in C++, which can then be imported and used in R. A Kalman Filter is a method that takes a time series of noisy measurements of some system, and produces estimates for the system’s state variables — for example, estimating the kinematics of a vehicle from camera or LIDAR measurements. He will walk through the considerations he would make when implementing such a method so that the resulting code is both robust and computationally efficient. He will also illustrate a simple example of how to connect C++ code to R via the rcpp package. 

James Giller is a software engineer for Land Rover Jaguar and is currently working on implementing sensor fusion algorithms for use in autonomous driving vehicles. He holds an undergraduate degree in computer science from UCC, an MEng in robotics from Osaka University, Japan, and, before joining JLR, he worked extensively in software engineering for robotics.

## Before the event

You will be able to find an R studio cloud instance with the code and packages installed for the talk [here](https://rstudio.cloud/project/1471581). If this is your first time using R studio cloud, you may need to create an account. The file `Talk_code_Kalman_fitler.r` contains the code for the talk.  After the talk, all the code will be available in this repo. 

After the talk you will be able to implement a simple Kalman filter in C++ and use if from within R.

![Animated plot of the Kalman Filter working on an example positional data set](/filter_y.gif)

## Tutorials and useful links for R and C++

- (Kalman Filter in C++](/Kalman Filter in C++.pdf) contains an introduction to Kalman filters
- Online introductory [book](https://isocpp.org/tour) on C++ by its creator, Bjarne Stroustrup.
- Introductory PDF to the [Rcpp](https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-introduction.pdf) package.
- [Rcpp Gallery](https://gallery.rcpp.org/): a collection of articles and examples for the Rcpp package.
- Advanced R by Hadley Wickham contains useful walk guide to C++ and R can be found [here](http://adv-r.had.co.nz/Rcpp.html).
- Online IDE for R [here](https://rstudio.cloud).
- You can download R from [here](https://www.r-project.org/).
- RStudio is a powerful IDE for R, we will use to compile the C++ code, can be found [here](https://rstudio.com/products/rstudio/download/).
- ggplot function references [here](https://ggplot2.tidyverse.org/reference/).
- An extensive introduction to ggplot2 [here](http://tutorials.iq.harvard.edu/R/Rgraphics/Rgraphics.html).
- The [Armadillo](http://arma.sourceforge.net/docs.html) library for linear algebra in C++.

## Free books on R

- Free online cook book for getting started with R [here](https://rstudio-education.github.io/tidyverse-cookbook/).
- Free online version of R for Data Science by Garrett Grolemund and Hadley Wickham [here](https://r4ds.had.co.nz/).
- Free online version of R Cookbook by James (JD) Long and Paul Teetor [here](https://rc2e.com/).
