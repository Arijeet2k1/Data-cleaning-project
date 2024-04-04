CREATE DATABASE PROJECT_1;
USE PROJECT_1;

-- DATA WRANGLING
-- Step 1 Gathered Data from csv
-- Step 2 Assessing Data

	-- Summary of Overall data
		-- This data is all about smartphones ->  It shows their detailed informartion,
		-- specificcations and prices of each model and this is an uncleaned data
        
	-- Column Descriptions of Smartphones Table
		-- Model: Textual identifier for the specific phone model (e.g., OnePlus 11 5G)
		-- Price: Numerical value representing the phone's cost (e.g., Rs. 15,999)
		-- Rating: This column contains an average user experience of the phone on a specific scale to be compared.
		-- SIM: This column describes the phone's SIM card capabilities.
		-- Processor: This column identifies the central processing unit (CPU) model powering the phone.
		-- RAM: Value indicating the phone's Random Access Memory capacity & Read Only Memory is also given in the same column
		-- Battery: Numerical value indicating the phone's expected battery life (e.g., 5000 mAh)
		-- Display: Numerical value representing the diagonal screen size of the phone (e.g., 6.7 inches)
		-- Camera: Numerical value indicating the camera sensor resolution (e.g., 50 MP)
		-- Card: It contain a text description of the memory card capabilities.
		-- Operating System: Textual identifier for the phone's software platform (e.g., Android 13)
        
	-- Finding the Problems with data

		-- Dirty Data
            # model: The name "OPPO" is writen in 2 different ways i.e- ("OPPO" and "Oppo")
				-- so we have to make both of them equal for further analysis
                -- row 755 will be deleted because there is a data of ipod 
			-- price: all rows contains "," this symbol which needs to be removed
			-- rating: THERE ARE SO MANY NULL VALUES IN THIS COLUMN
            # processor: There are so many rows where the processor name
				-- is not clearly mentioned or mentioned with different names like
                -- "apple a14" and "bionic a12",
                -- many processor names are not given in processor column
			# ram: in some rows ram and rom data is given in mb
				-- in some rows the data is given without mentioning ram or rom
                -- unnecessary symbols are there in the data like this -> "â","€","‰"
			# battery: remove symbols like "â€‰"
            # display: revove symbols like "â€‰"
            # camera: revove symbols like "â€‰"
            # card: null values
				-- revove symbols like "â€‰"
            # os: null values
		-- Messy Data
			# processor: The data of "Processor name" will be seperated in different column
				-- other column data is also inserted in this column like- "battery", "ram" , "sim" etc which needs to be seperated and placed somewhere else
			# ram: (ROM, display, battery,sim) data is also given in this column 
            # battery: ram,rom,camera,display,fast charging data is also inside this column
            # display: ( height, digonals and width,camera,refresh rate,notch,camera, card,battery, os ) data is given in the same column
			# camera: front ,rare camera needs to be seperated
				-- os, display, card,bluetooth in other column
			# card: camera, os, display, bluetooth, hybrid slot needs to be seperated
            # os: camera, card, fm radio needs to be seperated

            
            
-- creating a clone data for future mistakes
CREATE TABLE smartphones_clone LIKE smartphones;
INSERT INTO smartphones_clone
SELECT * FROM smartphones;

SELECT * FROM smartphones_clone;
SELECT * FROM smartphones;

-- searching for duplicates
SELECT model,price,rating,sim,processor,ram,battery,display,camera,card,os,count(*) FROM smartphones
GROUP BY model,price,rating,sim,processor,ram,battery,display,camera,card,os HAVING COUNT(*)>1;
-- no duplicates found

-- Adding colummn to extract brand name
ALTER TABLE smartphones
ADD COLUMN brand_name VARCHAR(50) AFTER `Index`;

-- EXTRACTING BRAND NAME FROM MODEL COLUMN
SET SQL_SAFE_UPDATES = 0;
UPDATE smartphones AS l2
SET brand_name = (SELECT SUBSTRING_INDEX(l1.model, ' ', 1) 
				 FROM 
				(SELECT * FROM smartphones) AS l1 
				 WHERE l2.`Index` = l1.`Index`);
                
/* fixed the whole brand_name column where Poco and POCO should be under Xiaomi Brand &
     Oppo is written in 2 different ways (OPPO & Oppo)   */
UPDATE smartphones 
SET brand_name = 'Xiaomi' WHERE brand_name = 'Poco' OR brand_name = 'POCO';

UPDATE smartphones
SET brand_name = 'Oppo' WHERE brand_name = 'OPPO';

