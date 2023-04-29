
library(sqldf)

# Get Persons data

# Show only 
# * students that are 
# * enrolled
# * 
sqldf(
  "
  select
  
    pn.*, 
    ad.Address, 
    ad.HouseNumber, 
    --Postal Code, 
    ad.City
    -- */
    
  from Person pn
  left join Address ad
    on pn.addressId = ad.ID
  left join State st
    on st.ID and pn.StateID
  left join Class cl 
    on pn.classID = cl.ID
  where 1=1 
    and st.State = 'Enrolled'
    and pn.Status = 'Student'
  "
) %>% as_tibble

names(my_data)
# TODO create query to get latest address
