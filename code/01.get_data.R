
# libraries
library(data.table)
library(yaml)
library(lobstr)
library(janitor)

# get data
path <- read_yaml(paste0(getwd(), "/settings/settings.yaml"))$where_data
data <- list.files(path, full.names = TRUE, pattern = "*.csv") |> fread()

# let's see the data
tree(data)
colnames(data)
# no blanks, NA, NaN
summary(data)

# cleanup
data <- clean_names(data)
data[, ":="(date = as.Date(date, "%d/%m/%Y"))]