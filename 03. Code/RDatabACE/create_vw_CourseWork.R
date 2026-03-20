vw_CourseWork <- sqldf(
  paste0(
    "
    select 
      en.Certificate, 
      en.CourseName,
      co.Alias as CoursesToChooseFrom
    from Enrollment en
    join Coursework cw
      on cw.certificateID = en.certificateID
    join Course co
      on co.ID = cw.courseID -- */
    where 1=1
      and en.Type = 'Coursework' 
      and cw.Certificate = '", 
    view_certificate
    ,"'
    "  
  )
) %>% as_tibble

