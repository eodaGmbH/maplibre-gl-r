library(shiny)
library(bslib)

COLORS <- palette.colors(n = 9)

nyc_boroughs <- sf::st_read("data-raw/geo_export_d082ab44-4688-42c8-8fe8-2d5f5abe25d9.shp")


ui <- function(request){
  bslib::page_sidebar(
    sidebar = tagList(
      selectInput("boro", "boro", choices = nyc_boroughs$boro_name),
      selectInput("color", "color", choices = COLORS),
      checkboxInput("visible", "visible", value = TRUE)
    ),
    bslib::card(
      maplibreglOutput("map")
    )

  )
}

server <- function(input,output,session){
  output$map <- renderMaplibregl(
    as_maplibregl(nyc_boroughs)
  )

  observe({

    print(input$color)
    maplibreglProxy("map") %>%
      set_paint_property("fill-layer", "fill-color", input$color) %>%
      set_filter("fill-layer", c("==", "boro_name", input$boro)) %>%
      updateMaplibregl()
  }) %>% bindEvent(input$color, input$boro, input$visible)
}

if (interactive()) shinyApp(ui, server)
