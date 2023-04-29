# separate tables from the my_data list into separate tables

Person <- my_data$Person
Person <- Person[-which(grepl(IGNORE_CHAR, names(Person)))]

Date <- my_data$Date
Grade <- my_data$Grade
Address <- my_data$Address
State <- my_data$State
Class <- my_data$Class
ICCE_certificates <- my_data$ICCE_Certificate
Enrollment <- my_data$Enrollment
Coursework <- my_data$CourseWorkICCE_Certificate
Course <- my_data$Course
SubjectGroup <- my_data$SubjectGroup
PaceCourse <- my_data$PaceCourse
PACE <- my_data$PACE
