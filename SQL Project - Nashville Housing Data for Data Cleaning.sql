/*

Cleaning Data in SQL Queries

*/


Select * from Portfolio_Project.dbo.Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate  --SaledateConverted
from Portfolio_Project.dbo.Nashville_Housing


Select SaleDate,CONVERT(Date,SaleDate)
from Portfolio_Project.dbo.Nashville_Housing


Update Portfolio_Project.dbo.Nashville_Housing
Set SaleDate=CONVERT(Date,SaleDate)

Alter table Portfolio_Project..Nashville_Housing
Add SaledateConverted Date

Update Portfolio_Project..Nashville_Housing
Set SaledateConverted =CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.Nashville_Housing a
 join Portfolio_Project.dbo.Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set a.PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.Nashville_Housing a
 join Portfolio_Project.dbo.Nashville_Housing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null




--Where PropertyAddress is null












--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress , Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
from Portfolio_Project..Nashville_Housing;


Alter table Portfolio_Project..Nashville_Housing
Add PropertSplitAddress nvarchar(255);

Update Portfolio_Project..Nashville_Housing
Set PropertSplitAddress=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table Portfolio_Project..Nashville_Housing
Add PropertySplitCity nvarchar(255);

Update Portfolio_Project..Nashville_Housing
Set PropertySplitCity=Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress));

Select * from 
Portfolio_Project..Nashville_Housing


----Same for Owner Address
Select * from 
Portfolio_Project..Nashville_Housing

Select OwnerAddress from 
Portfolio_Project..Nashville_Housing

Select OwnerAddress ,PARSENAME(Replace(OwnerAddress,',','.'),3),PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from Portfolio_Project..Nashville_Housing
where OwnerAddress is not null

Alter table Portfolio_Project..Nashville_Housing
Add OwnerSplitAddress nvarchar(255);

Update Portfolio_Project..Nashville_Housing
Set OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter table Portfolio_Project..Nashville_Housing
Add OwnerSplitCity nvarchar(255);

Update Portfolio_Project..Nashville_Housing
Set OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2);

Alter table Portfolio_Project..Nashville_Housing
Add OwnerSplitState nvarchar(255);

Update Portfolio_Project..Nashville_Housing
Set OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1);

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),COUNT(SoldAsVacant) from
Nashville_Housing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
	Case when SoldAsVacant ='Y' Then 'Yes'
		 when SoldAsVacant ='N' Then 'No'
	Else SoldAsVacant
	End
from Nashville_Housing

Update Nashville_Housing
Set SoldAsVacant = Case when SoldAsVacant ='Y' Then 'Yes'
		 when SoldAsVacant ='N' Then 'No'
	Else SoldAsVacant
	End






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With RownumCTE as (
Select *,
	ROW_NUMBER() over(
	Partition  by ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  order by UniqueID
				  )row_num
						  
from Nashville_Housing
--order by ParcelID
)
--Select * from RownumCTE
Delete from RownumCTE
where row_num>1
--order by PropertyAddress









---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select * from Nashville_Housing

Alter table Nashville_Housing
Drop column PropertyAddress,OwnerAddress,TaxDistrict,SaleDate













-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and l ooks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















