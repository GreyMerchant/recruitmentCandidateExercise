library(shiny) #for the app
library(readr) #reading data
library(tidyverse) # %>% and dplyr
library(arm) #bayesian lm
library(lubridate) #time variables
library(lm.beta) #standardised beta coefficients


# Importing additional functions ------------------------------------------
source("adstock.R")


# Defining simple UI for application
# UI section --------------------------------------------------------------
ui <- fluidPage(
  # Title of Application
  titlePanel("Investigating advertising spend on search volumes:"),
  # Sidebarpanel for inputs -----------------------------------------------
  sidebarLayout(
    sidebarPanel(
      # Slider for retention factor
      selectInput(
        "dataset",
        "Selected data:",
        c(
          "Total (2014 - 2016)" = 0,
          "Campaign 1 (2014)" = 1,
          "Campaign 2 (2015)" = 2,
          "Campaign 3 (2016)" = 3
        )
      ),
      sliderInput(
        "retention_factor",
        "Retention Factor:",
        min = 0,
        max = 1,
        value = 0,
        step = 0.1,
        animate = animationOptions(interval = 1000, loop = TRUE)
      ),
      helpText(
        "Note: Adjusting the Retention Factor (RF) will affect the
        proportion of media pressure that is carried over from week to week."
      )
    ),

    # Main panel for outputs ----------------------------------------------
    mainPanel(tabsetPanel(
      type = "tabs",
      tabPanel(
        "Model 1 - Linear Regression",
        p(strong("")),
        p(strong("Summary of model: ")),
        plotOutput("scatterPlot_model_1"),
        plotOutput("adstockPlot_model_1"),
        p(strong("Campaign efficiencies (standardised beta coefficients): ")),
        verbatimTextOutput("table_model_1"),
        p(strong("Summary of model: ")),
        verbatimTextOutput("model_1")
      ),
      tabPanel(
        "Model 2 -  Bayesian Linear Regression",
        p(strong("")),
        p(strong("Summary of model: ")),
        plotOutput("scatterPlot_model_2"),
        plotOutput("adstockPlot_model_2"),
        p(strong("Campaign efficiencies (standardised beta coefficients): ")),
        verbatimTextOutput("table_model_2"),
        p(strong("Summary of model: ")),
        verbatimTextOutput("model_2")
      )
    ))
  )
)

