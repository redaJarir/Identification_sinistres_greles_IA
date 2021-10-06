library(shiny)
library(reticulate)
library(fresh)
library(xlsx)
library(tidyverse)
library(DT)
library(vroom)
source_python("clean_function.py")
source_python("stem_function.py")
source_python("data_preparation_function.py")
source_python("predict_function.py")
source_python("Recherche_V_function.py")
source_python("classifier_function.py")
source_python("new_claim_function.py")
ui <- navbarPage(strong("Identification des sinistres causés par la grêle"),
                 header=use_theme(create_theme(
                   theme = "default",
                   bs_vars_navbar(
                     default_bg = "green",
                     default_link_color = "#FFFFFF",
                     default_link_active_bg = "green"
                   ),
                   output_file = NULL
                 )),
                 
                 tags$head(
                   tags$style(HTML("
                    .shiny-output-error-validation {
                    color: red;
                      }
                  "))
                 ),
                 img(src='groupama.jpg', height="10%", width="15%"),
          
                 tags$style(".shiny-file-input-progress {display: none}"),
                 tags$style(HTML("
    .tabbable > .nav > li > a {background-color: #7DCEA0;  color:black; width: 400PX;}
  ")),
                 tabsetPanel(
                 tabPanel(strong("Classification des sinistres entre l'année n-1 et n"),icon=icon('home'), br(), br(),
                          fluidRow(column(fileInput("file_n","Sélectionner le fichier Excel des données de l'année n"),br(),
                                 fileInput("file_n_1","Sélectionner le fichier Excel des données de l'année n-1"),br(),
                              actionButton("classifier", "Classifier les sinistres", style="color: #fff; background-color: green; border-color: white"),
                              br(),
                              br(),
                 actionButton("classifier_grele","Classifier grêle", style="color: #fff; background-color: green; border-color: white"),
                 br(),
                 br(),
                downloadButton("Telecharger", "Télécharger les résultats", style="color: #fff; background-color: green; border-color: white"),width = 4),
                 
                 column(dataTableOutput("Table_sinistres_a_verifier"), width=6))),
                tabPanel(strong('Classification générale')))
                   
                 
                 
                )
                 
server <- function(input, output, session) {
  

    file_n<-reactive(input$file_n)
    file_n_1<-reactive(input$file_n_1)
    data_n <- reactive({
    req(file_n())
    
    # as shown in the book, lets make sure the uploaded file is a csv
    ext <- tools::file_ext(file_n())
    
    validate(need(ext == "xlsx", "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
    file.rename(file_n()$datapath,paste(file_n()$datapath, ".xlsx", sep=""))
    dataset_n<-read.xlsx(paste(file_n()$datapath, ".xlsx", sep=""), 1)
    #dataset <- vroom::vroom(myfile()$datapath, col_names=TRUE, show_col_types = FALSE, locale = vroom::locale(encoding = "ISO-8859-1"))
    return(dataset_n)
    })
    data_n_1 <- reactive({
      req(file_n_1())
      
      # as shown in the book, lets make sure the uploaded file is a csv
      ext <- tools::file_ext(file_n_1())
      
      validate(need(ext == "xlsx", "Erreur : Télécharger un fichier .xlsx s'il vous plaît"))
      file.rename(file_n_1()$datapath,paste(file_n_1()$datapath, ".xlsx", sep=""))
      dataset_n_1<-read.xlsx(paste(file_n_1()$datapath, ".xlsx", sep=""), 1)
      #dataset <- vroom::vroom(myfile()$datapath, col_names=TRUE, show_col_types = FALSE, locale = vroom::locale(encoding = "ISO-8859-1"))
      return(dataset_n_1)
    })
    nouveaux_sinistres<-reactive(nv_sinistres(data_n(), data_n_1()))
    
    classe_nv_sinistre <- eventReactive(input$classifier,{
    data_class<-classifier(nouveaux_sinistres())
    return(data_class)
    })
    
    output$Table_sinistres_a_verifier<-renderDataTable({
      sinistres_a_verifier<-classe_nv_sinistre()[classe_nv_sinistre()[,'Class']=='sinistre à vérifier',]
      if(is.null(sinistres_a_verifier)){
        return(NULL)
      }else{
        sinistres_a_verifier[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')]
    }
    }, options = list(scrollX = TRUE))
    output$Telecharger<-downloadHandler(filename=function(){'classes_sinistres.xlsx'},
    content=function(file){
      write.xlsx(classe_nv_sinistre(), file, sheetName = "classes")
      
    })
  
  }

shinyApp(ui, server)