# create_vw_grades.R

join(Grade, Person, 
     # by = c("StudentID", "ID"))
     join_by("StudentID" == "ID")
)

  
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

# Find a way to pivot these into one row for each course
# in a specific order 
# on a specific location 
# depending on the enrollment 
# adding a grade-dependent colored star
# the pass-level depends on the grade

#todo/tothiergebleven 

# Create plot
# first update order of courses on enrollment worksheet 
# then, according to this order reorder this table, for this student (regardless of term), by number 
# plot each value with text, and then a position 

# Dimensions of A4
# create empty plot #todo/opzoeken 
xlim_A4 <- c(0, 468)
ylim_A4 <- c(0, 689)
plot(
  c(), 
  c(), 
  xlim_A4, 
  ylim_A4
  )
text(Grades$Alias[1], 
     10, 10)


