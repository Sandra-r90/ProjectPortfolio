Select *
From ProjectPortfolio..NashvilleHousing


-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From ProjectPortfolio..NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



Alter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address Data


Select *
From ProjectPortfolio..NashvilleHousing
-- Where PropertyAddress is Null
Order By ParcelID


-- Self JOIN

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.uniqueID
Where a.PropertyAddress is NULL


UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b
	ON a.ParcelID = b.parcelID
	AND a.[UniqueID ] <> b.uniqueID
Where a.PropertyAddress is NULL



-- Breaking out address into individul columns (Address, city, state)

Select PropertyAddress
From ProjectPortfolio..NashvilleHousing
-- Where PropertyAddress is Null
--Order By ParcelID


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From ProjectPortfolio..NashvilleHousing


Alter Table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

Alter Table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From ProjectPortfolio..NashvilleHousing


Select OwnerAddress
From ProjectPortfolio..NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From ProjectPortfolio..NashvilleHousing



Alter Table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




-- Change Y and N to Yes and No in "Solid as Vacant" field


Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From ProjectPortfolio..NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END
From ProjectPortfolio..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END



-- Remove Duplicates


WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From ProjectPortfolio..NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress




-- Delete Unused Columns


Select *
From ProjectPortfolio..NashvilleHousing


Alter Table ProjectPortfolio..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table ProjectPortfolio..NashvilleHousing
Drop Column SaleDate