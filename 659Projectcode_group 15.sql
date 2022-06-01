
go
SELECT * FROM information_schema.tables
where table_name = work_life_analysis
go
SELECT * FROM information_schema.table_constraints


go
drop database if exists DMBS_PROJECT
go
CREATE DATABASE DMBS_PROJECT
GO

drop SEQUENCE if exists Test.CountBy1
go

CREATE SCHEMA Test;  
GO  

CREATE SEQUENCE Test.CountBy1  
    START WITH 1  
    INCREMENT BY 1 ;  
GO  







/*---------------------------------------Profile-------------------------------------------------*/

go
--alter table Profile_details drop CONSTRAINT if exists u_Profile_details_email_id
go 
--alter table Profile_details drop CONSTRAINT if exists pk_Profile_details_userID
go
drop table if exists Profile_details
go
create table Profile_details(
userID int not null,
firstname varchar(50) not null,
lastname varchar(50),
email_id varchar(50) not null,
phone_number char(11) not null,
password varchar(11) not null
constraint u_Profile_details_email_id unique (email_id),
constraint pk_Profile_details_userID primary key (userID)
)

/*--------------------------------------special_days_tracker--------------------------------------------------*/

go
--alter table Upcoming_tasks_calender drop CONSTRAINT if exists  fk_speacial_events_calender
go
drop table if exists special_days_tracker
go
create table special_days_tracker(
event_id int  not null,
Event_details varchar(50) not null,
task_type varchar(50) not null,
event_category varchar(50) not null,
task_time time not null,
task_date date not null,
constraint u_special_days_tracker unique (event_id)
)


/*----------------------------------Upcoming_tasks_calender------------------------------------------------------*/

/*select * from Upcoming_tasks_calender
alter table Repetitive_tasks drop CONSTRAINT if exists u_Upcoming_tasks_calender 

go
alter table Repetitive_tasks drop CONSTRAINT if exists fk_upcoming_Repetitive_tasks
go
alter table Tasks_history drop CONSTRAINT if exists fk_history_entry_tasks
go
alter table Repetitive_tasks drop CONSTRAINT if exists fk_upcoming_onetime_tasks
go
alter table One_time_tasks drop CONSTRAINT if exists fk_upcoming_onetime_tasks
go
alter table Upcoming_tasks_calender drop CONSTRAINT if exists  fk_speacial_events_calender
go
alter table Upcoming_tasks_calender drop CONSTRAINT if exists  task_status_check
go
alter table One_time_tasks drop CONSTRAINT if exists u_Upcoming_tasks_calender
go
alter table Upcoming_tasks_calender drop CONSTRAINT if exists pk_Upcoming_tasks_calender_task_id
go*/
go
drop table if exists Upcoming_tasks_calender
go
create table Upcoming_tasks_calender(
task_id int  not null,
Task_name varchar(50) not null,
Task_type varchar(50) not null,
place varchar(50),
task_catergory varchar(50),
reminder varchar(11),
task_priority varchar(11),
task_time time,
task_date date,
task_day varchar(10),
constraint pk_Upcoming_tasks_calender_task_id primary key (task_id),
constraint u_Upcoming_tasks_calender unique (task_id)
)

--alter table Upcoming_tasks_calender add CONSTRAINT fk_speacial_events_calender foreign key (task_id) REFERENCES special_days_tracker(event_id)



/*----------------------------------Repetitive_tasks------------------------------------------------------*/
go
--alter table Repetitive_tasks drop CONSTRAINT if exists u_Repetitive_tasks
GO
--ALTER table Repetitive_tasks drop CONSTRAINT if exists task_type_check
go
drop table if exists Repetitive_tasks
go
create table Repetitive_tasks(
task_id int not null,
Task_name varchar(50) not null,
Task_type varchar(50),
place varchar(50),
task_catergory varchar(50),
task_time time,
task_day varchar(10),
--constraint fk_upcoming_Repetitive_tasks foreign key (task_id) REFERENCES Upcoming_tasks_calender(task_id),
constraint u_Repetitive_tasks unique (task_id)
)
go
ALTER table Repetitive_tasks add CONSTRAINT task_type_check check( Task_type in('Repeat'))




