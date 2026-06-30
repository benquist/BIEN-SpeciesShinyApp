suppressWarnings(library(rsconnect))

# Set account info for deployment
rsconnect::setAccountInfo(name = "benquist",
               token = "A8508E74F04D9F122B1376CCF06F808B",
               secret = "q7GZtMYaVMgnCCnUAhIr13lZS5UIsalkdQ/iP1Kc")

# Deploy app
cat("Deploying fixed app to shinyapps.io...\n")
rsconnect::deployApp(appDir = "/Users/brianjenquist/VSCode/BIEN-SpeciesShinyApp",
          appName = "bien-species-shinyapp",
          account = "benquist",
          launch.browser = FALSE)

cat("Deployment complete!\n")