-- deleting the entire row - '755' because ipod data is given in smartphones table
DELETE FROM smartphones
WHERE `Index` = 755;

select * FROM smartphones;

/*                   CLEANING THE PRICE COLUMN
              Removing these 2 symbols from price column ->  ? ,                         */
UPDATE smartphones
SET price = REPLACE(price, '?', '');

UPDATE smartphones
SET price = ROUND(REPLACE(price, ',', ''),0);

-- changing the datatype of price column from text to integer
ALTER TABLE smartphones
MODIFY COLUMN price INTEGER;

SELECT * FROM smartphones;

-- extracting 5g_Available column from sim column 
ALTER TABLE smartphones
ADD COLUMN 5g_Available VARCHAR(15) AFTER sim;

UPDATE smartphones AS l2
SET 5g_Available = (SELECT 
						CASE 
							WHEN sim LIKE '%5G%' THEN 'yes' 
							ELSE 'no' 
						END AS supports_5G
					FROM (SELECT * FROM smartphones) l1
					WHERE L1.`Index` = l2.`Index`);

-- Replacing 0's in rating column with average rating based on several price groups
update smartphones t2
join
(select `index`,
case
	when price between 1900 and 5000 then (select ROUND(avg(rating)) from smartphones where price between 1900 and 5000 )
    when price between 5000 and 9000 then (select ROUND(avg(rating)) from smartphones where price between 5000 and 9000)
    when price between 9000 and 14000 then (select ROUND(avg(rating)) from smartphones where price between 9000 and 14000)
    when price between 14000 and 20000 then (select ROUND(avg(rating)) from smartphones where price between 14000 and 20000)
    when price between 20000 and 26000 then (select ROUND(avg(rating)) from smartphones where price between 20000 and 26000)
    when price between 26000 and 34000 then (select ROUND(avg(rating)) from smartphones where price between 26000 and 34000)
    when price between 34000 and 40000 then (select ROUND(avg(rating)) from smartphones where price between 34000 and 40000)
    when price between 40000 and 50000 then (select ROUND(avg(rating)) from smartphones where price between 40000 and 50000)
    when price between 50000 and 60000 then (select ROUND(avg(rating)) from smartphones where price between 50000 and 60000)
    when price between 60000 and 70000 then (select ROUND(avg(rating)) from smartphones where price between 60000 and 70000)
    when price between 70000 and 80000 then (select ROUND(avg(rating)) from smartphones where price between 70000 and 80000)
    when price between 80000 and 95000 then (select ROUND(avg(rating)) from smartphones where price between 80000 and 95000)
    when price between 95000 and 133000 then (select ROUND(avg(rating)) from smartphones where price between 95000 and 133000)
    when price between 133000 and 240000 then (select ROUND(avg(rating)) from smartphones where price between 133000 and 240000)
    end AS AVG_
    from (select * from smartphones where rating = 0) a) t1
on t1.`Index` = t2.`Index`
set rating = AVG_ ;

-- analyzed those price groups which i created and found that it can be divided into 14 groups mentioned below
/*	    1999-5000
		5000-9000
		9000-14000
		14000-20000
		20000-26000
		26000-34000
		34000-40000
		40000-50000
		50000-60000
		60000-70000
		70000-80000
		80000-95000
		950000-133000
		133000-214000       */

select * from smartphones where rating =0;
-- no rows left with 0

-- cleaning processors column

-- adding new column for porcessor's name
ALTER TABLE smartphones
ADD COLUMN Processor_name VARCHAR(50) AFTER processor;

-- updating the data
UPDATE smartphones s1
SET Processor_name = (
SELECT 
CASE 
	WHEN Processor_P1 LIKE '%Bionic%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Apple%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Dimensity%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Exynos%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Fusion%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Helio%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Kirin%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Qualcomm%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Snapdragon%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Sc%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Spreadtrum%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Tiger%' THEN Processor_P1
    WHEN Processor_P1 LIKE '%Unisoc%' THEN Processor_P1
    ELSE 'Not Available'
END processor_final_name
FROM (SELECT `Index`, SUBSTRING_INDEX(processor, ',', 1) AS Processor_P1
FROM smartphones) s2 
WHERE s1.`Index` = s2.`Index`);


-- cleaning minor mistakes 

-- removing unwanted spaces using trim function
UPDATE smartphones a1
SET Processor_name =
					(SELECT REPLACE(TRIM(Processor_name),'  ',' ') 
						FROM (SELECT * FROM smartphones) a2 
						WHERE a1.`Index` = a2.`Index`);
