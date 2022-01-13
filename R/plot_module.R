

plot_UI <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(width = 2,
                    pickerInput(ns("sel_year"), label="Year", ch_year),
                    pickerInput(ns("sel_category"), label="Category", choices = ch_cat),
                    pickerInput(ns("sel_value"), label="Select", choices=NULL, multiple=TRUE)
                    ),
             column(width = 10,
                    plotlyOutput(ns("main_plot") )
                    )
    ) 
    )
}

plot_SERVER <- function(id, df) {
  moduleServer(id, function(input, output, session) {
    
    data <- reactive({
      tmp_data <- filter(df, year == input$sel_year) %>% 
        rename(target_var = input$sel_category) %>% 
        separate_rows(target_var , sep = ",") %>% 
        mutate(target_var = str_trim(str_squish(target_var), side = "both"))
      
      if(input$sel_category == "title") {
        tmp_data %<>% 
          mutate(target_var = paste(target_var,"-", artist))
      }
      return(tmp_data)
      
    })
    
    top_year_value <- reactive({  
      data() %>%
        tabulate::tabulate(cols = target_var) %>% 
        arrange(desc(pct)) %>%
        slice(1:50) %>%
        pull(value) 
    })
    
    result_et <- reactive({
      tabulate::tabulate(data(), target_var, groups=year_month)
    })
    
    observeEvent(result_et(),{
      updatePickerInput(session,"sel_value", selected = top_year_value()[1:5], choices = top_year_value(),
                        options = shinyWidgets::pickerOptions(actionsBox = TRUE,liveSearch = TRUE, maxOptions = 20,
                                                              maxOptionsText = "Not more than 5") )  })
    output$main_plot <- renderPlotly({
      req(length(input$sel_value)>0)
      
      p1 <- result_et() %>%  
        filter(value %in% input$sel_value) %>% 
        mutate(group_year_month  = factor(group_year_month,levels = str_sort(unique(group_year_month), numeric = TRUE)) )  %>% 
        ggplot(aes(x = group_year_month, y = pct, group = value, col = value)) +
        geom_line() +
        scale_y_continuous(labels = scales::percent) +
        labs(x = "Year - Month", y = "Percent", col = NULL, title = input$sel_category) +
        theme_bw() 
      
      plotly::ggplotly(p1)
    })
    
} )}