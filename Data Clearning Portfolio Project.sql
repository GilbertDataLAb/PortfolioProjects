/*

Cleaning Data in SQL queries

*/

SELECT *
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)


-- If it doesn't update properly here's an alternative

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

-- Check if alternative works (If it work the 2nd column and 3rd column will have the same value)
SELECT SaleDate, CONVERT(DATE, SaleDate), SaleDateConverted
From PortfolioProject..NashvilleHousing



----------------------------------------------------------------------------------------------

-- Populate Property Address Data
-- Used Self Join Technique to populate missing address data

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



----------------------------------------------------------------------------------------------

-- Breaking out Address	into Individual Columns (Address, City, State)

-- Use of SUBSTRING
-- (Address, City)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
ADD SplitCity nvarchar(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Renamed SplitCity to PropertySplitCity to not confuse Property and Owner Splits

EXEC sp_rename 'NashvilleHousing.PropertySlipCity', 'PropertySplitCity', 'COLUMN';

Select *
From PortfolioProject..NashvilleHousing


-- Use of PARSENAME
-- (Address, City, State)

SELECT Owneraddress
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field using CASE Statement

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS TotalSoldAsVacant
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET	SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumberCTE AS (
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
FROM PortfolioProject..NashvilleHousing
)

DELETE
FROM RowNumberCTE
WHERE row_num > 1

-- "To check if there are still duplicates, comment out the 'DELETE' statement and uncomment the 'SELECT' statement."
--SELECT *
--FROM RowNumberCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing