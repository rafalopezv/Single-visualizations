# about: function to convert to tabular to js data
library(jsonlite)
library(stringr)

convert_to_js_objects <- function(data, file_path = NULL) {
  
  json_data <- toJSON(data, pretty = TRUE, auto_unbox = TRUE)
  
  
  js_array_of_objects <- gsub('"(\\w+)":', '\\1:', json_data)
  
  
  if (!is.null(file_path)) {
    writeLines(js_array_of_objects, file_path)
  }
  
  
  return(js_array_of_objects)
}

 