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
source_python("data_preparation_function.py")
source_python("predict_function.py")
source_python("Recherche_V_function.py")
source_python("classifier_function.py")
source_python("new_claim_function.py")
source_python("final_classification_function.py")
ui <- dashboardPage(skin='green',
  dashboardHeader(
    title = "Identification des sinistres grêles",
    titleWidth = 400, tags$li(a(href = 'http://www.groupama.fr',
                                img(src = 'groupama.jpg',
                                    title = "Groupama", height = "30px"),
                                style = "padding-top:10px; padding-bottom:10px;"),
                              class = "dropdown")
  ),
  dashboardSidebar(sidebarMenu(
    menuItem("Identification générale", tabName = "generale", icon = icon("home")),
    menuItem("Identification périodique", tabName = "periode", icon = icon("dashboard"))
  )),
  dashboardBody(
    tags$head(tags$style(HTML('
      .main-header .logo {
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 20px;
      }
    '))),
    tags$head(
      tags$style(HTML(".main-sidebar {background-color:  #1E8449 !important;}"))
    ),
    tabItems(
      tabItem(tabName = 'generale',
              br(),
              
              tags$head(
                tags$style(HTML("
                    .shiny-output-error-validation {
                    color: red;
                      }
                  "))
              ),
              
              
              tags$style(".shiny-file-input-progress {display: none}"),
              tags$style(HTML("
    .tabbable > .nav > li > a {background-color: #7DCEA0;  color:black; width: 400PX;}
  ")),
              
              
              column(fileInput("general_file","Sélectionner le fichier Excel des données"),br(),
                              
                              actionButton("classifier_general", strong("Classifier les sinistres"), style="color: #fff; background-color: green; border-color: black"),
                              br(),
                              br(),
                              actionButton("classifier_grele_general",strong("Classifier grêle"), style="color: #fff; background-color: green; border-color: black"),
                              br(),
                              br(),
                              downloadButton("Telecharger_general", strong("Télécharger les résultats"), style="color: #fff; background-color: green; border-color: black"),width = 4),
                       
                       column(dataTableOutput("Table_sinistres_a_verifier_general"), width=8)),
              
      tabItem(tabName = 'periode',
              
              br(),
                 
                 tags$head(
                   tags$style(HTML("
                    .shiny-output-error-validation {
                    color: red;
                      }
                  "))
                 ),
                 
          
                 tags$style(".shiny-file-input-progress {display: none}"),
                 tags$style(HTML("
    .tabbable > .nav > li > a {background-color: #7DCEA0;  color:black; width: 400PX;}
  ")),
                 
                 
                          column(fileInput("file_n","Sélectionner le fichier Excel des données de l'année n"),br(),
                                 fileInput("file_n_1","Sélectionner le fichier Excel des données de l'année n-1"),br(),
                              actionButton("classifier_period", strong("Classifier les sinistres"), style="color: #fff; background-color: green; border-color: black"),
                              br(),
                              br(),
                 actionButton("classifier_grele_period",strong("Classifier grêle"), style="color: #fff; background-color: green; border-color: black"),
                 br(),
                 br(),
                downloadButton("Telecharger_period", strong("Télécharger les résultats"), style="color: #fff; background-color: green; border-color: black"),width = 4),
                 
                 column(dataTableOutput("Table_sinistres_a_verifier_period"), width=8)))))
                
                   
                 
                 
server <- function(input, output, session) {
  
    general_file<-reactive(input$general_file)
    file_n<-reactive(input$file_n)
    file_n_1<-reactive(input$file_n_1)
    
    general_data<- reactive({
      req(general_file())
      ext <- tools::file_ext(general_file())
      validate(need(ext == "xlsx", "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
      file.rename(general_file()$datapath,paste(general_file()$datapath, ".xlsx", sep=""))
      general_dataset<-read.xlsx(paste(general_file()$datapath, ".xlsx", sep=""), 1)
      return(general_dataset)
    })
    
    classes_sinistres_general <- eventReactive(input$classifier_general,{
      data_class_general<-classifier(general_data())
      return(data_class_general)
    })
    sinistres_a_verifier_general<-reactive(classes_sinistres_general()[classes_sinistres_general()[,'Class']=='sinistre à vérifier',])
    
    output$Table_sinistres_a_verifier_general<-renderDataTable({
      if(is.null(sinistres_a_verifier_general())){
        return(NULL)
      }else{
        sinistres_a_verifier_general()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')]
      }
    }, options = list(scrollX = TRUE, reactable(
      data = sinistres_a_verifier_general()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')],
      selection = "multiple",
      selectionId = "tableid1",
      onClick = "select",
      defaultSelected = NULL,
      fullWidth = FALSE
    )))
    
    sinistres_a_verifier_grele_general <- eventReactive(input$classifier_grele_general,{
      selected_rows=input$Table_sinistres_a_verifier_general_rows_selected
      
      sinistres_greles<-sinistres_a_verifier_general()[selected_rows,]
      sinistres_greles[,'Class']<-'grele'
      return(sinistres_greles)
    })
    
    
    
    output$Telecharger_general<-downloadHandler(filename=function(){'classes_sinistres.xlsx'},
                                               content=function(file){
                                                 table_classes_sinistres<-table_finale(classes_sinistres_general(),sinistres_a_verifier_general(),sinistres_a_verifier_grele_general())
                                                 write.xlsx(table_classes_sinistres, file, sheetName = "Sinistres classifiés")
                                               })
    
    data_n <- reactive({
    req(file_n())
    ext <- tools::file_ext(file_n())
    validate(need(ext == "xlsx", "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
    file.rename(file_n()$datapath,paste(file_n()$datapath, ".xlsx", sep=""))
    dataset_n<-read.xlsx(paste(file_n()$datapath, ".xlsx", sep=""), 1)
    return(dataset_n)
    })
    
    data_n_1 <- reactive({
      req(file_n_1())
      ext <- tools::file_ext(file_n_1())
      validate(need(ext == "xlsx", "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
      file.rename(file_n_1()$datapath,paste(file_n_1()$datapath, ".xlsx", sep=""))
      dataset_n_1<-read.xlsx(paste(file_n_1()$datapath, ".xlsx", sep=""), 1)
      return(dataset_n_1)
    })
    
    
    classes_nouveaux_sinistres_period <- eventReactive(input$classifier_period,{
    nouveaux_sinistres<-nv_sinistres(data_n(), data_n_1())
    data_class_period<-classifier(nouveaux_sinistres)
    return(data_class_period)
    })
    
    sinistres_a_verifier_period<-reactive(classes_nouveaux_sinistres_period()[classes_nouveaux_sinistres_period()[,'Class']=='sinistre à vérifier',])
    
    
    output$Table_sinistres_a_verifier_period<-renderDataTable({
      if(is.null(sinistres_a_verifier_period())){
        return(NULL)
      }else{
        sinistres_a_verifier_period()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')]
    }
    }, options = list(scrollX = TRUE, reactable(
      data = sinistres_a_verifier_period()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')],
      selection = "multiple",
      selectionId = "tableid1",
      onClick = "select",
      defaultSelected = NULL,
      fullWidth = FALSE
    )))
    
    sinistres_a_verifier_grele_period <- eventReactive(input$classifier_grele_period,{
      selected_rows=input$Table_sinistres_a_verifier_period_rows_selected
      
      sinistres_greles<-sinistres_a_verifier_period()[selected_rows,]
      sinistres_greles[,'Class']<-'grele'
      return(sinistres_greles)
    })
    
    output$Telecharger_period<-downloadHandler(filename=function(){'classes_nouveaux_sinistres.xlsx'},
                                                content=function(file){
                                                  table_classes_sinistres<-table_finale(classes_nouveaux_sinistres_period(),sinistres_a_verifier_period(),sinistres_a_verifier_grele_period())
                                                  write.xlsx(table_classes_sinistres, file, sheetName = "Nouveaux sinistres classifiés")
                                                })
    
  
  }

shinyApp(ui, server)