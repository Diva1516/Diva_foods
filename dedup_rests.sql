-- Update orders to point to the minimum RestaurantID for each duplicate
UPDATE ordertable ot
JOIN (
    SELECT r1.RestaurantID as OldID, (
        SELECT MIN(r2.RestaurantID)
        FROM restaurant r2
        WHERE r2.Name = r1.Name
    ) as NewID
    FROM restaurant r1
) mapping ON ot.RestaurantID = mapping.OldID
SET ot.RestaurantID = mapping.NewID;

-- Update menus to point to the minimum RestaurantID
UPDATE menu m
JOIN (
    SELECT r1.RestaurantID as OldID, (
        SELECT MIN(r2.RestaurantID)
        FROM restaurant r2
        WHERE r2.Name = r1.Name
    ) as NewID
    FROM restaurant r1
) mapping ON m.RestaurantID = mapping.OldID
SET m.RestaurantID = mapping.NewID;

-- Re-deduplicate menus just in case merging restaurants created duplicate menus for the same restaurant
DELETE m1 FROM menu m1
INNER JOIN menu m2 
WHERE m1.MenuID > m2.MenuID AND m1.RestaurantID = m2.RestaurantID AND m1.ItemName = m2.ItemName;

-- Delete duplicate restaurants
DELETE r1 FROM restaurant r1
INNER JOIN restaurant r2 
WHERE r1.RestaurantID > r2.RestaurantID AND r1.Name = r2.Name;
