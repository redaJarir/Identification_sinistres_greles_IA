library(shiny)
library(reticulate)
library(fresh)
library(openxlsx)
#library(tensorflow)
#library(keras)
library(vroom)
source_python("clean_function.py")
source_python("stem_function.py")
source_python("data_preparation_function.py")
source_python("predict_function.py")
source_python("Recherche_V_function.py")
source_python("classifier_function.py")
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
                 img(src='groupama.jpg', height="10%", width="10%"),
                 br(),
                 br(),
                 tags$style(".shiny-file-input-progress {display: none}"),
                 sidebarLayout(
                   sidebarPanel(fileInput("myfile","Sélectionner le fichier des données", accept = ".csv"),
                  actionButton("classifier", "Classifier les sinistres", style="color: #fff; background-color: green; border-color: black"),
                                br(),
                                br(),
                                downloadButton("Telecharger", "Télécharger les résultats", style="color: #fff; background-color: green; border-color: black")
                     ),
                   mainPanel(tableOutput("mytable"))
                 )
                )
                 
server <- function(input, output, session) {
  

    myfile<-reactive(input$myfile)
    data <- reactive({
    req(myfile())
    
    # as shown in the book, lets make sure the uploaded file is a csv
    ext <- tools::file_ext(myfile())
    
    validate(need(ext == "csv", "Erreur : Télécharger un fichier .csv s'il vous plaît"))
    dataset <- vroom::vroom(myfile()$datapath, col_names=TRUE, show_col_types = FALSE, locale = vroom::locale(encoding = "ISO-8859-1"))
    return(dataset)
    })
  
    pred_verif <- eventReactive(input$classifier,{
    data_class<-classifier(data())
    return(data_class)
    })
  
    output$mytable <- renderTable({
      my_table <- pred_verif()
      sinistres_verif<-my_table[my_table[,'Class']=='sinistre à vérifier',]
      if(is.null(sinistres_verif)){
        return(NULL)
      }else{
        sinistres_verif
    }})
    output$Telecharger<-downloadHandler(filename='sinistres classifiés.csv',
    content=function(file){read.csv(pred_verif(), file, col.names=TRUE, append=FALSE)})
  
  }

shinyApp(ui, server)