
gen_max <- max(unlist(sapply(data$individuals, function(x) x$gen_absolute)))
pos_max <- max(unlist(sapply(data$individuals, function(x) x$position)))

.plot_point <- function(crds, plot_col){
  points(crds['position'], crds['gen_absolute'], col = plot_col, pch=20)
}

.get_coords <- function(data, id){
  
  ind <- data$individuals[[id]]
  if(all(c('gen_absolute', 'position') %in% names(ind))){
    return(c(position = ind$position, gen = ind$gen_absolute))
  }else{
    return(NULL)
  }
}

par(mar=c(2,2,0.1,0.1))
plot(
  NA, 
  xlim = c(0, pos_max + 1), 
  ylim = c(0, gen_max + 1),
  xlab = "", ylab = ""
)

for(fam_id in names(data$families)){
  
  fam <- data$families[[fam_id]]

  chil_coords <- lapply(fam$CHIL, function(child_id) .get_coords(data, child_id))
  husb_coords <- .get_coords(data, fam$HUSB)
  wife_coords <- .get_coords(data, fam$WIFE)

  # Check if any coordinates are missing for this familly
  all_coords <- c(list(husb_coords), list(wife_coords), chil_coords)
  missing <-  any(sapply(all_coords, is.null))  
  
  plot_col <- 'black'
  if(missing){
    plot_col <- 'red'
    #cat('  Members missing in family: ', fam_id, '\n')
  }
  
  for(crds in all_coords){
    points(crds['position'], crds['gen'], col = plot_col)
  }

  if(!is.null(husb_coords) & !is.null(wife_coords)){
    join_position <- mean(c(husb_coords['position'], wife_coords['position']))
    join_coords <- c(position = join_position, gen = husb_coords['gen'])
    
    lines(rbind(husb_coords, wife_coords))
    
    for(crds in chil_coords){
      lines(rbind(join_coords, crds))
    }
  }
    
}


# Wladyslav Bystram
.plot_point(.get_coords(data, 'I109'), 'blue')
# Eugeniusz
.plot_point(.get_coords(data, 'I285'), 'blue')

.plot_point(.get_coords(data, 'I137'), 'blue')