-- Apple to --> Bionic
UPDATE smartphones b1
SET Processor_name =(SELECT REPLACE(Processor_name,'Apple','Bionic') 
						FROM (SELECT * FROM smartphones) b2 
                        WHERE b1.`Index`= b2.`Index`);
-- A13 Bionic to --> Bionic A13
UPDATE smartphones p1
SET Processor_name =(SELECT REPLACE(Processor_name,'A13 Bionic','Bionic A13')
						FROM (SELECT * FROM smartphones) p2 
						WHERE p1.`Index` = p2.`Index`);
-- Qualcomm Snapdragon 670 to --> Snapdragon 670
UPDATE smartphones p1
SET Processor_name =(SELECT REPLACE(Processor_name,'Qualcomm ','') 
						FROM (SELECT * FROM smartphones) p2 
						WHERE p1.`Index` = p2.`Index`);
-- Samsung Exynos 7885 to --> Exynos 7885
UPDATE smartphones p1
SET Processor_name =(SELECT REPLACE(Processor_name,'Samsung ','') 
						FROM (SELECT * FROM smartphones) p2 
                        WHERE p1.`Index` = p2.`Index`);
-- Dimensity 8100-Max to --> Dimensity 8100 Max
UPDATE smartphones p1
SET Processor_name =(SELECT REPLACE(Processor_name,'Dimensity 8100-Max','Dimensity 8100 Max') 
                    FROM (SELECT * FROM smartphones) p2 
                    WHERE p1.`Index` = p2.`Index`);

-- Checking all 
SELECT Processor_name FROM smartphones
GROUP BY Processor_name;

SELECT * FROM smartphones;



-- Cleaning the ram column

#####
SELECT `Index`,substring_index(ram,',',1) AS RAM_1 from smartphones;

-- EXTRACTING RAM_IN_GB FROM THIS DIRTY 'ram' COLUMN
-- ADDING NEW COLUMN
ALTER TABLE smartphones
ADD COLUMN RAM_IN_GB INT AFTER ram;

UPDATE smartphones B1
SET RAM_IN_GB = (SELECT 
					CASE
						WHEN RAM_1 LIKE '1GB RAM' THEN 1
						WHEN RAM_1 LIKE '2GB RAM' THEN 2
						WHEN RAM_1 LIKE '3GB RAM' THEN 3
						WHEN RAM_1 LIKE '4GB RAM' THEN 4
						WHEN RAM_1 LIKE '6GB RAM' THEN 6
						WHEN RAM_1 LIKE '8GB RAM' THEN 8
						WHEN RAM_1 LIKE '12GB RAM' THEN 12
						WHEN RAM_1 LIKE '16GB RAM' THEN 16
						WHEN RAM_1 LIKE '18GB RAM' THEN 18
						ELSE 0
					END AS A
				FROM (SELECT * FROM (select `Index`,substring_index(ram,',',1) AS RAM_1 from smartphones) A) B2
				WHERE B2.`Index` = B1.`Index`);

-- TOTAL 37 ROWS 
select * from smartphones where RAM_IN_GB = 0;

/*    BY ANALYZING EACH ROW MANULLY I HAVE CONCLUDED THAT WE CAN FIX 4 ROWS FROM THIS DATA AND REST WILL BE DELETED BECAUSE 
THE SPECIFICATIONS ARE NOT UPTO THE MARK TO BE CALLED AS A SMARTPHONE HENCE WE CAN DELETE THISE ROWS FROM SMARTPHONES DATA  */

-- THOSE ROWS WHICH CAN BE FIXED ARE --> Index- 440,484,858

-- FIXING ALL 4 ROWS
UPDATE smartphones
SET RAM_IN_GB = 4 WHERE `Index` = 440;
UPDATE smartphones
SET RAM_IN_GB =12 WHERE `Index` = 484;
UPDATE smartphones
SET RAM_IN_GB = 1 WHERE `Index` = 858;

-- DELETING ALL OTHER ROWS WHERE RAM IS BELOW 1 GB BECAUSE IT SHOULD NOT BE CONSIDERED AS A SMARTPHONE
DELETE FROM smartphones
WHERE RAM_IN_GB = 0;

SELECT * FROM smartphones;

-- EXTRACTING ROM COLUMN FROM ram COLUMN

ALTER TABLE smartphones
ADD COLUMN ROM_IN_GB VARCHAR(20) AFTER RAM_IN_GB;

