--CLEANING DATA IN SQL QUERIES

--Standardize Data Format
SELECT 
	SaleDateConverted, 
	Convert(date, SaleDate)
FROM NashvilleHousing

--Update NashvilleHousing table columns
ALTER TABLE NashvilleHousing
ADD SaleDateconverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)

--Populate property Address Data
SELECT 
	*
FROM NashvilleHousing
WHERE propertyaddress IS NULL
ORDER BY parcelid

SELECT 
	a.ParcelID, 
	a.PropertyAddress, 
	b.ParcelID, 
	b.PropertyAddress, 
	isnull(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyADdress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

	
--Breaking out address into individual columns (address, city, state)

--Property Address
	
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress  nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity  nvarchar(255);

UPDATE nashvillehousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Owner Address
SELECT OwnerAddress FROM NashvilleHousing

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 3), 
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 2), 
	PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress  nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity  nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState  nvarchar(255);

UPDATE nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT 
	DISTINCT(SoldAsVacant), 
	COUNT(soldasvacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant,  
	CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
		END



--Remove Duplicates

WITH RowNumCTE AS 
(
	SELECT *,
		ROW_NUMBER() OVER
			(PARTITION BY 
				ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
			ORDER BY UniqueID
			) AS row_num
	FROM NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1



--Delete Unused Columns

SELECT * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate



