-- Question Set 1 - Easy

-- Q1: Who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

-- Q2: Which countries have the most Invoices?

select billing_country, count(*) as Number_Of_Invoices 
from invoice
group by billing_country
order by Number_Of_Invoices desc;

-- Q3: What are top 3 values of total invoice?

select total from invoice
order by total desc
limit 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music
-- Festival in the city we made the most money. Write a query that returns one city that
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice
-- totals

select billing_city, sum(total) as Invoice_Total from invoice
group by billing_city
order by Invoice_Total desc;

-- Q5: Who is the best customer? The customer who has spent the most money will be
-- declared the best customer. Write a query that returns the person who has spent the
-- most money

select customer_id, first_name, last_name from customer 
where customer_id in 
	(select customer_id from invoice
	group by customer_id
	order by sum(total) desc
	limit 1);

-- OR

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

-- Question Set 2 – Moderate

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A

select email, first_name, last_name 
from customer 
where customer_id in
	(select customer_id from invoice where invoice_id in
		(select invoice_id from invoice_line where track_id in
			(select track_id from track where genre_id in
				(select genre_id from genre where name = 'Rock'))))
order by email;

-- Q2: Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

select artist.name, count(artist.artist_id) as total_track_count
from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
where genre_id in (select genre_id from genre where name = 'Rock')
group by artist.artist_id
order by total_track_count desc
limit 10;

-- Q3: Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- Question Set 3 – Advance

-- Q1: Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

select customer.customer_id, customer.first_name, customer.last_name, artist.name as artist_name, sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id, customer.customer_id
order by total_spent desc;

-- Q2: We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre.

with popular_genre as 
		(select invoice.billing_country as country, genre.name as genre_name, sum(invoice_line.quantity) as total_purchases,
		row_number() over (partition by invoice.billing_country order by sum(invoice_line.quantity) desc) as rownum
		from genre
		join track on genre.genre_id = track.genre_id
		join invoice_line on track.track_id = invoice_line.track_id
		join invoice on invoice_line.invoice_id = invoice.invoice_id
		group by invoice.billing_country, genre.name
		order by invoice.billing_country)
select country, genre_name, total_purchases from popular_genre where rownum = 1;

-- Q3: Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent.

select country, customer_id, first_name, last_name, total_spent 
from	(select 	customer.customer_id, customer.first_name, customer.last_name, customer.country, 
					sum(invoice.total) as total_spent, 
					row_number() over (partition by customer.country order by sum(invoice.total) desc) as rownum
		from customer
		join invoice on customer.customer_id = invoice.customer_id
		group by customer.country, customer.customer_id
		order by customer.country) temptable
where rownum = 1;
