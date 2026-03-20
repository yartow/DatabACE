# separate tables from the my_data list into separate tables

print("Separating tables")
Person <- my_data$Person %>% select(-contains(IGNORE_CHAR)) # Person <- Person[-which(grepl(IGNORE_CHAR, names(Person)))]
Date <- my_data$Date %>% select(-contains(IGNORE_CHAR))
Grade <- my_data$Grade %>% select(-contains(IGNORE_CHAR))
Address <- my_data$Address %>% select(-contains(IGNORE_CHAR))
State <- my_data$State %>% select(-contains(IGNORE_CHAR))
Class <- my_data$Class %>% select(-contains(IGNORE_CHAR))
ICCE_certificates <- my_data$ICCE_Certificate %>% select(-contains(IGNORE_CHAR))
Enrollment <- my_data$Enrollment %>% select(-contains(IGNORE_CHAR))
Coursework <- my_data$CourseWorkICCE_Certificate %>% select(-contains(IGNORE_CHAR))
Course <- my_data$Course %>% select(-contains(IGNORE_CHAR))
SubjectGroup <- my_data$SubjectGroup %>% select(-contains(IGNORE_CHAR))
PaceCourse <- my_data$PaceCourse %>% select(-contains(IGNORE_CHAR))
PACE <- my_data$PACE %>% select(-contains(IGNORE_CHAR))