UPDATE smartphones t1
SET ROM_IN_GB = (SELECT TRIM(I) as tr FROM (SELECT `Index`,
				SUBSTRING_INDEX(SUBSTRING_INDEX(ram, ',', -1), ' ',2) AS I FROM smartphones) t2 
				WHERE t1.`Index` = t2.`Index`);

-- ANALYZING 
SELECT I FROM (SELECT `Index`,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(ram, ',', -1), ' ',2)) AS I FROM smartphones) A
    GROUP BY I;
    
-- MISTAKES FOUND
/*    1470mAh Battery
512MB
1TB
1200mAh Battery
 64GB inbuilt
512GB inbuilt */

-- extracting all the row numbers where the problem needs to be fixed --
SELECT * FROM smartphones WHERE ROM_IN_GB NOT LIKE '%GB';

-- I FOUND THAT THESE INDEX NUMBERS NEEDS TO BE FIXED - 
-- (156', '291', '440', '484', '782', '815', '858', '926', '944', '962')

-- DELETING Index NUMBER 156 BECAUSE THE DATA IS WRONG --
DELETE FROM smartphones 
WHERE `Index` = 156;

-- FIXING OTHER ROWS 
UPDATE smartphones
SET ROM_IN_GB = 1024 WHERE ROM_IN_GB = '1TB';
UPDATE smartphones
SET ROM_IN_GB = 64 WHERE ROM_IN_GB = '64GB inbuilt';
UPDATE smartphones
SET ROM_IN_GB = 512 WHERE ROM_IN_GB = '512GB inbuilt';
UPDATE smartphones
SET ROM_IN_GB = 64 WHERE ROM_IN_GB = '64GB inbuilt';
-- CONCLUDED AFTER ANALYZING MANUALLY
UPDATE smartphones
SET ROM_IN_GB = 8 WHERE ROM_IN_GB = '1470mAh Battery';

SELECT * FROM smartphones;

-- REMOVING ALL 'GB' FROM THIS COLUMN
UPDATE smartphones t1
SET ROM_IN_GB = (SELECT replace(ROM_IN_GB,'GB','') 
					FROM (SELECT * FROM smartphones) t2
					WHERE t1.`Index` = t2.`Index`);

-- MODIFYING DATATYPE OF THIS COLUMN BECAUSE NOW ALL ARE IN INT FORM
ALTER TABLE smartphones
MODIFY COLUMN ROM_IN_GB INT;


-- CLEANING BATTERY COLUMN

-- ADDING NEW COLUMN TO EXTRACT BATTERY CAPACITY OF EACH SMARTPHONES 

ALTER TABLE smartphones 
ADD COLUMN `BATTERY_CAPACITY_(mAh)` VARCHAR(100) AFTER battery;

UPDATE smartphones t1
SET `BATTERY_CAPACITY_(mAh)` = (SELECT SUBSTRING_INDEX(battery,'mAh',1) 
								FROM (SELECT * FROM smartphones) t2 
								WHERE t1.`Index`= t2.`Index`);
                               
-- ANALYSING THE DATA WHERE BATTERY CAPACITY IS NOT AVAILABLE OR WRONGLY GIVEN
select * from smartphones where `BATTERY_CAPACITY_(mAh)` NOT like '____' OR `BATTERY_CAPACITY_(mAh)` NOT like '_____';


-- THESE ARE THE INDEX NUMBERS --> (112 150 308 364 440 449 629 854 858 914 915)

UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2815 WHERE `Index` = 112;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2227 WHERE `Index` = 150;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2815 WHERE `Index` = 308;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2227 WHERE `Index` = 364;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2018 WHERE `Index` = 440;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 3274 WHERE `Index` = 449;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2815 WHERE `Index` = 629;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2815 WHERE `Index` = 854;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 1470 WHERE `Index` = 858;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2227 WHERE `Index` = 914;
UPDATE smartphones 
SET `BATTERY_CAPACITY_(mAh)` = 2815 WHERE `Index` = 915;


-- CHECKING
SELECT `BATTERY_CAPACITY_(mAh)` FROM 
smartphones 
GROUP BY `BATTERY_CAPACITY_(mAh)`;


-- NOW FIXING THE DATATYPE OF THIS COLUMN
ALTER TABLE smartphones 
MODIFY COLUMN `BATTERY_CAPACITY_(mAh)` INT;

SELECT * FROM smartphones;

-- EXTRACTING A COLUMN FOR FAST_CHARGING FROM COLUMN--> 'battery'
SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(battery,'W',1),' ',-1) I FROM smartphones;

