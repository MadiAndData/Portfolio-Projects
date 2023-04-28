SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing



-- Standardize the Date Format

SELECT
	SaleDate, CONVERT(Date,SaleDate)
FROM ProjectPortfolio.dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);



-- Populate Property Address data

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL;


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
ORDER BY ParcelID;

SELECT 
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL;


-- Separating Address into Individual Columns (Address, City)

SELECT PropertyAddress
FROM ProjectPortfolio.dbo.NashvilleHousing;

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM ProjectPortfolio.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)); 

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvilleHousing;

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM ProjectPortfolio.dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1);


-- Set Y and N to Yes and No in "Sold as Vacant" field

SELECT
	DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   ELSE SoldAsVacant
					   END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   ELSE SoldAsVacant
					   END


-- Removing Duplicates

WITH RowNumCTE AS(
SELECT
	*, ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM ProjectPortfolio.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Deleting Unused Columns

SELECT*
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress, SaleDate