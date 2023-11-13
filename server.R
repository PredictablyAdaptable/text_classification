function(input, output) {
  
  values <- reactiveValues(in_raw = NULL,
                           search_df = NULL
  )
  
  ### Observing the uploading of the survey input
  
  observeEvent(input$in_df, {
    
    inFile <- input$in_df
    if (is.null(inFile))
      return(NULL)
    
    values$in_raw <- read.csv(inFile$datapath,header = FALSE)
  
    
    # Creating Output Tables
    output$in_df_out <- renderDT({

      return(datatable(values$in_raw, options = list(pageLength = 5,
                                             lengthMenu = c(5, 10, 15, 20))
      )
      )
    })

    
    
    }
  )
  
  
  ### Observing the uploading of the search input
  
  observeEvent(input$search_df, {
    
    inFile2 <- input$search_df
    if (is.null(inFile2))
      return(NULL)
    
    values$search_df <- read.csv(inFile2$datapath,header = FALSE)
    
    
    # Creating Output Tables
    output$search_df_out <- renderDT({
      
      return(datatable(values$search_df, options = list(pageLength = 5,
                                                     lengthMenu = c(5, 10, 15, 20))
      )
      )
    })

  }
  )
  
  
  ## The Function
  observeEvent(input$process_data, {
    tryCatch({    
    
      showModal(modalDialog("Computing Results", footer=NULL))

    

    
      exact_match <- ifelse(input$exact_match == "Yes", 1,0)
      string_dist <- input$string_distance
      algo <- input$algo
      
      
      ##extract uuid column, save in_df without uuid
      uuid <- values$in_raw[,1]
      in_df <- values$in_raw[,2:ncol(values$in_raw)]
      
      ##initiate list for the outer most for loop
      long_out_ls <- list()
      short_out_ls <- list()
      
      for(search_loop in 1:ncol(values$search_df)){
        
        search_vec <- values$search_df[,search_loop] 
        search_title <- search_vec[1] #save first element of vector as for the values of the columns
        
        
        ## Clean input dataframe
        new_df <- in_df %>% mutate(across(everything(), as.character)) # convert to character vector
        new_df[is.na(new_df)] <- ' ' # replace na values with ' '
        new_df <- as.data.frame(apply(new_df, 2, str_remove_all, " ")) # remove spaces in values
        new_df <- as.data.frame(apply(new_df, 2, str_remove_all, "[^[:alnum:]]")) #remove special characters 
        new_df <- as.data.frame(apply(new_df, 2, tolower))
        
        
        ## Clean search vector
        search_vec <- str_remove_all(search_vec, "[^[:alnum:]]")
        search_vec <- str_remove_all(search_vec, " ")
        search_vec <- search_vec[!search_vec %in% ""]
        search_vec <- search_vec[!is.na(search_vec)]
        search_vec <- tolower(search_vec)
        search_vec <- unique(search_vec)
        
        
        ## Extract The first Brand name to become the prefix of the column names for the new dataframe  
        col_names <- search_vec[1]
        
        
        ## Create a dataframe containing distance values
        dist_ls <- list()
        
        if (exact_match == TRUE) {
          
          for(words in search_vec){
            
            
            dist_df <- data.frame(matrix(nrow = nrow(new_df), ncol = ncol(new_df)))
            
            for(cols in 1:ncol(new_df)){
              for(rows in 1:nrow(new_df))
                dist_df[rows,cols] <- str_detect(new_df[rows,cols], words)
            }
            
            dist_ls[[words]] <- dist_df
            
          }
          
          bool_raw <- as.data.frame(dist_ls)  
          
        } else {
          
          for(words in search_vec){
            
  
            
            dist_df <- data.frame(matrix(nrow = nrow(new_df), ncol = ncol(new_df)))
            
            for(cols in 1:ncol(new_df)){
              for(rows in 1:nrow(new_df))
                dist_df[rows,cols] <- stringdist(new_df[rows,cols], words, method = algo)
            }
            
            dist_ls[[words]] <- dist_df
            
          }
          
          dist_raw <- as.data.frame(dist_ls)  
          
          ## Turn distance dataframe in to a boolean dataframe
          
          bool_raw <- data.frame(ncol = ncol(dist_raw), nrow = nrow(dist_raw))
          
          for (i in 1:nrow(dist_raw)) {
            for (j in 1:ncol(dist_raw)) {
              bool_raw[i, j] <- ifelse(dist_raw[i, j] <= string_dist, 1, 0)
            }
          }
        }
        
        ## rowSums the the different search word variations for each column variation in new_df
        search_length <- length(search_vec) 
        bool_tidy <- data.frame(matrix(0, nrow = nrow(bool_raw), ncol = ncol(bool_raw)/search_length)) #initiate empty dataframe
        
        
        if(search_length > 1) {
          
          for (i in seq(1,ncol(bool_raw)/search_length, 1)) {
            col_index <- seq(0, ncol(bool_raw) - ncol(bool_raw)/search_length, ncol(bool_raw)/search_length) + i
            bool_tidy[, i] <- rowSums(bool_raw[,col_index])
            
          }
        } else {
          
          bool_tidy <- bool_raw  
        }  
        
        
        ## convert bool_tidy dataframe to boolean vectors
        final_bool <- data.frame(matrix(ncol = ncol(bool_tidy), nrow = nrow(bool_tidy)))
        # use a for loop to iterate over every row and column in the dataframe
        for (i in 1:nrow(bool_tidy)) {
          for (j in 1:ncol(bool_tidy)) {
            # apply the ifelse function to the current element in the dataframe
            final_bool[i, j] <- ifelse(bool_tidy[i, j] == 0, 0, 1)
          }
        }
        
        
        short <- data.frame(ifelse(rowSums(final_bool) == 0, "", search_title))
        names(short) <- col_names
        
        long <- data.frame(matrix(ncol = ncol(final_bool), nrow = nrow(final_bool)))
        
        # use a for loop to iterate over every row and column in the dataframe
        for (i in 1:nrow(final_bool)) {
          for (j in 1:ncol(final_bool)) {
            # apply the ifelse function to the current element in the dataframe
            long[i, j] <- ifelse(final_bool[i, j] == 0, "", search_title)
          }
        }
        
        
        new_names <- paste0(col_names, 1:ncol(long))
        names(long) <- new_names
        
        
        long_out_ls[[search_loop]] <- long
        short_out_ls[[search_loop]] <- short
        
      }
      
      long_out <- bind_cols(long_out_ls)
      long_out <- bind_cols(uuid, long_out)
      short_out <- bind_cols(short_out_ls)
      short_out <- bind_cols(uuid, short_out)
      
      
      
      output$long_out_out <- renderDT({
        
        tryCatch({
        
        return(datatable(long_out, options = list(pageLength = 5,
                                                  lengthMenu = c(5, 10, 15, 20))
        )
        )
      }, error = function(e){
        "An error occurred, Please upload file with the correct format"
        
      })
      
      })
      
      output$short_out_out <- renderDT({
        
        tryCatch({
        
        return(datatable(short_out, options = list(pageLength = 5,
                                                   lengthMenu = c(5, 10, 15, 20))
        )
        )
        }, error = function(e){
          "An error occurred, Please upload file with the correct format"
          
      })
      
      })
        
      output$downloadData <- 
        downloadHandler(
          filename = "text_classification.xlsx",
          content = function(file){
            write_xlsx(list(short_out, long_out), path = "classified_text.xlsx",
                       col_names = TRUE)
          }
        )
      
      removeModal()
    
    }, error = function(e){
      "An error occurred, Please upload file with the correct format"
    })
    
    
  })



}


## Note to self,,,
# need another page
# Output, Clean
# contains,, row sums the character columns of Output, Total, rowSums by last charactor(number) of column name, and max column number is determined by extracting the last charactor, converting it to numeric, and using max() on it
# Fix download button
# deploy it on to server 











