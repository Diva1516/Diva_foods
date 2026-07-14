USE diva_foods;

-- newly generated Indian/desserts
UPDATE Menu SET imagePath = 'images/red_velvet.png' WHERE itemName LIKE '%Red Velvet Cupcake%';
UPDATE Menu SET imagePath = 'images/rasmalai.png' WHERE itemName LIKE '%Rasmalai%';
UPDATE Menu SET imagePath = 'images/dbc.png' WHERE itemName LIKE '%Death By Chocolate%';
UPDATE Menu SET imagePath = 'images/guntur_chicken.png' WHERE itemName LIKE '%Guntur Chicken%';
UPDATE Menu SET imagePath = 'images/gongura_pappu.png' WHERE itemName LIKE '%Gongura Pappu%';
UPDATE Menu SET imagePath = 'images/nellore_fish.png' WHERE itemName LIKE '%Nellore Fish%';
UPDATE Menu SET imagePath = 'images/tomato_pappu.png' WHERE itemName LIKE '%Tomato Pappu%';
UPDATE Menu SET imagePath = 'images/elaneer_payasam.png' WHERE itemName LIKE '%Elaneer Payasam%';

-- mapped to closest available images since generation limit was reached
UPDATE Menu SET imagePath = 'images/garlic_bread.png' WHERE itemName LIKE '%Margherita Pizza%';
UPDATE Menu SET imagePath = 'images/burger.png' WHERE itemName LIKE '%Veg Burger with Fries%';
UPDATE Menu SET imagePath = 'images/noodles.png' WHERE itemName LIKE '%Alfredo White Pasta%';
UPDATE Menu SET imagePath = 'images/garlic_bread.png' WHERE itemName LIKE '%Club Sandwich%';
UPDATE Menu SET imagePath = 'images/chicken_65.png' WHERE itemName LIKE '%Grilled Chicken Breast%';
UPDATE Menu SET imagePath = 'images/chicken_65.png' WHERE itemName LIKE '%Barbeque Chicken Wings%';
UPDATE Menu SET imagePath = 'images/noodles.png' WHERE itemName LIKE '%Arrabbiata Red Pasta%';
UPDATE Menu SET imagePath = 'images/french_fries.png' WHERE itemName LIKE '%Crispy Onion Rings%';
UPDATE Menu SET imagePath = 'images/choco_lava.png' WHERE itemName LIKE '%Thick Chocolate Shake%';
UPDATE Menu SET imagePath = 'images/garlic_bread.png' WHERE itemName LIKE '%Pepperoni Pizza%';
UPDATE Menu SET imagePath = 'images/noodles.png' WHERE itemName LIKE '%Alfredo Pasta%';
