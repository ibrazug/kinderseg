
source("global.R")

shinyApp(ui = source("ui.R")$value, server = source("server.R")$value)
