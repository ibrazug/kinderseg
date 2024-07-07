function(input, output, session) {
  
  showModal(modalDialog(
    title = "Disclaimer",
    HTML("
    <p></p>
    <p>KinderSeg is provided for educational purposes only and is not intended for professional or commercial use. This is not a diagnostic tool, and therefore the resultant Percentile Curves should only be used for research purposes. The creators of KinderSeg assume no responsibility for any outcomes resulting from the use of the application. By using this application, you acknowledge that you understand and agree to this disclaimer.</p>
    <p>Ibrahim Zughayyar, & Andrea Dell'Orco. (2024). ibrazug/kinderseg: v0.1 (v0.1). Zenodo. <a href='https://doi.org/10.5281/zenodo.11521842'>https://doi.org/10.5281/zenodo.11521842</a></p>
    <p>For any inquiries, please contact: <a href='mailto:ibrahim.zughayyar@charite.de'>ibrahim.zughayyar@charite.de</a></p>
    <hr />
    <p style='font-size: 0.7em;'>*This site is hosted on the free tier of ShinyApps.io, which may cause occasional downtime or limited availability. We cannot guarantee uninterrupted access. Thank you for your understanding and patience.</p>
    "),
    easyClose = FALSE,
    footer = modalButton("I understand")
  ))
  
  data_processed <- reactiveVal(FALSE)
  
  observeEvent(input$processData, {
    if (is.null(input$upload_eTIV) || is.null(input$upload_vols) || is.null(input$sex) || is.null(input$age)) {
      showNotification("Error: Please upload both files and provide sex and age inputs.", type = "error")
      return(NULL)
    }
    
    req(input$upload_eTIV, input$upload_vols, input$sex, input$age)
    
    #show loading
    data_processed(TRUE)
    
    eTIV_data <- read.csv(input$upload_eTIV$datapath)
    volume_data <- read.csv(input$upload_vols$datapath)

    
    output$newPlot <- renderPlotly({
      p <- my_ggplot(
        eTIV_file = input$upload_eTIV$datapath,
        volume_stat_file = input$upload_vols$datapath,
        sex = input$sex,
        age = input$age
      )
      ggplotly(p)
    })
  })
  
  ##Show Main Percentile Curves 
  
  output$showMainPanel <- reactive({
    data_processed()
  })
  outputOptions(output, "showMainPanel", suspendWhenHidden = FALSE)
  
  output$volumePlot <- renderPlotly({
    plot_data <- data %>%
      gather(key = 'ROI', value = 'Volume', -c(ids, age, sex, hemisphere, eTIV)) %>%
      arrange(ROI, age)
    
    if (input$displayAbsoluteVolumes) {
      plot_data <- plot_data %>%
        mutate(Volume = Volume * eTIV)
    } else {
      plot_data <- plot_data %>%
        mutate(p05 = mov_perc$p05, p50 = mov_perc$p50, p95 = mov_perc$p95)
    }
    
    p <- ggplot(plot_data, aes(x = age, y = Volume, color = !!sym(input$colorBy))) +
      geom_jitter(alpha = 0.4, size = 0.6) +
      { if (!input$displayAbsoluteVolumes) {
        list(
          geom_smooth(aes(x = age, y = p05), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5),
          geom_smooth(aes(x = age, y = p50), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5),
          geom_smooth(aes(x = age, y = p95), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5)
        )
      } } +
      facet_wrap(~ROI, scales = 'free_y', ncol = 4) +
      xlab("Age (year)") +
      ylab("") +
      theme_minimal() +
      theme(
        axis.text.x = element_text(size = 8),
        axis.text.y = element_text(size = 8),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        legend.position = 'none',
        panel.spacing.x = unit(-0.75, "cm"),
        panel.spacing.y = unit(-0.1, "cm"),
        plot.margin = margin(0, 0, 1, 0, "cm"),
        strip.background = element_blank(),
        #strip.text = element_text(size = 12)
        
      ) #+scale_y_continuous(labels = scales::scientific)
    
    ggplotly(p) %>% config(displayModeBar = FALSE, scrollZoom = FALSE)
  })
  
}
