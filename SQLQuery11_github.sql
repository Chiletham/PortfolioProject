SELECT * 
FROM PortfolioProject..NasvileHousing

--- Sale Date 
SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NasvileHousing

UPDATE NasvileHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NasvileHousing 
Add SaleDateConverted  Date

UPDATE NasvileHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)



----Property Address
SELECT *
FROM PortfolioProject..NasvileHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

--SELF JOIN
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NasvileHousing A
JOIN PortfolioProject..NasvileHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NasvileHousing A
JOIN PortfolioProject..NasvileHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


SELECT PropertyAddress
FROM PortfolioProject..NasvileHousing

---SUBSTRING
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress)+1, len(PropertyAddress)) as Address
FROM PortfolioProject..NasvileHousing


ALTER TABLE NasvileHousing 
Add PropertySplitAddress  NVARCHAR(255);

UPDATE NasvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1)

ALTER TABLE NasvileHousing 
Add PropertySplitCity  NVARCHAR(255);

UPDATE NasvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress)+1, len(PropertyAddress))


SELECT *
FROM PortfolioProject..NasvileHousing







------ OWNER ADDRESS
SELECT OwnerAddress
FROM PortfolioProject..NasvileHousing

--USING PARSE NAME TO SPLIT ITEMS 
SELECT 
PARSENAME(replace (OwnerAddress, ',', '.'),3),
PARSENAME(replace (OwnerAddress, ',', '.'),2),
PARSENAME(replace (OwnerAddress, ',', '.'),1)

FROM PortfolioProject..NasvileHousing

---EFFECTING THE CHANGES FRM THE OWNERS ADDRESS TO THE TABLE
ALTER TABLE NasvileHousing 
Add OwnerSplitAddress  NVARCHAR(255);

UPDATE NasvileHousing
SET OwnerSplitAddress = PARSENAME(replace (OwnerAddress, ',', '.'),3)

ALTER TABLE NasvileHousing 
Add OwnerSplitCity  NVARCHAR(255);

UPDATE NasvileHousing
SET OwnerSplitCity = PARSENAME(replace (OwnerAddress, ',', '.'),2)

ALTER TABLE NasvileHousing 
Add OwnerSplitState  NVARCHAR(255);

UPDATE NasvileHousing
SET OwnerSplitState = PARSENAME(replace (OwnerAddress, ',', '.'),1)



-----sOLD AS VACANT 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NasvileHousing
group by SoldAsVacant
ORDER BY 2



--- uSING CASE STATEMENT 
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
FROM PortfolioProject..NasvileHousing

UPDATE NasvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end


--------------rEMOVE DUPLICATE 
WITH RowNumCTI as (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					)row_num

FROM PortfolioProject..NasvileHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTI
WHERE row_num > 1
--ORDER BY PropertyAddress


--- Removing the unsed column
ALTER TABLE PortfolioProject..NasvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NasvileHousing
DROP COLUMN SaleDate