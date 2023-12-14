/* Cleaning data in SQL Queries*/

Select *
From [Portfolio Project 2].dbo.Nashville_Housing

--Standardize Date Format
ALTER TABLE Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted,CONVERT(Date,SaleDate) 
From [Portfolio Project 2].dbo.Nashville_Housing

--Populate Property Address Data

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project 2].dbo.Nashville_Housing a
Join [Portfolio Project 2].dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
	
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project 2].dbo.Nashville_Housing a
Join [Portfolio Project 2].dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address Into Individual Columns (Address, City, State)

Select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
From [Portfolio Project 2].dbo.Nashville_Housing

ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255);

Update Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_Housing
Add PropertySplitCity  Nvarchar(255) ;

Update Nashville_Housing
SET PropertySplitCity  = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
From [Portfolio Project 2].dbo.Nashville_Housing


--Breaking Down Owner Address

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
From [Portfolio Project 2].dbo.Nashville_Housing

--Incorporating Split Columns into Nashville_Housing table

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
Add OwnerSplitCity  Nvarchar(255) ;

Update Nashville_Housing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
Add OwnerSplitState  Nvarchar(255) ;

Update Nashville_Housing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Select *  From [Portfolio Project 2].dbo.Nashville_Housing


--Change Y and N to Yes and NO in "Sold as Vacant"field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From [Portfolio Project 2].dbo.Nashville_Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
From [Portfolio Project 2].dbo.Nashville_Housing

Update [Portfolio Project 2].dbo.Nashville_Housing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Y' THEN 'YES'
	When SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END 


--Identify Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 Saledate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 )row_num
From [Portfolio Project 2].dbo.Nashville_Housing
--order by ParcelID
)
Select *
From ROwNumCTE
Where row_num >1
Order by PropertyAddress

	
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 Saledate,
				 LegalReference
				 ORDER BY
				 UniqueID
				 )row_num
From [Portfolio Project 2].dbo.Nashville_Housing
--order by ParcelID
)
DELETE
From ROwNumCTE
Where row_num >1


--Delete Unused Columns

ALTER TABLE [Portfolio Project 2].dbo.Nashville_Housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate
