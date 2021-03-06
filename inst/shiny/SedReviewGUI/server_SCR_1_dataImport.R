#### Science-Center Review: Data import and summary ####
# Load DB info from SLA module
observeEvent(input$loadDB_SLA, {
  updateTextInput(session, inputId = "DBName2", value = input$DBName)
  updateTextInput(session, inputId = "env.db2", value = input$env.db)
  updateTextInput(session, inputId = "qa.db2", value = input$qa.db)
})
# Save/load database info
observeEvent(input$loadDBinfo2,{
  appDir <- system.file("shiny", "SedReviewGUI",package = "sedReview")
  DBInfo2 <- readRDS(file = paste0(appDir,"/DBinfo2.RDS"))
  updateTextInput(session, inputId = "DBName2", value = DBInfo2$DSN)
  updateTextInput(session, inputId = "env.db2", value = DBInfo2$env.db)
  updateTextInput(session, inputId = "qa.db2", value = DBInfo2$qa.db)
})
observeEvent(input$saveDBinfo2,{
  DBInfo2 <- list()
  DBInfo2$DSN <- input$DBName2
  DBInfo2$env.db <- input$env.db2          
  DBInfo2$qa.db <- input$qa.db2
  appDir <- system.file("shiny", "SedReviewGUI",package = "sedReview")
  saveRDS(DBInfo2, file = paste0(appDir,"/DBinfo2.RDS"))
})
# Center-level data summary pull routine  
observeEvent(input$reviewPull, {
  SitesCount <<- NULL
  SitesCount <<- count_activeSed(DSN = input$DBName2,            
                                 env.db = input$env.db2,           
                                 begin.date = input$reviewBeginDT, 
                                 end.date = input$reviewEndDT)
  SitesCount$SITE_NO <<- trimws(SitesCount$SITE_NO)
  SitesCount$SITE_NO_STATION_NM <<- paste0(SitesCount$SITE_NO, " - ", SitesCount$STATION_NM)
  
  output$centerSumtable <- DT::renderDataTable(
  datatable({SitesCount[, -c(8)]}, 
            extensions = 'Buttons', 
            rownames = FALSE,
            options = list(dom = 'Bfrtip',
                           buttons = 
                             list('colvis', list(
                               extend = 'collection',
                               buttons = list(list(extend ='csv',
                                                   filename = 'SCLSummaryTable'),
                                              list(extend ='excel',
                                                   filename = 'SCLSummaryTable'),
                                              list(extend ='pdf',
                                                   pageSize = 'A3',
                                                   orientation = 'portrait',
                                                   filename = 'SCLSummaryTable')),
                               text = 'Download'
                             )),
                           scrollX = TRUE,
                           scrollY = "600px",
                           order = list(list(4, 'desc'), list(2, 'asc')),
                           pageLength = nrow({SitesCount}),
                           selection = 'single')
            
  ))
})



observeEvent(input$reviewPull, {
  siteData_SCR <<- NULL
  siteData_SCR <<- get_localNWIS(DSN = input$DBName2,            
                                 env.db = input$env.db2,
                                 qa.db = input$qa.db2,
                                 STAIDS = SitesCount$SITE_NO,             
                                 begin.date = input$reviewBeginDT, 
                                 end.date = input$reviewEndDT,
                                 approval = "All")
})