-- browse all movies 
-- rented or not
select  distinct title, rating, price
from movies group by title;

-- using genre
select distinct title, rating, price, genre 
from movies where genre = usergenre
group by title;

--using title
select distinct distinct title, rating, price,  
from movies where title = usertitle
group by title;

-- actors present in film
select * from movies 
join movieactors using(movieid)
join actors using(actorid);


-- can maybe be simplified
select distinct title, rating, price
from movies where userInputFunction(userInput) = userInput;

--Film in stock – Create a subprogram that determines if a film is currently available for rent.
create or replace function checkWhatUserWants(userInput in varchar2) RETURN CHAR AS
--variables
begin 
-- can maybe be simplified

IF userInput = 'title' then
dbms_output.put_line('user input is title');
return 'title';

elsif userINput = 'genre' then
dbms_output.put_line('user input is genre');
return 'genre';
end if;

end;
-- run function 
DECLARE
		userInput varchar(64);
BEGIN
		userInput := filmInStock('Nothing Lasts Forever');
		dbms_output.put_line(userInput);
END;





