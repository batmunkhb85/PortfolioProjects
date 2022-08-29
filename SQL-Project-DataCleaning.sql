/* 
Cleaning Data in SQL Queries 
*/

Select * 


-- Standardize date fromat

Select SaleDate, Convert(Date, SaleDate)
from [Portfolio-Project]..NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDate, SaleDateConverted
from [Portfolio-Project]..NashvilleHousing

-- Populate Property Address Data

Select *
from [Portfolio-Project]..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio-Project]..NashvilleHousing a
join [Portfolio-Project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio-Project]..NashvilleHousing a
join [Portfolio-Project]..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out Address into seperate columns

Select PropertyAddress
from [Portfolio-Project]..NashvilleHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
, SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1),Len(PropertyAddress)) As Address
from [Portfolio-Project]..NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',', PropertyAddress)+1),Len(PropertyAddress))

Select *
from [Portfolio-Project]..NashvilleHousing

Select OwnerAddress
from [Portfolio-Project]..NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3)
,parsename(replace(OwnerAddress,',','.'),2)
,parsename(replace(OwnerAddress,',','.'),1)
from [Portfolio-Project]..NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)

select *
from [Portfolio-Project]..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [Portfolio-Project]..NashvilleHousing
group by SoldAsVacant
Order by 2

select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from [Portfolio-Project]..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Remove Duplicates

with RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by 
					UniqueID
					) row_num

From [Portfolio-Project]..NashvilleHousing
)

Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete Unusual Column

select *
from [Portfolio-Project]..NashvilleHousing

Alter table [Portfolio-Project]..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table [Portfolio-Project]..NashvilleHousing
drop column SaleDate

