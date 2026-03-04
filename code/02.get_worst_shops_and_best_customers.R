# get the smaller shops: as tasks, we want to work on low performer shops, and remove
# the low performance products, but that are not affecting the revenues.
# first we get the low performer shops.
# We are assuming that none of the shops are closed.

# classify customers
data_vn <- sum(data$net_revenue)
data_rec <- length(unique(data$net_revenue))

# best customers
bc <-
    data[,
        "."(vn = sum(net_revenue), nrec = length(unique(receipt_id))),
        by = c("customer_id")
    ]

bc[, ":="(percentage_vn = vn / data_vn, percentage_nrec = nrec / data_rec)]

# Add quantile-based categorical columns
bc[, ":="(
    vn_category = cut(
        percentage_vn,
        breaks = quantile(percentage_vn, probs = c(0, 1 / 3, 2 / 3, 1)),
        labels = c("L", "M", "H"),
        include.lowest = TRUE
    ),
    nrec_category = cut(
        percentage_nrec,
        breaks = quantile(percentage_nrec, probs = c(0, 1 / 3, 2 / 3, 1)),
        labels = c("L", "M", "H"),
        include.lowest = TRUE
    )
)]

bc$FM <- paste0(bc$nrec_category, bc$vn_category)
bc <- bc[, c("FM", "customer_id")]

# let's get the worst shops
shops <-
    data[,
        "."(
            vn = sum(net_revenue),
            n_receipt = length(unique(receipt_id)),
            n_articles = length(unique(product_key))
        ),
        by = c("store_key")
    ]

setorder(shops, -vn)
shops[, ":="(cumulative = cumsum(vn) / sum(vn))]
low_shops <- shops[, ":="(
    marker = fifelse(cumulative > .8, "low_performer", "high_performer")
)][marker == "low_performer"]

# here them
data_lower <- data[store_key %in% low_shops$store_key]

# add customers label
data_lower <- bc[data_lower, on = "customer_id"]

length(unique(data_lower$store_key))


write_parquet(data_lower, "lower_data.parquet")

# we need to find 250 that:
# - low sell out
# - low margin
# - replaceable
# - not bought by our favourite customers
# - if possible, not associated
