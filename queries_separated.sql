--Conclusão 1: Quem é o melhor cliente
SELECT
  c.CustomerId,
  c.FirstName || ' ' || c.LastName AS CustomerName,
  SUM(i.Total) AS total_expended
FROM Invoice i
JOIN Customer c
  ON i.CustomerId = c.CustomerId
GROUP BY CustomerName
ORDER BY total_expended DESC

--Conclusão 2: Qual gênero tem mais musicas cadastradas
SELECT
  Genre.Name,
  COUNT(*) AS Songs
FROM Track
JOIN Genre
  ON Genre.GenreId = Track.GenreId
GROUP BY Genre.Name
ORDER BY Songs DESC


--Conclusão 3: Quem está escrevendo as músicas de rock?
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

--Ultima conclusão: Qual artista mais faturou com qual cliente
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

