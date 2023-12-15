# create a view to show all ICCE levels

# select a certificate to view the requirements and options
view_certificate <- "Intermediate"
view_certificate <- "General Level 9"
view_certificate <- "Advanced Social Studies Bias"

vw_Certificate <- sqldf(
  paste0(
    "
    select
    
      en.ID, 
      icce.Certificate, 
      en.CourseName, 
      en.needChoice,
      sg.Name as 'Subject Group',
      en.StarValue
      -- , co.Alias
      
    from ICCE_certificates icce 
    join Enrollment en 
      on icce.ID = en.CertificateID
    join SubjectGroup sg
      on sg.ID = en.SubjectGroupID
      
    where 1=1 
      and en.ID is not null
      and en.Certificate = '", 
      view_certificate
      ,"'
    "
  )
)

# TODO join this later with vw_coursework
# TODO create select queries for "electives", i.e. courses where one can choose, so not only Further Credit Options. 