/*----------------------------------One_time_tasks------------------------------------------------------*/
go
--alter table One_time_tasks drop CONSTRAINT if exists task_type_check2
--alter table One_time_tasks drop constraint if exists u_One_time_tasks
GO
drop table if exists One_time_tasks
go
create table One_time_tasks(
task_id int not null,
Task_name varchar(50) not null,
Task_type varchar(50),
place varchar(50),
task_catergory varchar(50),
task_time time,
task_date date,
task_day varchar(10),
--constraint fk_upcoming_onetime_tasks foreign key (task_id) REFERENCES Upcoming_tasks_calender(task_id),
--constraint u_One_time_tasks unique (task_id)
)
go
ALTER table One_time_tasks add CONSTRAINT task_type_check2 check( Task_type in('OneTime'))


go
--alter table Tasks_history drop CONSTRAINT if exists u_history_entry_tasks
GO
drop table if exists Tasks_history
go
create table Tasks_history(
task_id int not null,
Task_name varchar(50) not null,
Task_type varchar(50),
task_catergory varchar(50),
task_time time,
task_date date,
task_day varchar(10),
constraint fk_history_entry_tasks foreign key (task_id) REFERENCES Upcoming_tasks_calender(task_id),
constraint u_history_entry_tasks unique (task_id)
)
go
--ALTER table Tasks_history add CONSTRAINT task_category_completed check( task_catergory in('Completed'))



/*--------------------------------------monthly_analysis--------------------------------------------------*/

go
drop table work_life_pie
go
create table work_life_pie(
Task_Type varchar(50),
Task_count int,
Task_month varchar(50)
)

insert into work_life_pie(Task_Type,Task_count,Task_month)
values ('Work',4,'May')

select
work_tasks_snoozed+social_tasks_completed as total_tasks
from monthly_analysis


/*--------------------------------Triggers for loading upcoming table-----------------------------------------*/

go
drop trigger if exists special_events_entry
go 
create trigger special_events_entry
on special_days_tracker
after insert
as begin 
insert Upcoming_tasks_calender(task_id,Task_name,task_type,task_catergory,reminder,task_priority,task_time,task_date)
select event_id,Event_details,task_type,event_category,'pending','High',task_time,task_date
from special_days_tracker
END


/*-------------------------------Triggers for loading OneTime  table----------------------------------------------*/

drop trigger if exists one_time_task_entry
go 
create trigger one_time_task_entry
on Upcoming_tasks_calender
after insert
as begin 
insert One_time_tasks(task_id,Task_name,task_type,place,task_catergory,task_time,task_date,task_day)
select task_id,Task_name,Task_type,null,task_catergory,task_time,task_date,task_day
from Upcoming_tasks_calender
where Task_type='OneTime'
END

/*---------------------------------Triggers for loading Repetitive_tasks  table--------------------------------------------*/


drop trigger if exists Repetitive_tasks_entry
go 
create trigger Repetitive_tasks_entry
on Upcoming_tasks_calender
after insert
as begin 
insert Repetitive_tasks(task_id,Task_name,task_type,place,task_catergory,task_time,task_day)
select task_id,Task_name,Task_type,null,task_catergory,task_time,task_day
from Upcoming_tasks_calender
where task_type='Repeat'
END

/*---------------------------------Triggers for loading task_History table--------------------------------------------*/


drop trigger if exists tasks_history_entry
go 
create trigger tasks_history_entry
on Upcoming_tasks_calender
after update
as begin 
insert into Tasks_history(task_id, Task_name, Task_type, task_catergory, task_time, task_date, task_day)
select task_id,Task_name,Task_type,task_catergory,task_time,task_date,task_day
from Upcoming_tasks_calender
where reminder='completed'
END
select * from Tasks_history

/*---------------------------------Triggers for loading work_life_analysis table--------------------------------------------*/

drop trigger if exists work_life_analysis_entry
go 
create trigger work_life_analysis_entry
on Tasks_history
after insert
as begin 

    if (select count(*) from work_life_pie) > 0
    begin
    update work_life_pie
    set
    Task_count =(select count(*) from Tasks_history where task_catergory='Work')
    where Task_type ='Work'

    go
    update work_life_pie
    set
    Task_count =(select count(*) from Tasks_history where task_catergory='Social')
    where Task_type ='Social'

    end
