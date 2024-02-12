Select *
From PortfolioProject..Housing

-- Standardized Date Format

Select SaleDateConverted--, Convert(Date, SaleDate) 
From PortfolioProject..Housing

Update PortfolioProject..Housing
Set SaleDate = Convert(Date, SaleDate)

Alter Table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address Data

Select *
From PortfolioProject..Housing
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..Housing a
Join PortfolioProject..Housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into individual columns(Address, City, State)

Select PropertyAddress
From PortfolioProject..Housing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From PortfolioProject..Housing

Alter Table Housing
Add PropertyAddressSplitAddress nvarchar(255);

Update Housing
Set PropertyAddressSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table Housing
Add PropertyAddressSplitCity nvarchar(255);

Update Housing
Set PropertyAddressSplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject..Housing

Select OwnerAddress
From PortfolioProject..Housing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..Housing

Alter Table Housing
Add OwnerSplitAddress nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table Housing
Add OwnerSplitCity nvarchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table Housing
Add OwnerSplitState nvarchar(255);

Update Housing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..Housing

-- Change Y and N to Yes and No in 'Sold as vacant' field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Housing
Group by(SoldAsVacant)
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From PortfolioProject.dbo.Housing

Update PortfolioProject.dbo.Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Housing
Group by(SoldAsVacant)
Order by 2

-- Removing Duplicates

with RowNumCTE AS(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDAte,
	LegalReference
	Order By
		UniqueID
		) row_num

From PortfolioProject..Housing
)
Select * 
From RowNumCTE
where row_num > 1
Order BY PropertyAddress

-- Delete Unused Columns

Select *
From PortfolioProject..Housing

Alter Table PortfolioProject..Housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..Housing
Drop Column SaleDate
