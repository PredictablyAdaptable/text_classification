dashboardPage(
  dashboardHeader(title = "Text Classification",
                  dropdownMenu(type = "notifications",
                               notificationItem(text = "App is case insensitive"),
                               notificationItem(text = "uploaded data - uuid in first column"),
                               notificationItem(text = "searched words - cols are diff words"), 
                               notificationItem(text = "rows are variations of same word"),
                               notificationItem(text = "only upload standard csv, not UTF-8")
                               )

                  ),
  
  dashboardSidebar(
    sidebarMenu(
      
      # Uploads
      fileInput("in_df", "upload the data you want to process as a csv", multiple = FALSE,
                accept = c(".csv")),
      fileInput("search_df", "upload the words you want to search as a csv", multiple = FALSE,
                accept = c(".csv")),
      
      #Sidebar Menu Items for Data Uploads
      menuItem(text = "Uploaded Data", tabName = "in_df_tab", icon = icon("table")),
      menuItem(text = "Words to Search", tabName = "search_df_tab", icon = icon("table")),


      # Togles
      selectInput(inputId = "exact_match", label = "exact match", 
                  choices = c("Yes", "No"), 
                  multiple = F),
      sliderInput(inputId = "string_distance", label = "letter distance", min = 0, 
                  max = 5, value = 2, step = 1),
      selectInput(inputId = "algo", label = "algorithm", 
                  choices = c("osa", "lv", "dl","hamming","lcs", "qgram", 
                              "cosine", "jaccard", "jw", "soundex"), 
                  multiple = F),
      
      #Run Button
      actionButton("process_data", "Run"),
      
      #Sidebar Menu Items for Data Outputs
      menuItem(text = "Output, Summary", tabName = "short_out_tab", icon = icon("table")),
      menuItem(text = "Output, Total", tabName = "long_out_tab", icon = icon("table")),
      
      #Download Data Button
      downloadButton("downloadData", "Download Data")
    )
  ),
  dashboardBody(
    tabItems(
      #upload tabs
      tabItem(tabName = "in_df_tab", DTOutput(outputId = "in_df_out")),
      tabItem(tabName = "search_df_tab", DTOutput(outputId = "search_df_out")),
      
      #output tabs
      tabItem(tabName = "short_out_tab", DTOutput(outputId = "short_out_out")),
      tabItem(tabName = "long_out_tab", DTOutput(outputId = "long_out_out"))
    )
  )
)






































