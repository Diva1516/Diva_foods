SELECT Name, COUNT(*) as Count FROM restaurant GROUP BY Name HAVING Count > 1;
