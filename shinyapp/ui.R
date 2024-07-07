fluidPage(
  tags$head(
    tags$title("KinderSeg"),
    tags$style(HTML("
      .plotly {
        height: 100vh !important;
      }
      .main-title {
        font-size: 2em;
        font-weight: bold;
        text-align: left;
        margin-bottom: 5px;
        margin-top: 5px;
        font-family: 'Brush Script MT', cursive;
        color: #2c3e50;
        margin-left: 20px;
      }
      .sidebar {
        height: 90vh;
        margin-top: 10px;
      }
    "))
  ),
  div(class = "main-title", "KinderSeg"),
  
  # Main tabset panel
  tabsetPanel(
    
    tabPanel("Percentile Curves",
             fluidRow(
               column(width = 12,
                      fluidRow(style = "display: flex; align-items: center;",
                               column(width = 2,
                                      br(),
                                      
                                      radioButtons("colorBy", "Color By:", 
                                                   choices = c("sex", "hemisphere"), 
                                                   selected = "sex")
                               ),
                               column(width = 8),
                               column(width = 2,
                                      checkboxInput("displayAbsoluteVolumes", "Display Absolute Volumes", 
                                                    value = FALSE)
                               )
                      )
               )
             ),
             withSpinner(
               plotlyOutput("volumePlot"), 
               type = 1, 
               color.background = "white"
             )
    ),
    
    
    

    
    tabPanel("Upload Subject",
             sidebarLayout(
               sidebarPanel(width = 3, class = "sidebar",
                            fileInput("upload_eTIV", "Upload eTIV.stats", accept = c(".csv")),
                            fileInput("upload_vols", "Upload volume.stats", accept = c(".csv")),
                            selectInput("sex", "Sex?", c("male", "female")),
                            numericInput("age", "Age?", min = 4, max = 18, value = 4),
                            actionButton("processData", "Process Data"),
                            br()
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "output.showMainPanel",
                   withSpinner(
                     plotlyOutput("newPlot"), 
                     type = 1, 
                     color.background = "white"
                   )
                 )
               )
             )
    ),
    
    
    tabPanel("How to use",
             fluidRow(
               column(width = 10, offset = 1,
                      
                      br(),
                      h3("Percentile Curves"),
                      
                      
                      p('The "Percentile Curves" tab lets you color plots by sex or hemisphere and switch between absolute volumes and relative volumes -highlighting the effects of normalization-. The interactive plot includes the ROIs: ', 
                        span(style = "background-color: white;", 'Frontal lobe, Parietal lobe, Paracentral lobe, Temporal lobe, Occipital lobe, Hippocampus, Insula, Cingulate gyrus, Corpus callosum, Basal ganglia, Thalamus, Cerebellum, Ventricles, Ventral diencephalon, White matter, and Brainstem.'), 
                        'The plot is created using ggplot2 and Plotly.'),
                      hr(),
                      
                      h3("How to Upload Your Own Subject Data"),
                      tags$ol(
                        tags$li("Run the Bash Script shown in the directory where the FastSurfer output is saved. (make sure the FastSurferOutput directory start with 'sub')"),
                        
                        
                        tags$pre('
#!/bin/bash

# Set the SUBJECTS_DIR to the current working directory
export SUBJECTS_DIR="$PWD"

# Get the first subject directory
first_sub=$(ls -1d sub* | head -n 1)

# Generate volume stats table for the first subject only
asegstats2table --subjects "$first_sub" \
                --skip --all-segs \
                --tablefile "$SUBJECTS_DIR/volume.stats.${first_sub}.csv" \
                --statsfile="aparc.DKTatlas+aseg.deep.volume.stats" \
                --common-segs --meas volume

# Initialize eTIV stats file with header
echo "IDs,eTIV" > "$SUBJECTS_DIR/eTIV.stats.${first_sub}.csv"

# Extract eTIV for the first subject
etiv=$(mri_segstats --etiv-only --subject "$first_sub" | grep eTIV | awk "{print $4}")
echo "$first_sub,$etiv" >> "$SUBJECTS_DIR/eTIV.stats.${first_sub}.csv"
echo "eTIV written to $SUBJECTS_DIR/eTIV.stats.${first_sub}.csv for subject $first_sub"
'),
tags$pre('
.
├── bash_script.sh
├── eTIV.stats.sub-k(FastSurferOutput).csv
├── volume.stats.sub-k(FastSurferOutput).csv
└── sub-k(FastSurferOutput)
    '),
                        
                        tags$li("Navigate to the 'Upload Subject' tab. and upload the eTIV.stats and volume.stats generated by the script above"),

                        tags$li("Select the sex and the age of the subject."),
                        tags$li("Click the 'Process Data' button to analyze the uploaded data."),
                        tags$li("After processing, the plot will be displayed in the main panel. You can save a screenshot by clicking on the camera icon on the right upper corner.")
                      ),
                      #https://github.com/ibrazug/kinderseg/blob/main/mri_processing_Python/run_fastsurfer
                      h4("Important Notes:"),
                      p("The Script to run FastSurfer is on our ",
                          a("GitHub Repo", href="https://github.com/ibrazug/kinderseg/blob/main/mri_processing_Python/run_fastsurfer", target="_blank")), 
                      p("To execute the script mentioned above, you need both FreeSurfer tools installed on your machine: ",
                        a("asegstats2table", href="https://surfer.nmr.mgh.harvard.edu/fswiki/asegstats2table", target="_blank"),
                        " and ",
                        a("mri_segstats", href="https://surfer.nmr.mgh.harvard.edu/fswiki/mri_segstats", target="_blank")),
br(),
br(),
br(),

                      
               )
             )
    ),
    
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  )
)
