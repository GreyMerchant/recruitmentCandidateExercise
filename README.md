# Model 1 - linear regression
The first model was a simple linear regression through the lm() function. Depending on the data selected the model will slightly change the regression formula. At a total level, it will accommodate all data and show the interaction between media campaigns and the adstock version of the media spend against search volume within its estimates. Filtering on the campaign will remove the media campaign interaction as part of the regression formula. Efficiencies for the three campaigns were reported by taking the estimates and converting them into standardised beta coefficients.  

# Model 2 - Bayesian regression
The second model was a bayesian linear regression which also made use of a simple call to bayesglm() function. Some basic priors were selected in order for the bayesian model to work. The model results are comparable between the two models. Same considerations were taken on the data and output of the campaigns’ efficiencies. 

# Results
Results are presented here in Shiny as requested: https://docgrey.shinyapps.io/CandidateExercise/

# Additional comments
Regrettably, I did not have as much time as I would have liked to work on this project since other work related projects exceeded normal hours. If I had more time, I would have created additional wrappers around the regression and graph functions in order to have them as specified in the document with appropriate documentation. For the adstock function I did at least go through these steps to demonstrate it. In addition, I would have done more regular commits to show good practice with code commits. 


# Recruitment Candidate Exercise
Exercise for Solutions Analytics Director role

This exercise aims to gain an understanding of how a brand’s advertising spend has influenced the levels of weekly Google Search volumes that were made for the brand in a particular country.

In this case, the advertising has specifically intended to increase in Search volumes and over time three different (non-overlapping) advertising campaigns have been used.

Data for the weekly Search volumes; the advertising spend; and where the three different campaigns take place are available.

The task is to create two different modelling approaches for the data with Search Volume as the dependent. The aim is use the media spend to gain an understanding of which of the campaigns appear to have more effectively and efficiently generated additional Search volumes.

Because the media/advertising spend will have an impact in the week in which it takes place and a decaying effect in future weeks, it is necessary to represent the media spend in the model in the form of a 'recent advertising pressure' measure. This type of measure with media spend is called an Adstock; and it is in this form that the advertising should be used as an independent variable in the model. The Adstock calculation takes the form:

Adstock (in week n) = Media Spend (in week n) + [ RF x Adstock (in week n-1) ]

The RF is the Retention Factor [0,1] describing the proportion of the media pressure the is carried over from week to week.

Results for the two modelled approaches should be delivered as a Shiny App.

There should be a slider to allow the viewer to alter the value of the RF (in increments of 0.1); and as well as a chart showing the model fit, there should also be a table that reports the efficiencies for the three campaigns.

The models don’t need to be complicated and the Shiny app UI should be simple. Templated Shiny UI is enough. We expect that each model will use its own function with appropriate documentation and that the code will be pushed to your Github repository. We expect to see at least two commits. Along with pushing your code to Github, you should deploy your Shiny app on the Shiny server (using a free account https://www.shinyapps.io/).

The data for the exercise are available here https://github.com/schubertjan/recruitmentCandidateExercise. You are expected to fork the repository into your own Github account and make any code commits in this forked repository.