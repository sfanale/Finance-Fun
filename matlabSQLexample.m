%SQLLite exmaple from mathworks
%Annotated by Mike Aguilar December 2016
%Note: the db file "tutorial" must not exist 

%https://www.mathworks.com/help/database/ug/work-with-data-using-the-matlab-interface-to-sqlite.html
clear all; close all; clc

%%Create a blank database 
%Create a SQLite connection conn to a new SQLite database file tutorial.db. Specify the file name in the current working folder.
dbfile = fullfile(pwd,'tutorial.db');
conn = sqlite(dbfile,'create');

%%Create some empty tables, in which we will place data later
%Create the tables inventoryTable, suppliers, salesVolume, and productTable using exec. Clear the MATLAB® workspace variables.
createInventoryTable = ['create table inventoryTable ' ...
    '(productNumber NUMERIC, Quantity NUMERIC, ' ...
    'Price NUMERIC, inventoryDate VARCHAR)'];
exec(conn,createInventoryTable)

createSuppliers = ['create table suppliers ' ...
    '(SupplierNumber NUMERIC, SupplierName varchar(50), ' ...
    'City varchar(20), Country varchar(20), ' ...
    'FaxNumber varchar(20))'];
exec(conn,createSuppliers)

createSalesVolume = ['create table salesVolume ' ...
    '(StockNumber NUMERIC, January NUMERIC, ' ...
    'February NUMERIC, March NUMERIC, April NUMERIC, ' ...
    'May NUMERIC, June NUMERIC, July NUMERIC, ' ...
    'August NUMERIC, September NUMERIC, October NUMERIC, ' ...
    'November NUMERIC, December NUMERIC)'];
exec(conn,createSalesVolume)

createProductTable = ['create table productTable ' ...
    '(productNumber NUMERIC, stockNumber NUMERIC, ' ...
    'supplierNumber NUMERIC, unitCost NUMERIC, ' ...
    'productDescription varchar(20))'];
exec(conn,createProductTable)

%%Populate the database tables with sample data from matlab
%tutorial.db contains four empty tables.
%Load the MAT-file named sqliteworkflowdata.mat. The variables CinvTable, Csuppliers, CsalesVol, and CprodTable contain data for export. Export data into the tables in tutorial.db using insert. Clear the MATLAB® workspace variables.
load('sqliteworkflowdata.mat')

%Insert the matlab data into the "conn" database object 
insert(conn,'inventoryTable', ...
    {'productNumber','Quantity','Price','inventoryDate'},CinvTable)

insert(conn,'suppliers', ...
    {'SupplierNumber','SupplierName','City','Country','FaxNumber'}, ...
    Csuppliers)

insert(conn,'salesVolume', ...
    {'StockNumber','January','February','March','April','May','June', ...
    'July','August','September','October','November','December'}, ...
    CsalesVol)

insert(conn,'productTable', ...
    {'productNumber','stockNumber','supplierNumber','unitCost', ...
    'productDescription'},CprodTable)

%Close the connection to the database
close(conn)
clear conn

%%Create a read-only SQLite connection to tutorial.db.
    conn = sqlite('tutorial.db','readonly');
    
%Import the product data into the MATLAB® workspace using fetch. Variables inventoryTable_data, suppliers_data, salesVolume_data, and productTable_data contain data from the tables inventoryTable, suppliers, salesVolume, and productTable.
%Grab all variables from inventory table and store in a matlab object  
inventoryTable_data = fetch(conn,'SELECT * FROM inventoryTable');

suppliers_data = fetch(conn,'SELECT * FROM suppliers');

salesVolume_data = fetch(conn,'SELECT * FROM salesVolume');

productTable_data = fetch(conn,'SELECT * FROM productTable');

%Display the first three rows of data in each table.
inventoryTable_data(1:3,:)

suppliers_data(1:3,:)

salesVolume_data(1:3,:)

productTable_data(1:3,:)


%% A more advanced/specific call function
% Display the product description for all the product #'s > 5
clear sql pr2
sql = 'SELECT productDescription, productNumber FROM productTable WHERE productNumber >5';
out2 = fetch(conn,sql)


%% display all city, country, fax for suppliers in US

clear sql out2
sql= 'SELECT SupplierName,City,Country,FaxNumber FROM suppliers WHERE Country= "United States"';
out2= fetch(conn,sql)