-- PROBLEMS
/*Charging
Battery
Notch
Display
Hole
22.5
68.2*/

-- EXTRACTING FAST CHARGING FROM BATTERY COLUMN
ALTER TABLE smartphones
ADD COLUMN FAST_CHARGING_SPEED VARCHAR(20) AFTER `BATTERY_CAPACITY_(mAh)`;

-- cleaning and extracting the charging-speed from the battery column by using the available data
UPDATE smartphones t1
SET FAST_CHARGING_SPEED = (SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(battery,'W',1),' ',-1) I 
						   FROM (SELECT * FROM smartphones) t2 
                           WHERE t1.`Index` = t2.`Index`);

-- Analysing the data where charging speed is not available
SELECT * FROM smartphones WHERE FAST_CHARGING_SPEED NOT LIKE '___' AND FAST_CHARGING_SPEED NOT LIKE '__';
-- 218 no of rows are missing
                           
/*  Extracted those 218 columns using Gemini A.I by putting the model name of smartphones
		( which I found by using the query mentioned above ) to get 
    real time data form the internet for those missing smartphone's charging speed     */
  
-- imported that data with the name of smartphones_charging
/* Now performing update and inner-join to update the main smartphones table by matching the data from both the tables 
so that it will only affect those rows where the data was not available before the pre-cleaning process of this column */
set sql_safe_updates =0;
UPDATE smartphones t1
JOIN smartphones_charging t2 ON t1.model = t2.Model_name
SET t1.FAST_CHARGING_SPEED = t2.Charging_speed;


-- even after updating there are still ( 111 ) rows where data is still missing/ Not found
select * from smartphones;

-- cleaning display column
-- extracting display size

select * from (select *,substring_index(display,'inches',1) size from smartphones) a where size like '%MP%';

ALTER TABLE smartphones 
ADD COLUMN DISPLAY_IN_INCHES VARCHAR(70) AFTER display;

ALTER TABLE smartphones 
DROP COLUMN DISPLAY_IN_INCHES;

SET SQL_SAFE_UPDATES=0;
UPDATE smartphones T1
SET DISPLAY_IN_INCHES=
(select substring_index(display,'inches',1) size from (SELECT * FROM smartphones) T2 WHERE T1.`Index` = T2.`Index`);

SELECT * FROM smartphones where DISPLAY_IN_INCHES like '%MP%';

UPDATE smartphones T1
JOIN 
(SELECT `Index`,SUBSTRING_INDEX(battery,'inches',1) SIZE from smartphones
where DISPLAY_IN_INCHES like '%MP%') T2 ON T1.`Index` = T2.`Index`
SET T1.DISPLAY_IN_INCHES = T2.SIZE;

SELECT DISPLAY_IN_INCHES FROM smartphones GROUP BY DISPLAY_IN_INCHES;

ALTER TABLE smartphones
MODIFY COLUMN DISPLAY_IN_INCHES DECIMAL(3,2);

SELECT * FROM smartphones;

-- EXTRACTING PIXLES IN WIDTH

SELECT * FROM (SELECT `Index`,SUBSTRING_INDEX(SUBSTRING_INDEX(display,'x',1),' ',-1) A FROM smartphones) T5;

ALTER TABLE smartphones
ADD COLUMN PIXLES_IN_WIDTH VARCHAR(50) AFTER DISPLAY_IN_INCHES;

UPDATE smartphones t1
SET PIXLES_IN_WIDTH =
(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(display,'x',1),' ',-1) A FROM (SELECT * FROM smartphones) t2 
WHERE t1.`Index`= t2.`Index`);

SELECT * FROM smartphones WHERE PIXLES_IN_WIDTH = 'Camera';

UPDATE smartphones T1
RIGHT JOIN 
(SELECT `Index`,SUBSTRING_INDEX(SUBSTRING_INDEX(battery,'x',1),' ',-1) SIZE_ FROM smartphones WHERE PIXLES_IN_WIDTH = 'Camera') T2 
ON T1.`Index` = T2.`Index`
SET PIXLES_IN_WIDTH = SIZE_;

ALTER TABLE smartphones
MODIFY COLUMN PIXLES_IN_WIDTH INTEGER;

-- EXTRACTING PIXLES IN HEIGHT

SELECT * FROM (SELECT `Index`,SUBSTRING_INDEX(SUBSTRING_INDEX(display,'px',1),'x',-1) A FROM smartphones) T5;

