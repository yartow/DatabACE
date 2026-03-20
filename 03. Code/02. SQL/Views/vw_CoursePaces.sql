select 
    c.Alias as Name, 
    c.ICCE_Alias, 
    c.[Level], 
    c.Remarks, 
    c.CourseType,
    c.PassThreshold, 
    p.Number, 
    p.Remark as RemarkPace
from Courses c 
join PaceCourse pc 
    on c.id = pc.CourseID
join Pace p 
    on p.id = pc.PaceID
where 1=1  
    and c.[Status] <> 'Inactive'
    and p.[Type] = 'PT'
;