create view vw_Person as 

select 
    p.Surname, 
    p.CallName, 
    p.DateOfBirth, 
    cl.Class, 
    l.language as FirstLanguage, 
    l2.language as SecondLanguage, 
    b.Baptism, 
    d.Denomination,
	p.IsDislectic
from Person p
join Address a 
    on p.AddressID = a.ID
join Class cl 
    on cl.id = p.classId
left join Language l 
    on l.id = p.FirstLanguageID
left join language l2 
    on l2.id = p.SecondLanguageID
join baptism b 
    on b.id = p.BaptismId
join Denomination d 
    on d.id = p.denominationID
join State s 
    on s.id = p.StateID
where 1=1 
    and p.[Status] = 'Student'
    and s.State = 'Enrolled'
;



/*
Tables to create: 
Address
Class
Language
Baptism
Denomination
State
*/