ALTER TABLE smartphones
ADD COLUMN PIXLES_IN_HEIGHT VARCHAR(50) AFTER PIXLES_IN_WIDTH;

UPDATE smartphones t1
SET PIXLES_IN_HEIGHT =
(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(display,'px',1),'x',-1) A FROM (SELECT * FROM smartphones) t2 
WHERE t1.`Index`= t2.`Index`);

SELECT * FROM smartphones WHERE PIXLES_IN_HEIGHT LIKE '%MP%';

UPDATE smartphones T1
RIGHT JOIN 
(SELECT `Index`,SUBSTRING_INDEX(SUBSTRING_INDEX(battery,'px',1),'x',-1) SIZE_H FROM smartphones 
WHERE PIXLES_IN_HEIGHT LIKE '%MP%') T2 
ON T1.`Index` = T2.`Index`
SET PIXLES_IN_HEIGHT = SIZE_H;

SELECT * FROM smartphones ;

ALTER TABLE smartphones
MODIFY COLUMN PIXLES_IN_HEIGHT INTEGER;

SELECT * FROM smartphones;

-- EXTRACTING REFRESH_RATE FROM DISPLAY COLUMN

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(display,'Hz',1),'x, ',-1) FROM smartphones;

ALTER TABLE smartphones 
ADD COLUMN REFRESH_RATE_IN_HZ VARCHAR(100) AFTER PIXLES_IN_HEIGHT;

SET SQL_SAFE_UPDATES = 0;
UPDATE smartphones t1
SET REFRESH_RATE_IN_HZ =
(SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(display,'Hz',1),'x, ',-1)) FROM (SELECT * FROM smartphones) t2
WHERE t1.`Index` = t2.`Index`);

SELECT * FROM smartphones WHERE REFRESH_RATE_IN_HZ NOT LIKE '___' AND REFRESH_RATE_IN_HZ NOT LIKE '__';

-- imported data of 370 missing refreshrate rows which is extracted by 
-- using gemini to get the access of real time data
UPDATE smartphones t1
join smartphones_refreshrate t2
ON `Phone Model` = model
SET REFRESH_RATE_IN_HZ = `Refresh Rate (Hz)`;

-- data for 270 rows is still not available

-- changing datatype from varchar to int because all of the are now integers
ALTER TABLE smartphones
MODIFY COLUMN REFRESH_RATE_IN_HZ INT;

select * from smartphones where `os` like '%Memory%';

select os from smartphones
group by os;

-- CLEANING THE CAMERA COLUMN
-- Extracting rare camera data from card column
ALTER TABLE smartphones
ADD COLUMN REAR_CAMERA VARCHAR(100) AFTER Camera;

ALTER TABLE smartphones
drop COLUMN REAR_CAMERA;

SELECT cam FROM (select SUBSTRING_INDEX(camera,'Rear',1) CAM from smartphones) a group by cam
;

UPDATE smartphones
SET REAR_CAMERA = SUBSTRING_INDEX(camera,'Rear',1);

select replace(REAR_CAMERA,'Triple','') from smartphones;


UPDATE smartphones
SET REAR_CAMERA = REPLACE(REAR_CAMERA,'Triple','');
UPDATE smartphones
SET REAR_CAMERA = REPLACE(REAR_CAMERA,'Dual','');
UPDATE smartphones
SET REAR_CAMERA = REPLACE(REAR_CAMERA,'Quad','');


-- Analyzing the remaining problems
SELECT REAR_CAMERA FROM smartphones
group by REAR_CAMERA;

-- PROBLEMS FOUND
/* Foldable Display,  Display
	Foldable Display
	Memory Card Not Supported
	 Display
	Memory Card Supported          */

-- fixing those issues 
UPDATE smartphones
SET REAR_CAMERA = NULL WHERE REAR_CAMERA = 'Foldable Display,  Display' OR
REAR_CAMERA = 'Foldable Display' OR REAR_CAMERA = 'Memory Card Not Supported'
OR REAR_CAMERA = ' Display' OR REAR_CAMERA = 'Memory Card Supported';

-- Analyzing 
SELECT REAR_CAMERA FROM SMARTPHONES GROUP BY REAR_CAMERA;

SELECT * FROM smartphones where REAR_CAMERA IS NULL;

SELECT REAR_CAM FROM (SELECT SUBSTRING_INDEX(camera,'&',1) REAR_CAM FROM smartphones) A1
GROUP BY REAR_CAM;

-- ISSUES FOUND 
/*      Foldable Display, Dual Display
		Foldable Display
		Memory Card Not Supported
		Dual Display
		Memory Card Supported           */

