/*

Cleaning Data in SQL Queries by GANIYAT ISSA-ONILU
Dataset used: Nashville Housing Data (publicly available)
*/

-- CSV file was imported to the database and loaded as SQL table
--------------------------------------------------------------------------------------------------------------------------

-- View all the rows in the data
Select * from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT: change date column into the appropriate format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
from NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS: FILL NULL VALUES WITH APPROPRIATE ADDRESS
Select PropertyAddress
from NashvilleHousing

Select *
from NashvilleHousing
order by ParcelID
-- Note: Sales with the same Parcel IDs have the same Address, hence fill address using same Parcel ID

--Check for null property address and update with correct address using ISNULL
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- SPLIT ADDRESS COLUMNS (PropertyAddress and OwnerAddress) into (Address, City, State)

--SPLIT PropertyAddress USING SUBSTRING AND CHARINDEX
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from NashvilleHousing

-- UPDATE TABLE WITH NEW COLUMNS FOR Address and City (PropertyAddress)
ALTER TABLE NashvilleHousing
ADD PropertyAddressClean nvarchar(255)

UPDATE NashvilleHousing
set PropertyAddressClean = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(255)

UPDATE NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

-- SPLIT OwnerAddress into Address, City and State using PARSENAME

-- Note: replace comma(,) with fullstop (.) to use PARSENAME
Select OwnerAddress from NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

--UPDATE TABLE with 3 new columns for Owner Address, City and State
ALTER TABLE NashvilleHousing
ADD OwnerAddressClean nvarchar(255)

UPDATE NashvilleHousing
set OwnerAddressClean = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity nvarchar(255)

UPDATE NashvilleHousing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState nvarchar(255)

UPDATE NashvilleHousing
set OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHANGE Y and N TO Yes AND No IN "SoldAsVacant" column

--Check for distinct values in SoldAsVacant
Select Distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- Use CASE statement to replace 'Y' and 'N' with 'Yes' and 'No' correspondingly
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashvilleHousing

-- UPDATE TABLE with right naming
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES USING CTE 

-- USE ROW_NUMBER() AND PARTTITION BY TO CHECK FOR DUPLICATES
--Note: ParcelID, PropertyAddress, SalePrice and LegalReference fields were used to check for duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
			) row_num
From NashvilleHousing
)

Delete from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS
 -- Drop unnecessary columns after data cleaning

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress,SaleDateConverted
















