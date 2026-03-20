select 
    c.Alias as CourseName,
    s.Number,
    s.Edition,
    s.EditionOrder, 
    s.[Year], 
    s.Revision, 
    s.InStock, 
    s.Remark
from Stock s
JOIN Courses c 
    on c.id = s.CourseID
where 1=1
    and (s.InStock is not null)
    or s.Remark is not null  
;