END

--insert into work_life_pie(Task_Type,Task_count,Task_month)
--values('Social',1,'May')
select * from work_life_pie
select * from Tasks_history
/*--------------------------------------Procedures for Reminders---------------------------------------------------------------*/

exec p_shoot_reminder_onetime
go
exec p_shoot_reminder_repetitive

--For One time tasks
go
drop procedure if exists p_shoot_reminder_onetime
go
CREATE PROCEDURE p_shoot_reminder_onetime
AS
Declare @v_Name nvarchar(100)
Declare @v_Time varchar(100)
Declare @v_Task_id int
Declare cursor_db cursor For SELECT task_name, LEFT(convert(varchar, task_time), 5) as taskTime, task_id
FROM One_time_tasks where task_date = DATEADD(day, 1, CAST(GETDATE() AS date));-- (select convert(date, getdate()));
OPEN cursor_db 
Fetch Next From cursor_db Into @v_Name, @v_Time, @v_Task_id
While @@Fetch_Status = 0 
Begin
    PRINT 'Here is a reminder for you, it is your ' + @v_Name +' today, at '+@v_Time 
    Fetch Next From cursor_db Into @v_Name, @v_Time, @v_Task_id

    update Upcoming_tasks_calender set reminder='Completed' where task_id=@v_Task_id

End -- End of Fetch
Close cursor_db
Deallocate cursor_db
go
exec p_shoot_reminder_onetime

--For Repetitive tasks
go
drop procedure if exists p_shoot_reminder_repetitive
go
CREATE PROCEDURE p_shoot_reminder_repetitive
AS
Declare @v_Name1 nvarchar(50)
Declare @v_Time1 varchar(50)
Declare @v_Task_id1 int
Declare cursor_db1 cursor For select task_name, LEFT(convert(varchar, task_time), 5), task_id from Repetitive_tasks where task_day= (select
CASE 
    when (SELECT DATEPART(dw,GETDATE()))=1 then 'Sunday'
    when (SELECT DATEPART(dw,GETDATE()))=2 then 'Monday'
    when (SELECT DATEPART(dw,GETDATE()))=3 then 'Tueday'
    when (SELECT DATEPART(dw,GETDATE()))=4 then 'Wednesday'
    when (SELECT DATEPART(dw,GETDATE()))=5 then 'Thursday'
    when (SELECT DATEPART(dw,GETDATE()))=6 then 'Friday'
    when (SELECT DATEPART(dw,GETDATE()))=7 then 'Saturday'
END) 

OPEN cursor_db1 
Fetch Next From cursor_db1 Into @v_Name1, @v_Time1, @v_Task_id1
While @@Fetch_Status = 0 Begin

print 'Here is a reminder for you, it is your ' + @v_Name1 +' today, at '+@v_Time1 
update Upcoming_tasks_calender 
    set reminder='Completed'
    where task_id=@v_Task_id1
Fetch Next From cursor_db1 Into @v_Name1, @v_Time1, @v_Task_id1

End -- End of Fetch
Close cursor_db1
Deallocate cursor_db1
go
exec p_shoot_reminder_repetitive


/*------------------------------------------Stored procedures for Inserts -----------------------------------------------------------*/


--Special days
go
drop procedure if exists p_insert_special_events
go
CREATE PROCEDURE p_insert_special_events @Event_details varchar(50), @event_category varchar(50), 
@task_time time, @task_date date
AS
BEGIN
declare @res int
declare @task_type varchar(50)
SELECT @res = NEXT VALUE FOR Test.CountBy1;
print @res
set @task_type ='OneTime'
insert into special_days_tracker(event_id,Event_details,task_type,event_category,task_time,task_date)
values(@res,@Event_details, @task_type, @event_category, @task_time, @task_date)
END

--Upcoming_tasks_calender

