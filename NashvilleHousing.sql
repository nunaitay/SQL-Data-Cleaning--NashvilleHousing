select * from NashvilleHousing 


--Convert SaleDate into date datatype

Alter table NashvilleHousing
Alter column Saledate date 

--Populate PropertyAddress data

Select *
from NashvilleHousing 
WHERE PropertyAddress is null 
order by ParcelID

--Some of the parcel ids have null values while same parcel id has an address in other rows
--Join table to self
--Populate the null Property Addresses with the same Address of the same Parcel Id 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousing a 
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID  
where a.propertyaddress is null 

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a 
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID  
where a.propertyaddress is null

--Creating new columns with street address and city into separate columns 

Select PropertyAddress 
from NashvilleHousing 

--First, check how it would look 
SELECT
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) AS StreetAddress,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))as City
FROM NashvilleHousing 

--Update the table with new columns

Alter Table NashvilleHousing
ADD PropertyStreetAddress nvarchar(250)

UPDATE NashvilleHousing 
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertyCity nvarchar(250)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) 
 

--Split Owner Address using parse name

Select 
Parsename (REPLACE(OwnerAddress, ',', '.') , 3),
Parsename (REPLACE(OwnerAddress, ',', '.') , 2),
Parsename (REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing 

---Update table

ALTER TABLE NashvilleHousing
Add OwnerStreetAddress nvarchar (250)

UPDATE NashvilleHousing 
SET OwnerStreetAddress = Parsename (REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerCityAddress nvarchar (250)

UPDATE NashvilleHousing
SET OwnerCityAddress = Parsename(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerStateAddress nvarchar (250)

UPDATE NashvilleHousing
SET OwnerStateAddress = Parsename(Replace(OwnerAddress, ',', '.'), 1)
 

--Change Y and N to Yes and No in 'Sold as vacant' field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by soldasvacant 
order by 2 

SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
 FROM NashvilleHousing 

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END

 --Remove Duplicates using CTE, Partition BY, Row_Number


WITH RowNUMCTE AS (
SELECT *,
	row_number() OVER (
	PARTITION BY ParcelID,
	PropertyAddress, 
	SalePrice,
	SaleDate, 
	LegalReference
	ORDER BY
		UniqueID
		) row_num
FROM NashvilleHousing 
--order by ParcelID
)

DELETE
FROM RowNUMCTE
where row_num > 1

--Delete Unused Columns

Select * 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN PRopertyAddress, OwnerAddress, TaxDistrict

