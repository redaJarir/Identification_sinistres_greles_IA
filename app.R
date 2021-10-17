library(shiny)
library(reactable)
library(reticulate)
library(fresh)
library(xlsx)
library(tidyverse)
library(shinydashboard)
library(DT)
library(dplyr)
source_python("clean_function.py")
source_python("stem_function.py")
source_python("data_preparation_for_lstm_function.py")
source_python("lstm_predictions_function.py")
source_python("Recherche_V_function.py")
source_python("initial_classification_function.py")
source_python("final_classification_function.py")
source_python("classes_new_claims_function.py")
ui <- dashboardPage(skin='green',
  dashboardHeader(
    title = "Identification des sinistres grêles",
    titleWidth = 400, tags$li(a(href = 'http://www.groupama.fr',
                                img(src = 'groupama.jpg',
                                    title = "Groupama", height = "30px"),
                                style = "padding-top:10px; padding-bottom:10px;"),
                              class = "dropdown")),
  dashboardSidebar(),
  dashboardBody(
    tags$head(tags$style(HTML('
      .main-header .logo {
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 20px;}'))),
    tags$head(
      tags$style(HTML("
        .main-sidebar {background-color:  #1E8449 !important;}"))),
    br(),
    tags$head(tags$style(HTML("
        .shiny-output-error-validation {
          color: red;
          }"))),
    tags$style(".shiny-file-input-progress {display: none}"),
    tags$style(HTML("
    .tabbable > .nav > li > a {background-color: #7DCEA0;
    color:black; width: 400PX;}
      ")),
    column(fileInput("my_file",
            "Sélectionner le fichier Excel des données"),
          br(),
          actionButton("classifier",
            strong("Classifier les sinistres"),
            style="color: #fff; background-color: green; 
            border-color: black; width:200px"),
          br(),
          br(),
          actionButton("classifier_grele",
            strong("Classifier grêle"),
            style="color: #fff; background-color: green; 
            border-color: black; width:200px"),
          br(),
          br(),
          downloadButton("Telecharger",
            strong("Télécharger les résultats"),
            style="color: #fff; background-color: green; 
            border-color: black; width:200px"),
                    width = 4),
                       
    column(dataTableOutput("Table_sinistres_a_verifier"), width=8)
              
      
              ))
                
                   
                 
                 
server <- function(input, output, session) {
  
    my_file<-reactive(input$my_file)

    my_data<- reactive({
      req(my_file())
      ext <- tools::file_ext(my_file())
      validate(need(ext == "xlsx", 
        "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
      file.rename(my_file()$datapath,
        paste(my_file()$datapath, ".xlsx", sep=""))
      my_dataset<-read.xlsx(paste(my_file()$datapath, ".xlsx", sep=""), 1)
      return(my_dataset)
    })
    
    classes_claims<- eventReactive(input$classifier,{
      data_class<-new_claims_class(my_data())
      return(data_class)
    })
    claims_to_check<-reactive({
      classes_claims()[classes_claims()[,'Class']=='sinistre à vérifier',]})
    
    output$Table_sinistres_a_verifier<-renderDataTable({
      claims_to_check()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')]
      }, options = list(scrollX = TRUE, reactable(
      data = claims_to_check()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')],
      selection = "multiple",
      onClick = "select",
      defaultSelected = NULL,
      fullWidth = FALSE
    )))
    
    claims_to_check_hail<- eventReactive(input$classifier_grele,{
        selected_rows=input$Table_sinistres_a_verifier_rows_selected
        sinistres_greles<-claims_to_check()[selected_rows,]
        sinistres_greles[,'Class']<-'grele'
        sinistres_greles
    })
    
    
    
    output$Telecharger<-downloadHandler(filename=function(){'classes_sinistres.xlsx'},
                          content=function(file){
                          if(length(input$Table_sinistres_a_verifier_rows_selected) > 0){
                                sinistres_greles=claims_to_check_hail()
                                }
                          else{
                                sinistres_greles<-data.frame()
                              }
                          table_classes_sinistres<-table_finale(classes_claims(),claims_to_check(),sinistres_greles)
                          write.xlsx(table_classes_sinistres, file, sheetName = "Sinistres classifiés")
                          })
    }

shinyApp(ui, server)