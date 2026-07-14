-- Update orderitem to point to the minimum MenuID for each duplicate
UPDATE orderitem oi
JOIN (
    SELECT m1.MenuID as OldID, (
        SELECT MIN(m2.MenuID)
        FROM menu m2
        WHERE m2.RestaurantID = m1.RestaurantID AND m2.ItemName = m1.ItemName
    ) as NewID
    FROM menu m1
) mapping ON oi.MenuID = mapping.OldID
SET oi.MenuID = mapping.NewID;

-- Now delete the duplicate menus
DELETE m1 FROM menu m1
INNER JOIN menu m2 
WHERE m1.MenuID > m2.MenuID AND m1.RestaurantID = m2.RestaurantID AND m1.ItemName = m2.ItemName;
