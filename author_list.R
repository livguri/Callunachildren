library(tidyverse)
library(plume)

authors <- "authors.csv"
if (!file.exists(authors)) {
  plm <- plume_template(FALSE)
  write.csv(plm, file = authors, row.names = FALSE)
}


aut <- PlumeQuarto$new(read_csv(authors))
aut$set_corresponding_authors(1)
aut$to_yaml("calluna6000.qmd")


aut$get_contributions(role_first = TRUE, name_list = TRUE) |> cat()