# Server section ----------------------------------------------------------
server <- function(input, output) {
  # Reading in the datafile for server use --------------------------------
  df_advertisement <- readr::read_csv("data.csv") %>%
    mutate(`Date (Week)` = `Date (Week)` %>% dmy()) %>% # create date variable
    arrange(`Date (Week)`) %>% # guarantee data is sorted
    mutate(`Media Campaign` = `Media Campaign` %>% as.factor()) # changing def

  # Creating the dataframe with adstocked variable ------------------------
  df_with_adstock <- reactive({

    # creating required adstock function
    adstock_effect <-
      adstock(input$retention_factor)

    if (input$dataset == 0) {
      df <- df_advertisement %>%
        mutate(adstocked = adstock_effect(`Media Spend (USD)`))
    } else {
      df <- df_advertisement %>%
        filter(`Media Campaign` == input$dataset) %>%
        mutate(adstocked = adstock_effect(`Media Spend (USD)`))
    }
  })

  # LM model ( interaction adstock and media campaigns) (Model 1) -----------

  linear_model <- reactive({
    req(df_with_adstock())
    if (input$dataset == 0) {
      lm(
        `Search Volume` ~ adstocked:`Media Campaign`,
        df_with_adstock()
      )
    } else {
      lm(
        `Search Volume` ~ adstocked,
        df_with_adstock()
      )
    }
  })

  # Model summary output (Model 1) ------------------------------------------

  output$model_1 <- renderPrint({
    summary(linear_model())
  })


  # Efficiencies of the campaigns (Model 1) ---------------------------------

  output$table_model_1 <- renderPrint({
    if (input$dataset == 0) {
      output_beta <- lm.beta(linear_model())
      beta_table <-
        output_beta$standardized.coefficients %>% as.data.frame()
      names(beta_table) <- c("efficiencies")
      beta_table <- beta_table %>% filter(efficiencies > 0)
      beta_table
    } else {
      print("Campaign efficiencies can only be shown when Total (2014-2016) is selected")
    }
  })


  # Bayesian glm model (Model 2) ------------------------------------------

  bayes_model <- reactive({
    req(df_with_adstock())
    if (input$dataset == 0) {
      bayesglm(
        `Search Volume` ~ adstocked:`Media Campaign`,
        df_with_adstock(),
        family = gaussian,
        prior.mean = 0.,
        prior.scale = Inf,
        prior.df = Inf
      )
    } else {
      bayesglm(
        `Search Volume` ~ adstocked,
        df_with_adstock(),
        family = gaussian,
        prior.mean = 0.,
        prior.scale = Inf,
        prior.df = Inf
      )
    }
  })

  # Model summary output (Model 2) ------------------------------------------

  output$model_2 <- renderPrint({
    summary(bayes_model())
  })


  # Efficiencies of the campaigns (Model 2) ---------------------------------

  output$table_model_2 <- renderPrint({
    if (input$dataset == 0) {
      output_beta <- lm.beta(bayes_model())
      beta_table <-
        output_beta$standardized.coefficients %>% as.data.frame()
      names(beta_table) <- c("efficiencies")
      beta_table <- beta_table %>% filter(efficiencies > 0)
      beta_table
    } else {
      print("Campaign efficiencies can only be shown when Total (2014-2016) is selected")
    }
  })

  # Scatterplot - adstock against search volume (Model 1) -------------------

  output$scatterPlot_model_1 <- renderPlot({
    df_with_adstock() %>%
      ggplot(aes(x = adstocked, y = `Search Volume`, color = `Media Campaign`)) +
      geom_point() +
      labs(
        x = "Media Spend (with Adstock)",
        y = "Search Volume",
        title = "Media Spend (with Adstock) against Search Volume by Media campaign"
      )
  })

  # Scatterplot - adstock against search volume (Model 2) -------------------

  output$scatterPlot_model_2 <- renderPlot({
    df_with_adstock() %>%
      ggplot(aes(x = adstocked, y = `Search Volume`, color = `Media Campaign`)) +
      geom_point() +
      labs(
        x = "Media Spend (with Adstock)",
        y = "Search Volume ",
        title = "Media Spend (with Adstock) against Search Volume by Media campaign"
      )
  })

  # Line plot - predicted search volume against true volume (Model 1) -------

  output$adstockPlot_model_1 <- renderPlot({
    # Create dataset for plot from df and lm
    df_temp <-
      cbind(df_with_adstock(), fitted = linear_model()$fitted.values)

    # Line graph based on model result and measured search volume
    df_temp %>%
      ggplot(aes(x = `Date (Week)`)) +
      geom_line(aes(y = `Search Volume`, color = "actual")) +
      geom_line(aes(y = fitted, color = "predicted")) +
      scale_color_manual("Search Volume",
        breaks = c("actual", "predicted"),
        values = c("black", "green")
        )+
      labs(
        title = "Search Volume (actual) against Search Volume (predicted) across weeks"
      )
  })

  # Line plot - predicted search volume against true volume (Model 2) -------

  output$adstockPlot_model_2 <- renderPlot({
    # Create dataset for plot from df and bayes model
    df_temp <-
      cbind(df_with_adstock(), fitted = bayes_model()$fitted.values)

    # Line graph based on model result and measured search volume
    df_temp %>%
      ggplot(aes(x = `Date (Week)`)) +
      geom_line(aes(y = `Search Volume`, color = "actual")) +
      geom_line(aes(y = fitted, color = "predicted")) +
      scale_color_manual("Search Volume",
        breaks = c("actual", "predicted"),
        values = c("black", "blue")
      ) +
      labs(
        title = "Search Volume (actual) against Search Volume (predicted) across weeks"
      )
  })
}

shinyApp(ui, server)