-- FILLING ALL THE VALUES OF RARE CAMERA
UPDATE smartphones T2
JOIN 
(SELECT `Index`,substring_index(CARD,'&',1) CAM FROM 
		(SELECT * FROM SMARTPHONES WHERE REAR_CAMERA IS NULL) A) T1
        ON T1.`Index` = T2.`Index`
SET REAR_CAMERA = CAM;

-- ANALYZING THE ISSUES
SELECT * FROM SMARTPHONES WHERE REAR_CAMERA LIKE '%Rear%' OR
REAR_CAMERA LIKE '%iOS%' OR REAR_CAMERA LIKE '%BLUETOOTH%';
-- Issues found
	-- Issues that can be fixed
	/*   Quard Rear
		 Quard Rear Camera
		 Triple Rear
		 Dual Rear  
		 Rear            */         
	-- Issues that needs to be removed
    /*   Bluetooth
		 iOS    		 */
-- FIXING THOSE ISSUES
UPDATE smartphones
SET REAR_CAMERA = REPLACE(REAR_CAMERA,'Triple Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Dual Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Quad Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Quad Rear Camera',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Rear','');

-- Removing rest of them
UPDATE smartphones 
SET REAR_CAMERA = NULL WHERE REAR_CAMERA LIKE '%iOS%' OR REAR_CAMERA LIKE '%Bluetooth%';

-- ANALYZING AGAIN
SELECT * FROM SMARTPHONES WHERE REAR_CAMERA IS NULL;
-- ISSUES FOUND 
-- THE DATA OF THESE 11 ROWS ARE GIVEN IN DISPLAY COLUMN
UPDATE smartphones 
SET REAR_CAMERA =  SUBSTRING_INDEX(display,'&',1) WHERE REAR_CAMERA IS NULL;

-- ANALYZING THE NEW 11 DIRTY ROWS
SELECT * FROM SMARTPHONES WHERE REAR_CAMERA LIKE '%Rear%';
-- problems found
/*  Dual Rear
	Rear
	Triple Rear
    Rear Camera  
    Camera
    Triple       */
-- CLEANING THOSE 11 ROWS 
UPDATE smartphones
SET REAR_CAMERA = REPLACE(REAR_CAMERA,'Dual Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Triple Rear',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Rear Camera',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Triple',''),
REAR_CAMERA = REPLACE(REAR_CAMERA,'Camera','');

select REAR_CAMERA from smartphones GROUP BY REAR_CAMERA;
-- FIXED THIS WHOLE BY EXTRACTING DATA FROM VARIOUS COLUMNS

SELECT * FROM SMARTPHONES;

-- EXTRACTING FRONT CAMERA DATA FROM CAMERA COLUMN
ALTER TABLE smartphones 
ADD COLUMN FRONT_CAMERA VARCHAR(100) AFTER REAR_CAMERA;

UPDATE smartphones
SET FRONT_CAMERA = SUBSTRING_INDEX(camera,'&',-1);

-- ANALYZING THE ISSUES
SELECT FRONT_CAMERA FROM smartphones GROUP BY FRONT_CAMERA;
-- ISSUES FOUND
	/*  Foldable Display, Dual Display
		Foldable Display
		Memory Card Not Supported
		Dual Display
		Memory Card Supported     */

-- FIXING THE ISSUES
UPDATE smartphones
SET FRONT_CAMERA = NULL WHERE FRONT_CAMERA NOT LIKE '%MP%';

-- EXTRACTING DATA OF FRONT CAMERA FROM CARD COLUMN BECAUSE IT IS SHIFTED IN THAT COLUMN
UPDATE smartphones
SET FRONT_CAMERA = SUBSTRING_INDEX(card,'&',-1) 
WHERE card LIKE '%Front Camera%';

SELECT * FROM smartphones WHERE FRONT_CAMERA IS NULL;

/*  FEW DATA IS PRESENT IN DISPLAY COLUMN ALSO HENCE THE DATA 
	CLEANING PROCESS IS MULTIPLE COLUMN IN THIS CASE  */
UPDATE smartphones
SET FRONT_CAMERA = SUBSTRING_INDEX(display,'&',-1) 
WHERE display LIKE '%Front Camera%';

-- ANALYZING THE FALUTY ROWS
SELECT FRONT_CAMERA FROM smartphones GROUP BY FRONT_CAMERA;

-- CORRECTING MINOR MISTAKES
UPDATE smartphones
SET FRONT_CAMERA = NULL 
WHERE FRONT_CAMERA LIKE '%Rear%';

/*  REMOVING 'Front Camera' AND 'Dual' WORDS FROM FRONT_CAMERA COLUMN 
	HENCE THE MEGAPIXELS WILL BE VISIBLE ONLY IN THIS COLUMN    */
select * from smartphones;
UPDATE smartphones
SET FRONT_CAMERA = REPLACE(REPLACE(FRONT_CAMERA,'Front Camera',''),'Dual','');

-- CLENING THE CARD COLUMN
-- ADDING NEW COLUMN
ALTER TABLE smartphones
ADD COLUMN MEMORY_CARD VARCHAR(100) AFTER card;

SET SQL_SAFE_UPDATES = 0;
UPDATE smartphones
SET MEMORY_CARD = card WHERE card LIKE'%Memory Card%';

/*  Memory Card Not Supported
	Memory Card (Hybrid), upto 1TB
	Memory Card Supported, upto 1TB
	Memory Card Supported
	Memory Card (Hybrid)
	Memory Card Supported, upto 512GB
	Memory Card Supported, upto 256GB
	Memory Card Supported, upto 2TB
	Memory Card Supported, upto 128GB
	Memory Card (Hybrid), upto 256GB
	Memory Card (Hybrid), upto 128GB
	Memory Card (Hybrid), upto 512GB
	Memory Card Supported, upto 32GB
	Memory Card (Hybrid), upto 64GB
	Memory Card Supported, upto 1000GB
	Memory Card (Hybrid), upto 2TB      */

-- ANALYZING THOSE ROWS WHERE THE VALUE IS NULL TO FIND DATA PRESENT IN OTHER COLUMNS
SELECT * FROM smartphones WHERE MEMORY_CARD IS NULL;

UPDATE smartphones
SET MEMORY_CARD = os WHERE os LIKE '%Memory Card%';

-- REST OF THE DATA IS NOT AVAILABLE
UPDATE smartphones
SET MEMORY_CARD = 'NOT AVAILABLE' WHERE MEMORY_CARD IS NULL;

-- CLEANING THE 'os' COLUMN
-- ADDING NEW COLUMN AND EXTRACTING DATA FROM 'os' COLUMN
ALTER TABLE smartphones
ADD COLUMN OPERATING_SYSTEM VARCHAR(40) AFTER os;

UPDATE smartphones
SET OPERATING_SYSTEM = os WHERE os LIKE '%Android%' OR 
os LIKE '%iOS%' OR 
os LIKE '%Harmony%' OR 
os LIKE '%Hongmeng%' OR 
os LIKE '%Pragati%' OR 
os LIKE '%EMUI%';

-- ANALYZING THE NULL ROWS 
SELECT * FROM smartphones WHERE OPERATING_SYSTEM IS NULL;
-- FOUND THAT MOST OF THE MISSING OPERATING SYSTEM DATA IS PRESENT IN CARD COLUMN

-- UPDATING THE DATA FROM CARD COLUMN
UPDATE smartphones
SET OPERATING_SYSTEM = card 
WHERE card LIKE '%Android%' OR card LIKE '%iOS%' OR card LIKE '%Harmony%';

SELECT * FROM smartphones WHERE OPERATING_SYSTEM IS NULL;

-- STILL 15 ROWS ARE MISSING
-- SEARCHED AND EXTRACTED ALL THE DATA BY THEIR MODEL NAMES USING GEMINI TO FIND OS THROUGH THE INTERNET

-- updating the data by matching them based on their model names 
UPDATE smartphones T1
JOIN
(SELECT * FROM OS_DATA) T2
ON T2.`Phone Model` = T1.model
SET OPERATING_SYSTEM = `Operating System`;

-- all the data off all the columns is cleaned hence i am creating a new table
-- which will only contain the cleaned columns

SELECT * FROM SMARTPHONES;

-- ADDING ALL THE CLEANED DATA TO A NEW TABLE 
CREATE TABLE SMARTPHONES_CLEANED AS
(SELECT `Index`, brand_name, model, price, rating, `5g_Available`, Processor_name,RAM_IN_GB, ROM_IN_GB, `BATTERY_CAPACITY_(mAh)`,FAST_CHARGING_SPEED, DISPLAY_IN_INCHES, PIXLES_IN_WIDTH, PIXLES_IN_HEIGHT, REFRESH_RATE_IN_HZ,REAR_CAMERA, FRONT_CAMERA,MEMORY_CARD,OPERATING_SYSTEM FROM smartphones);
