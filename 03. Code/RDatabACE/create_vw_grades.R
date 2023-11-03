# create_vw_grades.R

  
library(sqldf)

Grades <- sqldf(
  "
  select 
    p.CallName, p.Surname,
    
    g.Date, 
    g.Course, 
    g.Pace_ID, 
    g.Type, 
    g.Grade,
    d.Term, 
    
    c.Alias,
    
    /* case when g.Grade >= c.PassThreshold then 
      'Passed' 
    else 
      'Failed'
    end as Passed, -- */
    
    -- pace.StarValue,
    pace.Number
    
  from Grade g
  join Person p  
    on g.StudentID = p.ID
  join Date d 
    on g.Date = d.Date
  join PaceCourse pc
    on g.Course = pc.courseID
    and g.Pace_ID = pc.paceID
  join PACE pace 
    on pc.paceID = pace.ID
  join Course c 
    on c.ID = pc.courseID
  "
) %>% 
  as_tibble

# Selection
# Only Toby, only the "Advanced Maths Bias" certificate

thisSurname <- "Adeleke"
thisCallName <- "Oluwatobi"
certificate_selected <- "Advanced Maths Bias"

# Get the Grades table, filter it to get only the relevant certificate
Grades_filtered <- Grades %>% 
  filter(Surname == thisSurname,
         CallName == thisCallName)
  # arrange()

# Get the Enrollment table, filter it to get only the relevant certificate
Enrollment_ordered <- Enrollment %>% 
  filter(Certificate == certificate_selected) %>%
  arrange(Order)

# I need a way to find out which course's turn it is when we go through the Grades_filtered table.
# This is only possible if in the EnrollmentCourses sheet there is data. This needs 
# to be populated through a UI, such as 
# * StudentID
# * Certificate (optional), but needed when applying for a certificate
# * Course (each selected course needs to be mapped to a field within the selected certificate. 
# For example, if Apologetics has been chosen, the user must indicate whether this course 
# applies as an elective, further credit option, or as elective for Biblical Studies.)

# Find a way to pivot these into one row for each course
# in a specific order 
# on a specific location 
# depending on the enrollment 
# adding a grade-dependent colored star
# the pass-level depends on the grade

#todo/tothiergebleven 

# Plotting can occur later, first pivot 

# Create plot
# first update order of courses on enrollment worksheet 
# then, according to this order reorder this table, for this student (regardless of term), by number 
# plot each value with text, and then a position 


# Dimensions of A4
# create empty plot 
# TODO find a way to plot same scale on both axes
xlim_A4 <- c(0, 468)
ylim_A4 <- c(0, 689)

# create an empty plot
plot(
  c(), 
  c(),
  main = "Current Progress",
  xlim = xlim_A4, 
  ylim = ylim_A4
  )


# calculate the position of the row
# for each course (`Alias`), print out the grades from left to right

#todo/tothiergebleven 
# TODO
# Uitzoeken hoe A4 plotten
# https://stackoverflow.com/questions/41768273/create-ggplots-with-the-same-scale-in-r
# https://stackoverflow.com/questions/16783019/how-to-save-a-graph-as-an-a4-size-pdf-file-under-windows-system-r-ggplot2
# Uitzoeken hoe hoog die rijen zijn
# Elke rij in een apart png-bestand zetten en die als achtergrond gebruiken
## Of eventueel elk blokje apart printen, en zelfs de kleur afhankelijk maken van het vak
# Deze rijen moeten in een bepaalde volgorde. Welke volgorde gebruiken?


# text(Grades$Alias[1], 
#      10, 10)


