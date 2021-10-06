# Author: Joey Chen 
# Date: 10/5/2021
# Description: This program renders Crypto_Vignette and outputs the README.md file

rmarkdown::render("Crypto-Vignette.Rmd", 
                  output_format = "github_document", 
                  output_file = "README.md",
                  output_options = list(
                    html_preview = FALSE,
                    toc = TRUE,
                    toc_depth = 2
                  )
)


