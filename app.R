library(shiny)
library(fresh)
library(tensorflow)
library(keras)
library(reticulate)
source_python("data_preparation_function.py")

ui <- navbarPage("Identification des sinistres causés par la grêle",
                 header=use_theme(create_theme(
                   theme = "default",
                   bs_vars_navbar(
                     default_bg = "green",
                     default_link_color = "#FFFFFF",
                     default_link_active_bg = "green"
                   ),
                   output_file = NULL
                 )),
                 column(6, fileInput("file","Sélectionner le fichier des données"),
                        actionButton("classifier", "Classifier les sinistres", style="color: #fff; background-color: green; border-color: black"),
                        actionButton("Telecharger", "Télécharger les résultats", style="color: #fff; background-color: green; border-color: black")))

server <- function(input, output, session) {
  
  dataset<-reactive({ 
    inFile <- input$file
    dat<-read_xlsx(inFile$datapath, sheet =  1)
    return(dat)
  })
  observeEvent({input$classifier, })
  
}

shinyApp(ui, server)