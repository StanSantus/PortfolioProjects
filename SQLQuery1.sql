SELECT *
FROM PortfolioProject.dbo.nashville_housing

-- Change Date Format - ALTER TABLE, UPDATE, CONVERT

SELECT SaleDate, CONVERT(date, SaleDate), saledate2
FROM PortfolioProject.dbo.nashville_housing



ALTER TABLE nashville_housing
ADD SaleDate2 date;

UPDATE PortfolioProject.dbo.nashville_housing
SET SaleDate2 = CONVERT(date, SaleDate);


-------------------------------------------------------------------------------------------------------------------------------------------------
-- Clean Property Adress. - JOIN, ISNULL, UPADTE with a JOIN

SELECT A.ParcelID, A.Propertyaddress, B.PropertyAddress, ISNULL(A.Propertyaddress, B.PropertyAddress) AS ISNULL
FROM PortfolioProject.dbo.nashville_housing AS A
JOIN PortfolioProject.dbo.nashville_housing AS B
	ON A.ParcelID=B.ParcelID
WHERE A.Propertyaddress IS NULL AND B.Propertyaddress IS NOT NULL

UPDATE A
SET PropertyAddress = ISNULL(A.Propertyaddress, B.PropertyAddress)
FROM PortfolioProject.dbo.nashville_housing AS A
JOIN PortfolioProject.dbo.nashville_housing AS B
	ON A.ParcelID=B.ParcelID
WHERE A.Propertyaddress IS NULL AND B.Propertyaddress IS NOT NULL

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Dividing Address Column (Adress, City, State) using SUBSTRING, CHARINDEX, LEN

SELECT PropertyAddress
FROM PortfolioProject.dbo.nashville_housing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS ADRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) AS City
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE nashville_housing
ADD property_street nvarchar(255);

UPDATE PortfolioProject.dbo.nashville_housing
SET property_street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE nashville_housing
ADD property_city nvarchar(255);

ALTER TABLE PortfolioProject.dbo.nashville_housing
ALTER COLUMN owner_state nvarchar(255);


UPDATE PortfolioProject.dbo.nashville_housing
SET property_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress));

-------------------------------------------------------------------------------------------------------------------------------------------------
-- OWNER ADDRESS using PARCENAME

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE PortfolioProject.dbo.nashville_housing
ADD owner_state nvarchar(2);

UPDATE PortfolioProject.dbo.nashville_housing
SET owner_street = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3);

UPDATE PortfolioProject.dbo.nashville_housing
SET owner_city = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2);

UPDATE PortfolioProject.dbo.nashville_housing
SET owner_state = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1);

-------------------------------------------------------------------------------------------------------------------------------------------------
-- Clean Sold As Vacant Column using CASE

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.nashville_housing
GROUP BY SoldAsVacant


SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.nashville_housing


UPDATE PortfolioProject.dbo.nashville_housing
SET 	SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.nashville_housing;

-------------------------------------------------------------------------------------------------------------------------------------------------
--Revome Duplicates using ROW_NUMBER, PARTITION BY

WITH rownumber
AS
(
	SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
						PropertyAddress,
						SaleDate,
						SalePrice,
						LegalReference
						ORDER BY
						UniqueID
						) row_number
	
	FROM PortfolioProject.dbo.nashville_housing
)
Delete *
FROM rownumber
WHERE row_number > 1

-------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETE COLUMNS

SELECT *
FROM PortfolioProject.dbo.nashville_housing

ALTER TABLE PortfolioProject.dbo.nashville_housing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress