--Pergunta 1: Quais países possuem mais faturas?
SELECT BillingCountry, count(*) as invoices
from Invoice
group by BillingCountry
order by invoices desc

--Pergunta 2; Qual cidade tem os melhores clientes?

SELECT BillingCity, sum(Total) as total_collected
from Invoice
group by BillingCity
order by total_collected desc

--Pergunta 3: Quem é o melhor cliente?
SELECT c.CustomerId, c.FirstName || ' ' || c.LastName as CustomerName, sum(i.Total) as total_expended
from Invoice i
join Customer c on i.CustomerId = c.CustomerId
group by CustomerName
order by total_expended desc

--Parte 2
--Pergunta 1: se sua consulta para retornar o e-mail, nome, sobrenome e gênero de todos os ouvintes de Rock. 
--Retorne sua lista ordenada alfabeticamente por endereço de e-mail, começando por A. 
--Você consegue encontrar um jeito de lidar com e-mails duplicados para que ninguém receba vários e-mails?
select distinct(c.Email), c.FirstName, c.LastName, g.Name as Genre
from Customer c
join Invoice i on i.CustomerID = c.CustomerId
join InvoiceLine il on il.InvoiceId = i.InvoiceId
join Track t on t.TrackId = il.TrackId
join Genre g on g.GenreId = t.GenreId
where g.Name = 'Rock'
order by c.Email

--Pergunta 2: Quem está escrevendo as músicas de rock?
select artist.ArtistId, Artist.Name, count(*) as Songs
from Track
join Genre on Genre.GenreId = Track.GenreId
join Album on Album.AlbumId = Track.AlbumId
join Artist on Artist.ArtistId = Album.ArtistId
Where Genre.Name = 'Rock'
Group by Artist.Name
order by Songs desc

--Pergunta 3
--Primeiro, descubra qual artista ganhou mais de acordo com InvoiceLines (linhas de faturamento)?
select artist.ArtistId, Artist.Name, sum(InvoiceLine.UnitPrice * invoiceLine.Quantity) as Invoices
from InvoiceLine
join Track on Track.TrackId = InvoiceLine.TrackId
join Album on Album.AlbumId = Track.AlbumId
join Artist on Artist.ArtistId = Album.ArtistId
group by Artist.Name
order by Invoices desc

--Agora use este artista para encontrar qual cliente gastou mais com este artista.
select a.Name, sum(il.UnitPrice * il.Quantity) as AmountSpent, 
c.CustomerId, c.FirstName, c.LastName
from Invoice 
join Customer c on c.CustomerId = Invoice.CustomerId
join InvoiceLine il on il.InvoiceId = Invoice.InvoiceId
join Track t on t.TrackId = il.TrackId
join Album on Album.AlbumId = t.AlbumId
--Join Query anterior
join (select artist.ArtistId, Artist.Name, sum(InvoiceLine.UnitPrice * invoiceLine.Quantity) as Invoices
	from InvoiceLine
	join Track on Track.TrackId = InvoiceLine.TrackId
	join Album on Album.AlbumId = Track.AlbumId
	join Artist on Artist.ArtistId = Album.ArtistId
	group by Artist.Name
	order by Invoices desc
	limit 1) as a on album.ArtistId = a.ArtistId 
group by c.CustomerId, a.Name
order by AmountSpent desc

-- Parte 3
--Pergunta 1
--Queremos descobrir o gênero musical mais popular em cada país. 
--Determinamos o gênero mais popular como o gênero com o maior número de compras. 
--Escreva uma consulta que retorna cada país juntamente a seu gênero mais vendido. 
--Para países onde o número máximo de compras é compartilhado retorne todos os gêneros.

select * from (
select count(*) as Purchases, i.BillingCountry as Country, g.Name as Name, g.GenreId as GenreId
from Invoice i
join InvoiceLine il on il.InvoiceId = i.InvoiceId
join Track t on t.TrackId = il.TrackId
join Album al on al.AlbumId = t.AlbumId
join Artist a on a.ArtistId = al.ArtistId
join Genre g on g.GenreId = t.GenreId
group by Country, g.Name) as sub
where (Purchases, Country) in 
	(select max(Purchases), Country
	from (
select count(*) as Purchases, i.BillingCountry as Country, g.Name as Name, g.GenreId as GenreId
from Invoice i
join InvoiceLine il on il.InvoiceId = i.InvoiceId
join Track t on t.TrackId = il.TrackId
join Album al on al.AlbumId = t.AlbumId
join Artist a on a.ArtistId = al.ArtistId
join Genre g on g.GenreId = t.GenreId
group by Country, g.Name
) group by Country)
order by Country


--Pergunta 2
--Retorne todos os nomes de músicas que possuem um comprimento de canção maior que o comprimento médio de canção.
select t.Name, t.Milliseconds as SongTime
from Track t
where SongTime > (
	select avg(t.Milliseconds)
	from Track t
)
order by SongTime desc

--Pergunta 3
--Escreva uma consulta que determina qual cliente gastou mais em músicas por país. 
--Escreva uma consulta que retorna o país junto ao principal cliente e quanto ele gastou
select * 
from (
	select  i.BillingCountry as Country, sum(i.Total) as TotalSpent, c.FirstName, c.LastName, c.CustomerId
	from Invoice i
	join Customer c on c.CustomerId = i.CustomerId
	group by c.CustomerId
) as cs
group by Country
order by CustomerId

