library(shiny)
library(reticulate)
library(reactable)
library(fresh)
library(DT)
library(bslib)
source_python("clean_function.py")
source_python("stem_function.py")
source_python("data_preparation_for_lstm_function.py")
source_python("lstm_predictions_function.py")
source_python("Recherche_V_function.py")
source_python("initial_classification_function.py")
source_python("final_classification_function.py")
source_python("classes_new_claims_function.py")

ui<-tagList(
  tags$head(
    
    #tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css"),
    
    tags$style("
         body, html {
            height: 100%;
            scroll-behavior: smooth;

         }
        
        .jumbotron {
            position: relative;
            top: 50px;
            background-color:transparent; 
            color:#ecf0f1;
            height:100%
        }
        .button_align {
          width: 100%;
          height: 100%;
          padding-left: 0px;
          padding-right: 0px;
          
        
        
        }
        .parallax_1 {
            /* The image used */
            background-image: url('grele.jpg');
            
            /* Set a specific height */
            height: 100%;
            margin-left:-15px;   
            margin-right:-15px;
            /* Create the parallax scrolling effect */
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
        }
        .parallax_2 {
            /* The image used */
            background-image: url('grele.jpg');
            
            /* Set a specific height */
            height: 700px;
            margin-left:-15px;   
            margin-right:-15px;
            /* Create the parallax scrolling effect */
            background-attachment: fixed;
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
        }           

      
        
     ")
    
    
  ),
  
  
  navbarPage(
    theme = bs_theme(
      secondary = "rgb(0, 106, 83)"
    ),
    
    
    id="main_navbar",
    position="fixed-top",
    title = div(
      tags$a( 
        img(
          src='groupama.jpg',
          style="margin-left: -15px;", 
          height = 60
        ), 
        href='http://www.groupama.fr',
        target="_blank"
      )
    ),
    windowTitle="Identification des sinistres grêles",
    collapsible = TRUE,
    tabPanelBody(
      value = "page_1",
      fluidRow(
        column(
          width = 12,
            div(
              class="parallax_1 ",
              div(
                class="jumbotron",
                h1(class = "page-header",
                   style="color: white",
                  "Identification automatique des sinistres du risque grêle") %>% 
                  tags$b(),
                br(),
                column(
                  width = 4,
                  style= "padding-left: 0",
                  fileInput(
                    width = "100%",
                    "my_file", 
                    p("Importer un fichier Excel de données") %>% tags$b()
                  )
                )
              )
            )
          ),
        fluidRow(
      
          style= "height: 100%; padding-right: 30px",
      
          column(
        
            width = 4,
            style = "padding: 20px",
              actionButton(
              "classifier",
              class = "button_align",
              "1 - Classification auto",
              width = "100%"
            )
          ),

          column(
            width = 4,
            style = "padding: 20px",
            actionButton(
              "classifier_grele",
              class = "button_align",
              "2 - Confirmer la vérification"
            )
          ),

          column(
            width = 4,
            style = "padding: 20px",
            actionButton(
              "Telecharger",
              class = "button_align",
              "Télécharger les résultats"
            )
          )
        ) %>% column(width = 12, style= "margin-left:12px"),
        column(
          width=12,
          div(
            class="parallax_2 ",
            dataTableOutput("Table_sinistres_a_verifier")
          )
        )
      )
    )
  )
)



server <- function(input, output, session) {

  
  my_file<-reactive(input$my_file)
  
  classes_claims<- eventReactive(
    input$classifier,
    {
      req(my_file())
      ext <- tools::file_ext(my_file()$datapath)
      validate(
        need(
          ext == "xlsx", 
          "Erreur : Télécharger un fichier .xlsx s'il vous plaît"
        )
      )
      data_class<-new_claims_class(my_file()$datapath)
      return(data_class)
    }
  )
  
  claims_to_check<-reactive(
    {
      classes_claims()[classes_claims()[,'Class']=='sinistre à vérifier',]
    }
  )
  
  output$Table_sinistres_a_verifier<-renderDataTable(
    {
      claims_to_check()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')]
    }, 
    options = list(
      scrollX = TRUE, 
      reactable(
        data = claims_to_check()[,c('ID_ADS', 'LI_DSC_SIGMA', 'LI_DSC_ADS', 'LI_CAUSE', 'Class')],
        selection = "multiple",
        onClick = "select",
        defaultSelected = NULL,
        fullWidth = FALSE
      )
    )
  )
  
  claims_to_check_hail<- eventReactive(
    input$classifier_grele,
    {
      selected_rows=input$Table_sinistres_a_verifier_rows_selected
      sinistres_greles<-claims_to_check()[selected_rows,]
      sinistres_greles[,'Class']<-'grele'
      sinistres_greles
    }
  )
  
  output$Telecharger<-downloadHandler(
    filename=function(){'classes_sinistres.xlsx'},
    content=function(file){
      if(length(input$Table_sinistres_a_verifier_rows_selected) > 0){
        sinistres_greles=claims_to_check_hail()
      }else{
        sinistres_greles<-data.frame()
      }
      table_classes_sinistres<-table_finale(classes_claims(),claims_to_check(),sinistres_greles)
      write.xlsx(table_classes_sinistres, file, sheetName = "Sinistres classifiés")
    }
  )
}

shinyApp(ui, server)