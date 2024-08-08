USE data;
-- lets see how our data looks
SELECT * FROM laptopdata;

-- LETS TAKE THE BACKUP OF THE BEFORE OPERATING OVER IT
CREATE TABLE lapback LIKE laptopdata;
INSERT INTO lapback
SELECT * FROM laptopdata;

SELECT * FROM lapback;

-- ITS ESSENTIAL TO DROP NON USEFUL COLUMNS AT START
-- but here this column can act as index column hence renaming is better option
ALTER TABLE laptopdata DROP COLUMN `Unnamed: 0`;


-- its essential to check for null row and remove if exists
SELECT * FROM laptopdata
WHERE `Company` IS NULL AND `TypeName` IS NULL AND 
`Inches` IS NULL AND `ScreenResolution` IS NULL AND 
`Cpu` IS NULL AND `Ram` IS NULL AND `Memory` IS NULL AND 
`Gpu` IS NULL AND `OpSys` IS NULL AND `Weight` IS NULL AND 
`Price` IS NULL;
-- HERE THERE ARE NO DUPLICATES HENCE NO NEED TO DELETE ANY ROW

SELECT * FROM laptopdata;
-- HERE EVEN AFTER CHECKING FOR NULL values
-- WE STILL HAVE GOT FEW ROWS WHERE EITHER ANY 1 OR 2 COLUMNS
-- CONTAIN INVALID VALUE HENCVE THEY ARE USELESS TO BE OPRTATED UPON
-- HENCE ITS ESSENTIAL TO REMOVE THEM


-- NOW LETS CONSIDER EACH COLUMNS AND CHECK FOR WHAT NEEDS TO BE DONE
SELECT DISTINCT(Company) FROM laptopdata;
-- there are few null values we could check TYPENAME column if it
-- contains the data to fill
-- before that lets alot an index using ro_number function
ALTER TABLE laptopdata ADD COLUMN `id` INT FIRST;

-- this code is for the mistake i did by droping the column unnamed
-- thans to the backup i could make a new id column now
UPDATE laptopdata t
JOIN lapback t1
ON t1.Company = t.Company
AND t1.TypeName = t.TypeName AND t1.Inches = t.Inches
AND t1.ScreenResolution = t.ScreenResolution
AND t1.Cpu = t.Cpu AND t1.Ram = t.Ram
AND t1.Memory = t.Memory AND t1.Gpu = t.Gpu
AND t1.OpSys = t.OpSys AND t1.Weight = t.Weight
AND t1.Price = t.Price
SET t.id = t1.`Unnamed: 0`;
SELECT * FROM laptopdata;

-- NOW LETS CONSIDER EACH COLUMNS AND CHECK FOR WHAT NEEDS TO BE DONE
SELECT DISTINCT(Company) FROM laptopdata;
-- there are few null values we could check TYPENAME column if it
-- contains the data to fill
SELECT Company,COUNT(*) FROM laptopdata
GROUP BY Company;
SELECT * FROM laptopdata WHERE id IN(SELECT id FROM laptopdata WHERE Company='');
-- Here we could observe that both Company , TypeName are wmpty alongside much of values
-- hence its optimal to drop these rows
DELETE FROM laptopdata WHERE Company='';
SELECT DISTINCT(Company) FROM laptopdata;

-- here we are updating ram column by keeping only numerical value maikng it int type
UPDATE laptopdata l1
JOIN  laptopdata l2
ON l1.id=l2.id
SET l1.Ram=REPLACE(l2.Ram,'GB','');
-- now we can change the type of the column
ALTER TABLE laptopdata MODIFY COLUMN Ram INT;

-- now updating weight column
UPDATE laptopdata l1
JOIN  laptopdata l2
ON l1.id=l2.id
SET l1.Weight=REPLACE(l2.Weight,'kg','');
ALTER TABLE laptopdata MODIFY COLUMN Weight INT;

-- code to check memory space
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
 WHERE TABLE_SCHEMA='data'
 AND TABLE_NAME ='laptopdata';
 
SELECT DATA_LENGTH/1024 FROM information_schema.TABLES
 WHERE TABLE_SCHEMA='data'
 AND TABLE_NAME ='lapback';
 
SELECT * FROM laptopdata;
-- here am trying to convert float value of price to int
UPDATE laptopdata l1 
JOIN laptopdata l2 
ON l2.id = l1.id
SET l1.Price = (SELECT ROUND(l2.Price));
ALTER TABLE laptopdata MODIFY COLUMN Price INTEGER;
SELECT * FROM laptopdata;



-- here am trying to minimise the categories of operating system
SELECT DISTINCT OpSys FROM laptopdata;
SELECT OpSys,CASE
	 WHEN OpSys LIKE '%mac%' THEN 'macos'
	 WHEN OpSys LIKE 'windows%' THEN 'windows'
	 WHEN OpSys LIKE '%linux%' THEN 'linux'
	 WHEN OpSys='No OS' THEN 'N/A'
	 ELSE 'other'
 END AS'operating_sys'
 FROM laptopdata;
-- Now lets update these values with OsSys
UPDATE laptopdata l1 JOIN (SELECT id,CASE
	 WHEN OpSys LIKE '%mac%' THEN 'macos'
	 WHEN OpSys LIKE 'windows%' THEN 'windows'
	 WHEN OpSys LIKE '%linux%' THEN 'linux'
	 WHEN OpSys='No OS' THEN 'N/A'
	 ELSE 'other'
 END AS'operating_sys'
 FROM laptopdata) l2
