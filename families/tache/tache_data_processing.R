
setwd("families/tache")

in_data <- xlsx::read.xlsx2("xlsx/Pierre's family data sent to Andrew August 12th.xlsx", 1, check.names=F)

out_data <- list(
  individuals = list(),
  families = list()
)

# Data checks (all FAMC exist in FAMS)
all(in_data$FAMC %in% in_data$FAMS)

for(i in 1:nrow(in_data)){
  
}