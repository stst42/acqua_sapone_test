# libraries
library(data.table)
library(yaml)
library(lobstr)
library(janitor)
library(ggplot2)
library(arrow)

# get data
path <- read_yaml(paste0(getwd(), "/settings/settings.yaml"))$where_data
data <- list.files(path, full.names = TRUE, pattern = "*.csv") |> fread()

# let's see the data
tree(data)
colnames(data)
# no blanks, NA, NaN
summary(data)
head(data, 1) |> t()


# cleanup
data <- clean_names(data)
data[, ":="(date = as.Date(date, "%d/%m/%Y"))]

data[, ":="(
      gross_margin_percent = as.numeric(gsub("-|%", "", gross_margin_percent))
)]

length(unique(data$product_key))
length(unique(data$store_key))
length(unique(data$receipt_id))
length(unique(data$customer_id))
length(unique(data$date))

write_parquet(data, "data.parquet")

# let's get the worst shops