ON l1.id=l2.id
SET l1.OpSys=l2.operating_sys;
SELECT DISTINCT(OpSys) FROM laptopdata;

-- NOW LETS DIVIDE gpu column further for easy classification
ALTER TABLE laptopdata
 ADD COLUMN cpu_brand VARCHAR(255) AFTER `Cpu`,
 ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,
 ADD COLUMN cpu_speed DECIMAL(10,1) AFTER cpu_name;

UPDATE laptopdata l1 
JOIN (SELECT id,SUBSTRING_INDEX(Cpu," ",1) AS 'SUB' FROM laptopdata)l2
ON l1.id=l2.id
SET cpu_brand=l2.SUB;
SELECT * FROM laptopdata;
 
-- similarly updating other two columns
UPDATE laptopdata l1 
JOIN (SELECT id,REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','')AS 'H' FROM laptopdata)l2
ON l2.id = l1.id
SET l1.cpu_speed =l2.H;

UPDATE laptopdata l1 
JOIN (SELECT id,TRIM(REPLACE(REPLACE(REPLACE(Cpu,cpu_brand,""),CPU_SPEED,''),'GHz',''))
AS 'FINALLY' FROM laptopdata)l2
ON l2.id = l1.id
SET cpu_name = FINALLY ;
SELECT * FROM laptopdata;

SELECT DISTINCT(ScreenResolution) FROM laptopdata;

ALTER TABLE laptopdata
 ADD COLUMN resolution_width INTEGER AFTER ScreenResolution,
 ADD COLUMN resolution_height INTEGER AFTER resolution_width;

UPDATE laptopdata
 SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),
 resolution_height = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1); 
 
ALTER TABLE laptopdata
ADD COLUMN touchscreen INTEGER AFTER resolution_height,
ADD COLUMN screentype VARCHAR(225) AFTER resolution_height;

UPDATE laptopdata
SET touchscreen = CASE 
    WHEN ScreenResolution LIKE '%Touch%' THEN 'Yes'
    ELSE 'No'
END;

UPDATE laptopdata
SET screentype = CASE
    WHEN ScreenResolution = '2560x1600' THEN 'WQXGA'
    WHEN ScreenResolution = '1440x900' THEN 'WXGA+'
    WHEN ScreenResolution = '1920x1080' THEN 'Full HD'
    WHEN ScreenResolution = '2880x1800' THEN 'Retina Display'
    WHEN ScreenResolution = '1366x768' THEN 'HD'
    WHEN ScreenResolution = '2304x1440' THEN 'QHD+'
    WHEN ScreenResolution = '3200x1800' THEN 'QHD+'
    WHEN ScreenResolution = '2256x1504' THEN 'QHD'
    WHEN ScreenResolution = '3840x2160' THEN '4K UHD'
    WHEN ScreenResolution = '2160x1440' THEN 'QHD'
    WHEN ScreenResolution = '1600x900' THEN 'HD+'
    WHEN ScreenResolution = '2560x1440' THEN 'QHD'
    WHEN ScreenResolution = '2736x1824' THEN 'QHD+'
    WHEN ScreenResolution = '2400x1600' THEN 'WQXGA'
    WHEN ScreenResolution = '1920x1200' THEN 'WUXGA'
    ELSE 'Other'
END;

SELECT * FROM laptopdata;
SELECT DISTINCT(ScreenResolution) FROM laptopdata;

ALTER TABLE laptopdata
ADD COLUMN memory_type VARCHAR(255) AFTER Memory,
ADD COLUMN primary_storage INTEGER AFTER memory_type,
ADD COLUMN secondary_storage INTEGER AFTER primary_storage;
 
UPDATE laptopdata
 SET memory_type = CASE
 WHEN Memory LIKE '%SSD%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
 WHEN Memory LIKE '%SSD%' THEN 'SSD'
 WHEN Memory LIKE '%HDD%' THEN 'HDD'
 WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
 WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
 WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
 ELSE NULL
 END;
 
UPDATE laptopdata
SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',1),'[0-9]+'),
secondary_storage = CASE WHEN Memory LIKE '%+%' THEN
REGEXP_SUBSTR(SUBSTRING_INDEX(Memory,'+',-1),'[0-9]+') ELSE 0 END;

SELECT * FROM laptopdata; 

UPDATE laptopdata
 SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage*1024 ELSE
 primary_storage END,
 secondary_storage = CASE WHEN secondary_storage <= 2 THEN secondary_storage*1024
 ELSE secondary_storage END;
 
 ALTER TABLE laptopdata
 ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,
 ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;
 
 SELECT * FROM laptopdata;
 
UPDATE laptopdata
SET gpu_brand = SUBSTRING_INDEX(Gpu, ' ', 1);

UPDATE laptopdata
 SET gpu_name =REPLACE(Gpu,gpu_brand,'');
 
SELECT * FROM laptopdata;

ALTER TABLE laptopdata
DROP COLUMN ScreenResolution,
DROP COLUMN `Cpu`,
DROP COLUMN `Memory`,
DROP COLUMN Gpu;

SELECT * FROM laptopdata;