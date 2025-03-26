/*

Cleaning Data inSQL Queries

/*


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------
--Standardize Data Format


Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD SaleDateConverted Date;


Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)


Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------
--Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID



Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null



Select a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)

From [PortfolioProject].[dbo].[NashvilleHousing] a
JOIN [PortfolioProject].[dbo].[NashvilleHousing] b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
--Where a.PropertyAddress is null

--------------------------------------------------------------------

--Breaking out Address into Individual Columns(Address, City, State)

Select PropertyAddress
From [PortfolioProject].[dbo].[NashvilleHousing]

--1. PropertyAddress : separate by SUBSTRING,CHARINDEX
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From [PortfolioProject].[dbo].[NashvilleHousing]


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD PropertySplitAddress varchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE [PortfolioProject].[dbo].[NashvilleHousing]
ADD PropertySplitCity varchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 



--2. OwnerAddress :  : separate by PARSENAME,REPLACE


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress varchar(255);

Update [PortfolioProject].[dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1) 


--------------------------------------------------------------------
--change Y and N to Tes and No in "Sold As Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE	When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant  = CASE	When SoldAsVacant = 'Y' THEN 'Yes'
							When SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END



--------------------------------------------------------------------
--Remove Duplicates

Select *,
	ROW_NUMBER() OVER(PARTITION BY	ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference
				 ORDER BY UniqueID) row_num

From PortfolioProject.dbo.NashvilleHousing




WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(PARTITION BY	ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference
				 ORDER BY UniqueID) row_num

From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress




WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(PARTITION BY	ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference
				 ORDER BY UniqueID) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress

