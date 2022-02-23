delete_families <- c(
  'F422', # Duplicate family (H: 1656 , W: I361, C: I503 )
  'F215', # Duplicate family from (H: I363)
  'F143', # One of (I179)'s many wives **
  'F453', # One of (I179)'s many wives **
  'F249'  # Twice married to the same person
)


delete_individuals <- c(
  'I363', # duplicate of (I503)
  'I379', # two of (I179)'s many wives **
  'I1081' # two of (I179)'s many wives **
) 
# ** Deleting these here might not be the best way to go. It might be
#    preferable to remove them in the "trimming" process


name_swaps = setNames(as.data.frame(matrix(c(
  
  "Ko\u0142uda Ma\u0142a k.Janikowa \\(Inowroc\u0142aw\\)" , "Ko\u0142uda Ma\u0142a",
  "Bia\u0142e B\u0142ota \\(Bydgoszcz\\)" , "Bia\u0142e B\u0142ota",
  "Upit\u00E9" , "Upyt\u00E9",
  "Nashville, TN" , "Nashville",
  "Francja" , "France",
  "Lomianki ko\u0142o Warsaw" , "Lomianki",
  "Granteln \\(Granteles,Iekava\\)", "Granteles",
  "Bistrampolis" , "Bystrampol",
  "W\u0142adiwosto\u0323k",  "Vladivostok",
  "Montr\u00E9al" , "Montreal",
  "Auschwitz" , "Auschwitz, Poland",
  "Kursze \\(Karol\u00F3w\\)" , "Ramygala, Lithuania",
  " \\(cm ul.Ga\u0142czynskiego\\)" , "",
  " \\(cm.ul.Ga\u0142czynskiego\\)" , "",
  "Torun" , "Toru\u0144",
  "Bauska/Letland", "Bauska, Latvia",
  "Gross-Sessau \\(Kurlandia\\)", "Gross-Sessau, Latvia",
  'Litwa', "Lithuania",
  "Rzym, Italia", "Rome, Italy",
  "Warszawa", "Warsaw, Poland",
  "Gdansk$", "Gdansk, Poland",
  "Bystrampol$", "Bystrampol, Lithuania"
  
), ncol =2, byrow=T) ), c("from", "to"))


family_corrections <- list(
  
  # George Hartwig and sibling
  F134 = list(
    CHIL = c("I362", "I503")
  )
)

individual_corrections <- list(
  
  # Agota Maria Maia Pethö 
  I286 = list(
    NAME = list(
      GIVN = "Ágota Maria Maia"
    )
  ),
  
  # Catherine Plowright
  I288 = list(
    NAME = list(
      GIVN = "Catherine Maria Sophia"
    )
  ),
  
  # Chris Plowright
  I357 = list(
    BIRT = list(
      PLAC = "Sheffield, UK"
    )
  ),
  
  # Alex Bystram
  I287 = list(
    NAME = list(
      GIVN = "Alexander Stephen Charles"
    )
  ),

  # Lynne Chickakian
  I2213 = list(
    BIRT = list(
      DATE = 'September 9, 1962',
      YEAR = 1962,
      PLAC = "Toronto, Canada",
      CIRCA = FALSE
    )
  ),
  
  # Liz Bystram
  I289 = list(
    NAME = list(
      GIVN = "Elizabeth Anne Bystram"
    )
  ),
  
  # Pierre Tremblay
  I447 =  list(
    BIRT = list(
      DATE = 'August 18, 1961',
      YEAR = 1961,
      PLAC = "Ottawa, Canada",
      CIRCA = FALSE
    )
  ),
  
  # Carl Plowright
  I445 = list(
    NAME = list(
      GIVN = "Carl Elizabeth",
    )
  ),
  
  # Isabel Plowright
  I446 = list(
    NAME = list(
      GIVN = "Isabel Anne"
    )
  ),
  
  # Matthew Tremblay
  I2211 = list(
    BIRT = list(
      PLAC = "Ottawa, Canada"
    )
  ),
  # Michael Tremblay
  I2212 = list(
    BIRT = list(
      PLAC = "Ottawa, Canada"
    )
  ),

  
  # George Hartwig
  # who needs to be replaced in the correct (F134) family
  I503 = list(
    NAME = list(
      GIVN = "George Hartwig"
    ),
    FAMC = 'F134'
  ),
  
  # Fabian (I) "Zajaczkowski" Bystram
  # Removed the "Zajaczkowski" bit
  I200 = list(
    NAME = list(
      GIVN = 'Fabian I'
    )
  ),
  
  # Korwin-Kossakowska z Wojtkuszek
  # Abbreviated to fit in the box
  I423 = list(
    NAME = (
      SURN = "Korwin-Kossakowska"
    )
  ),
  
  # Ottomar AleksanderII
  # Missing a space
  I186 = list(
    NAME = list(
      GIVN = 'Ottomar Aleksander II'
    )
  ),
  
  # Anna Elisabeth
  I251 = list(
    NAME = list(
      GIVN = "Anna Elisabeth"
    )
  )
)