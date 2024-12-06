select 
    p.Surname, 
    p.CallName, 
    p.DateOfBirth, 
    cl.Class, 
    l.FirstLanguage, 
    l.SecondLanguage, 
    b.Baptism, 
    d.Denomination
from Person p
join Address a 
    on p.AddressID = a.ID
join Class cl 
    on cl.id = p.classId
join Language l 
    on l.id = p.FirstLanguageID
join language l2 
    on l2.id = p.SecondLanguageID
join baptism b 
    on b.id = p.BaptismId
join Denomination d 
    on d.id = p.denominationID
where 1=1 
    and p.[Status] = 'Student'
    and s.State = 'Active'
;