go
drop procedure if exists p_insert_Upcoming_tasks_calender
go
CREATE PROCEDURE p_insert_Upcoming_tasks_calender @task_details varchar(50), @task_type varchar(50), @task_category varchar(50), 
@task_time time, @task_date date, @task_day varchar(50)
AS
BEGIN
declare @task_priority varchar(50)
declare @reminder varchar(50)
declare @res int
SELECT @res = NEXT VALUE FOR Test.CountBy1;
print @res
set @task_priority ='High'
set @reminder ='Pending'
insert Upcoming_tasks_calender(task_id,Task_name,task_type,task_catergory,reminder,task_priority,task_time,task_date, task_day)
values(@res, @task_details, @task_type, @task_category, @reminder, @task_priority, @task_time, @task_date, @task_day)
END



/*-------------------------------------------------Inserts in tables using exec of stored procedures and trigers------------------------------------------------------*/


exec p_shoot_reminder_onetime
go
exec p_shoot_reminder_repetitive




go
exec p_insert_special_events 'Date with girlfriend','Social','14:00', '05-20-2021'
go
exec p_insert_special_events 'college reunion','Social','23:59', '05-18-2021'
go
exec p_insert_special_events 'JobInterview','Work','23:59', '05-21-2021'
go
exec p_insert_special_events 'Socialnumber appointment','Work','23:59', '05-29-2021'
go
exec p_insert_special_events 'Driving Test','Work','23:59', '05-18-2021'
go
exec p_insert_special_events 'MBA Class','Work','17:59', '05-30-2021'
go
exec p_insert_special_events 'JobInterview','Work','23:59', '05-28-2021'
go
exec p_insert_Upcoming_tasks_calender 'Swim Class','Repeat','Social','23:59', null, 'Thursday'
go
exec p_insert_Upcoming_tasks_calender 'Gym','Repeat','Social','07:00', null, 'Sunday'
go
exec p_insert_Upcoming_tasks_calender 'Beach Cleaning','Repeat','Social','09:00', null, 'Sunday'
go
exec p_insert_Upcoming_tasks_calender 'NGO Tutoring','Repeat','Social','10:00', null, 'Saturday'
go
exec p_insert_Upcoming_tasks_calender 'Church volunteering','Repeat','Social','14:00', null, 'Friday'
go
exec p_insert_Upcoming_tasks_calender 'Guitar Class','Repeat','Social','16:00', null, 'Friday'
exec p_insert_special_events 'Birthday','Social','23:59', '05-18-2021'
go
exec p_insert_Upcoming_tasks_calender 'Birthday','OneTime','Social','23:59', '05-18-2021', 'Tuesday'
go
exec p_insert_Upcoming_tasks_calender 'Swim Class','Repeat','Social','23:59', null, 'Thursday'
go


go
delete from special_days_tracker
go
delete from Tasks_history
go
delete from Upcoming_tasks_calender
go
delete from One_time_tasks
go
delete from Repetitive_tasks
go
delete from Tasks_history
go



update Upcoming_tasks_calender 
set reminder='Completed'
where task_date <= (select convert(date, getdate()))



go
select *  from special_days_tracker
go
select * from Upcoming_tasks_calender where task_catergory='Work'
go
select * from One_time_tasks
go
select * from Repetitive_tasks
go
select * from Tasks_history
go
select * from work_life_pie




go

drop view if exists v_upcoming_task
go
create view v_upcoming_task AS
SELECT Task_name, (cast(task_time as varchar) + ' ' +cast(task_date as varchar)) as task_dstetime, task_day
FROM Upcoming_tasks_calender

go
drop view if exists v_history_task
go
create view v_history_task as 
select task_name, (cast(task_date as varchar)+ ' ' + cast(task_time as varchar)) as task_dstetime, task_day
from Tasks_history

go
select * from v_history_task
go
select * from v_upcoming_task

select * from Profile_details

insert into Profile_details(userID,firstname,email_id,phone_number,password)
values(145,'avani','apatel@syr.edu','9757273735','xyzanjkk')

select * from Profile_details

select * from Tasks_history

update Upcoming_tasks_calender
set reminder='Completed'
where task_id=2

select * from Upcoming_tasks_calender



create table work_life_pie(
    Task_type varchar(10),
    Task_count varchar(10),
    Task_month varchar(10)
)

insert into work_life_pie( Task_type, Task_count, Task_month) 
values('social',1500,'May')


