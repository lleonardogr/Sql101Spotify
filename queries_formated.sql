--Pergunta 1: Quais países possuem mais faturas?
SELECT
  BillingCountry,
  COUNT(*) AS invoices
FROM Invoice
GROUP BY BillingCountry
ORDER BY invoices DESC

--Pergunta 2; Qual cidade tem os melhores clientes?
SELECT
  BillingCity,
  SUM(Total) AS total_collected
FROM Invoice
GROUP BY BillingCity
ORDER BY total_collected DESC

--Pergunta 3: Quem é o melhor cliente?
SELECT
  c.CustomerId,
  c.FirstName || ' ' || c.LastName AS CustomerName,
  SUM(i.Total) AS total_expended
FROM Invoice i
JOIN Customer c
  ON i.CustomerId = c.CustomerId
GROUP BY CustomerName
ORDER BY total_expended DESC

--Parte 2
--Pergunta 1: se sua consulta para retornar o e-mail, nome, sobrenome e gênero de todos os ouvintes de Rock. 
--Retorne sua lista ordenada alfabeticamente por endereço de e-mail, começando por A. 
--Você consegue encontrar um jeito de lidar com e-mails duplicados para que ninguém receba vários e-mails?
SELECT DISTINCT
  (c.Email),
  c.FirstName,
  c.LastName,
  g.Name AS Genre
FROM Customer c
JOIN Invoice i
  ON i.CustomerID = c.CustomerId
JOIN InvoiceLine il
  ON il.InvoiceId = i.InvoiceId
JOIN Track t
  ON t.TrackId = il.TrackId
JOIN Genre g
  ON g.GenreId = t.GenreId
WHERE g.Name = 'Rock'
ORDER BY c.Email

--Pergunta 2: Quem está escrevendo as músicas de rock?
SELECT
  artist.ArtistId,
  Artist.Name,
  COUNT(*) AS Songs
FROM Track
JOIN Genre
  ON Genre.GenreId = Track.GenreId
JOIN Album
  ON Album.AlbumId = Track.AlbumId
JOIN Artist
  ON Artist.ArtistId = Album.ArtistId
WHERE Genre.Name = 'Rock'
GROUP BY Artist.Name
ORDER BY Songs DESC

--Pergunta 3
--Primeiro, descubra qual artista ganhou mais de acordo com InvoiceLines (linhas de faturamento)?
SELECT
  artist.ArtistId,
  Artist.Name,
  SUM(InvoiceLine.UnitPrice * invoiceLine.Quantity) AS Invoices
FROM InvoiceLine
JOIN Track
  ON Track.TrackId = InvoiceLine.TrackId
JOIN Album
  ON Album.AlbumId = Track.AlbumId
JOIN Artist
  ON Artist.ArtistId = Album.ArtistId
GROUP BY Artist.Name
ORDER BY Invoices DESC

--Agora use este artista para encontrar qual cliente gastou mais com este artista.
SELECT
  a.Name,
  SUM(il.UnitPrice * il.Quantity) AS AmountSpent,
  c.CustomerId,
  c.FirstName,
  c.LastName
FROM Invoice
JOIN Customer c
  ON c.CustomerId = Invoice.CustomerId
JOIN InvoiceLine il
  ON il.InvoiceId = Invoice.InvoiceId
JOIN Track t
  ON t.TrackId = il.TrackId
JOIN Album
  ON Album.AlbumId = t.AlbumId
--Join Query anterior
JOIN (SELECT
  artist.ArtistId,
  Artist.Name,
  SUM(InvoiceLine.UnitPrice * invoiceLine.Quantity) AS Invoices
FROM InvoiceLine
JOIN Track
  ON Track.TrackId = InvoiceLine.TrackId
JOIN Album
  ON Album.AlbumId = Track.AlbumId
JOIN Artist
  ON Artist.ArtistId = Album.ArtistId
  GROUP BY Artist.Name
  ORDER BY Invoices desc
	LIMIT 1) AS a
  ON album.ArtistId = a.ArtistId
GROUP BY c.CustomerId,
         a.Name
ORDER BY AmountSpent DESC

-- Parte 3
--Pergunta 1
--Queremos descobrir o gênero musical mais popular em cada país. 
--Determinamos o gênero mais popular como o gênero com o maior número de compras. 
--Escreva uma consulta que retorna cada país juntamente a seu gênero mais vendido. 
--Para países onde o número máximo de compras é compartilhado retorne todos os gêneros.

SELECT
  *
FROM (SELECT
  COUNT(*) AS Purchases,
  i.BillingCountry AS Country,
  g.Name AS Name,
  g.GenreId AS GenreId
FROM Invoice i
JOIN InvoiceLine il
  ON il.InvoiceId = i.InvoiceId
JOIN Track t
  ON t.TrackId = il.TrackId
JOIN Album al
  ON al.AlbumId = t.AlbumId
JOIN Artist a
  ON a.ArtistId = al.ArtistId
JOIN Genre g
  ON g.GenreId = t.GenreId
GROUP BY Country,
         g.Name) AS sub
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
ORDER BY Country

--Pergunta 2
--Retorne todos os nomes de músicas que possuem um comprimento de canção maior que o comprimento médio de canção.
SELECT
  t.Name,
  t.Milliseconds AS SongTime
FROM Track t
WHERE SongTime > (SELECT
  AVG(t.Milliseconds)
FROM Track t)
ORDER BY SongTime DESC

--Pergunta 3
--Escreva uma consulta que determina qual cliente gastou mais em músicas por país. 
--Escreva uma consulta que retorna o país junto ao principal cliente e quanto ele gastou
SELECT
  *
FROM (SELECT
  i.BillingCountry AS Country,
  SUM(i.Total) AS TotalSpent,
  c.FirstName,
  c.LastName,
  c.CustomerId
FROM Invoice i
JOIN Customer c
  ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId) AS cs
GROUP BY Country
ORDER BY CustomerId

