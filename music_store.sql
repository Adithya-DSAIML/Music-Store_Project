use music_store;
Create Table genre
(genre_id varchar(10),
name varchar(20));

CREATE TABLE album2 
(
    album_id bigint primary key,
    title varchar(255),
    artist_id bigint
);

/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */
select billing_country,count(invoice_id) as nbr_of_invoice from invoice
group by billing_country
order by nbr_of_invoice desc;

/* Q3: What are top 3 values of total invoice? */
with cte as(
select total as total_invoice, dense_rank() over(order by total desc) as ranks from invoice)
select total_invoice from cte where ranks <= 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_country,round(sum(total),2) as total_revenue from invoice
group by billing_country
order by total_revenue desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select c.customer_id, c.first_name,c.last_name, round(sum(total),2) as total_spending
from
customer as c
join
invoice as i
on i.customer_id = c.customer_id
group by 1,2,3
order by total_spending desc;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select distinct c.first_name, c.last_name, c.email,g.name
from customer as c
join invoice as i
on c.customer_id = i.customer_id
join invoice_line as il
on i.invoice_id = il.invoice_id
join track as t
on il.track_id = t.track_id
join genre as g
on t.genre_id = g.genre_id
where g.name = 'rock';


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
with cte as(
select distinct ar.artist_id,ar.name, count(t.name) as nbr_of_songs, dense_rank() over(order by count(t.name) desc) as ranks
from artist as ar
join album as a
on ar.artist_id = a.artist_id
join track as t
on t.album_id = a.album_id
join genre as g
on g.genre_id = t.genre_id
where g.name = 'rock'
group by 1,2
order by nbr_of_songs desc)
select artist_id, name, nbr_of_songs from cte where ranks <= 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name, milliseconds from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
with best_selling_artist as (select ar.artist_id, ar.name, round(sum(il.unit_price*il.quantity),2) as total_sales
from
invoice_line as il
join track as t 
on t.track_id = il.track_id
join album as a
on a.album_id = t.album_id
join artist as ar
on ar.artist_id = a.artist_id
group by 1,2
order by 3 desc)

select c.customer_id,c.first_name,c.last_name,b.name, round(sum(il.unit_price*il.quantity),2) as amount_spent
from
invoice as i
join customer as c
on c.customer_id = i.customer_id
join invoice_line as il
on i.invoice_id = il.invoice_id
join track as t
on t.track_id = il.track_id
join album as a
on a.album_id = t.album_id
join best_selling_artist as b
on b.artist_id = a.artist_id
group by 1,2,3,4
order by amount_spent desc;

-- Method 2
select c.customer_id,c.first_name,c.last_name,ar.name, round(sum(il.unit_price*il.quantity),2) as amount_spent
from
invoice as i
join customer as c
on c.customer_id = i.customer_id
join invoice_line as il
on i.invoice_id = il.invoice_id
join track as t
on t.track_id = il.track_id
join album as a
on a.album_id = t.album_id
join artist as ar
on ar.artist_id = a.artist_id
group by 1,2,3,4
order by amount_spent desc;


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with cte as (
select g.genre_id, c.country, g.name, count(il.quantity) as purchases, 
dense_rank() over(partition by country order by count(il.quantity) desc) as ranks
from
track as t
join genre as g
on t.genre_id = g.genre_id
join invoice_line as il
on il.track_id = t.track_id
join invoice as i
on i.invoice_id = il.invoice_id
join customer as c
on i.customer_id = c.customer_id
group by 1,2,3)

select genre_id, country, name, purchases from cte
where ranks = 1;

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with cte as (
select c.customer_id, c.first_name, c.last_name, i.billing_country, round(sum(i.total),2) as amount_spent, 
dense_rank() over(partition by i.billing_country order by round(sum(i.total),2) desc) as dns_rank
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by 1,2,3,4)

select customer_id, first_name, last_name, billing_country, amount_spent from cte 
where dns_rank = 1;
