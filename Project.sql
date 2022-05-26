
-----------------------DataBase TimeeCard-----------------------------

create database TimeCard
on primary(name= TimeCard, filename= 'C:\Data\TimeCard.mdf'),
filegroup filestreamgroup contains filestream(name=TimeCard_Data,
filename= 'C:\Data\TimeCard_Data')
log on (name=log1, filename= 'C:\Data\TimeCard.ldf')


exec sp_configure filestream_access_level, 2

reconfigure

---------------------HUMANRESOURCES.EMPLOYEES-------------------------
----------------------------------------------------------------------
create schema HumanResources
----------------------------------------------------------------------
create table HumanResources.Employees
(
Employee_ID int not null identity(1,1) primary key,
First_Name char(20) not null,
Last_Name char(20) null,
Title varchar(30) constraint ckType check(Title in('Trainee','Team Member',
'Team Leader','Project Manager','Senior Project Manager')),
Phone_No varchar not null,
Billing_Rate tinyint not null
)

drop table HumanResources.Employees
--2
alter table HumanResources.Employees
add constraint cfpPhone check( Phone_No like '[0-9][0-9]-[0-9] [0-9][0-9]-[0-9]
[0-9][0-9][0-9]-[0-9][0-9] [0-9]-[0-9] [0-9] [0-9]')

--3
alter table HumanResources.Employees
add constraint eckBillingRate check(Billing_Rate > 0)

------------------------PROJECTDETAILS.PROJECTS-----------------------
----------------------------------------------------------------------
create schema ProjectDetails
----------------------------------------------------------------------
create table ProjectDetails.Projects
(
Project_ID int not null identity(1,1) primary key, --1
Project_Name char(20) not null, --2
Project_Description varchar(100) null,
Client_ID int not null, --5
Billing_Estimate money,
Employee_ID varchar(20),
Start_Date datetime not null, --2
End_Date datetime not null --2
)
--3
alter table ProjectDetails.Projects
add constraint chkBillingEstimate check(Billing_Estimate > 1000)
--4
alter table ProjectDetails.Projects
add constraint tchkDate check(End_Date > Start_Date)
--5
alter table ProjectDetails.Projects
add constraint pkclClientID foreign key(ClientID) references
CustomerDetails.Clients(Client_ID)

------------------------------CUSTOMERDETAILS.CLIENTS----------------
---------------------------------------------------------------------
create schema CustomerDetails
---------------------------------------------------------------------
create table CustomerDetails.Clients
(
Client_ID int not null identity (1,1)primary key,--1
Company_Name char(30) not null, --2
Address varchar(100) not null, --2
City varchar(100) not null, --2
State varchar(40) not null, --2
Zip char(30)not null, --2 --
Country char(30)not null, --2
Contact_Person varchar(100)not null, --2
Phone int not null --2
)

select * from CustomerDetails.Clients
--3
alter table clients add constraint chkPhone check(Phone like '[0-9][0-9]-[0-9] [0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9]
[0-9] [0-9]-[0-9] [0-9] [0-9]' )

-------------------------------PROJECTDETAILS.TIMECARDS-------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
create table ProjectDetails.TimeCards
(
TimeCard_ID int not null identity(1,1) primary key, --1
Employee_ID int not null, --2
Date_Issued datetime not null --3
)
--2
alter table ProjectDetails.Timecards
add constraint cfpEmployeeID foreign key(Employee_ID) references
HumanResources.Employees(Employee_ID)
--3
alter table ProjectDetails.Timecards
add constraint ckDateIssued check(Date_Issued >  ProjectDetails.Projects.Start_Date )
--(cast( getdate() as Date ))

--3
alter table ProjectDetails.Timecards
add constraint ckDateIssued check(Date_Issued >   getdate())  

--SELECT CAST( GETDATE() AS Date ) ;
--4 move to TimeCardHours


-----------------------------TIMECARDHOURS----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
create table TimeCardHours
(
Time_Card_Detail_ID varchar(100) not null primary key,
Time_Card_ID int not null,
Date_Worked tinyint not null,--4
Project_ID int not null , --5
Work_Description varchar(100) null,
Billable_Hours tinyint, --6
Total_Cost int not null, --7
Work_Code_ID int not null, --8
Billing_Rate int not null --Just added from --7
)
--4
alter table TimeCardHours
add constraint gckDateWorked check(Date_Worked > 0)

--5
alter table TimeCardHours
add constraint tckProjectID foreign key (Project_ID) references
ProjectDetails.Projects(project_ID)

--6
alter table TimeCardHours
add constraint gckBillableHours check(Billable_Hours > 0)

--7
alter table TimeCardHours
add constraint tcTotalCost check(Total_Cost = Billable_Hours * Billing_Rate)

--7
--or 
alter table TimeCardHours add Total_cost as Billable_Hours * Billing_Rate persisted 

--8
alter table TimeCardHours
add constraint wkcWorkCodeID foreign key(Work_Code_ID) references
ProjectDetails.WorkCodes(Work_Code_ID)


-------------------------------------PROJECRDETAILS.WORKCODES------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
create table ProjectDetails.WorkCodes
(
Work_Code_ID int not null identity(1,1) primary key, --1
Description varchar(100) not null --2
)

---------------------------------------PROJECTDETAILS.TIMECARDEXPENSES----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
create table ProjectDetails.TimeCardExpenses
(
Time_Card_Expense_ID int not null identity(1,1) primary key, --1
Time_Card_ID int not null, --2
Expense_Date datetime not null, --3 --5
Project_ID int not null, --6
Expense_Description varchar(100) null,
Expense_Amount tinyint not null, --4
Expense_Code_ID int not null --7
)

--2
alter table ProjectDetails.TimeCardExpenses
add constraint tcckTimeCardID foreign key(Time_Card_ID) references
ProjectDetails.Timecards(TimeCard_ID)


--3
alter table ProjectDetails.TimeCardExpenses
add constraint rckExpenseDate check( ProjectDetails.Projects.End_date > Expense_Date )

--4
alter table ProjectDetails.TimeCardExpenses
add constraint gtkExpenseAmount check(Expense_Amount > 0)

--6
alter table ProjectDetails.TimeCardExpenses
add constraint gckProjectID foreign key(Project_ID) references
ProjectDetails.Projects(Project_ID)

--7
alter table ProjectDetails.TimeCardExpenses
add constraint ckcExpenseCodeID foreign key(Expense_Code_ID) references
ProjectDetails.ExpenseCodes(Expense_Code_ID)


-----------------------------------PROJECTDETAILS.EXPENSECODES-------------------------
---------------------------------------------------------------------------------------
create table ProjectDetails.ExpenseCodes
(
Expense_Code_ID int not null identity(1,1) primary key, --1
Description varchar(100) not null --2
)


------------------------------PAYMENT.PAYMENTS------------------------------------------
----------------------------------------------------------------------------------------
create schema Payment

----------------------------------------------------------------------------------------

create table Payment.Payments
(
Payment_ID int not null identity(1,1) primary key, --1
Project_ID varchar(50) null,
Payment_Amount tinyint not null, --2
Payment_Date datetime null, --3
Credit_Card_Number int null, --4 
Card_Holders_Name varchar(100) null, --4 
Credit_Card_Expiry_Date datetime null, --4 
Payment_Method_ID varchar(100) null  
)

--2
alter table Payment.Payments
add constraint pyPaymentAmount check(Payment_Amount > 0)

--3
alter table Payment.Payments
add constraint gtckPaymentDate check(Payment_Date > ProjectDetails.Projects.End_Date)

--5
alter table Payment.Payments
add constraint pxkCreditCardExpiryDate check(Credit_Card_Expiry_Date  > Payment_Date )


--6
alter table Payment.Payments
add constraint pkclProjectID foreign key(Project_ID) references
ProjectDetails.Projects(Project_ID)

--7
alter table Payment.Payments
add constraint pdPaymentDate check( Payment_Amount > Payment_Date )

--------------------------------PAYMENT.PAYMENTMETHODS------------------------------
------------------------------------------------------------------------------------
create table Payment.PaymentMethods
(
Payment_Method_ID int not null identity(1,1) primary key, --1
Description varchar(100) not null --constraint unDesc unique --2
)

--;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;