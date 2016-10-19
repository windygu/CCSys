﻿/*
This is a simple, single-table CRUD Generator. It does not have a bunch of 
bells and whistles, and is easy to follow and modify. I wrote this to make
my job easier, and I am sharing it with you to do with it as you wish.

The Basics:
The TSQL below will create 3 procedures:
    1. An Upsert Procedure: Prefix spUpInsert 
    2. A Select Procedure: Prefix spGet
    3. A Delete Procedure: Suffix spDelete

A Little More Detail:
Things you should know:
    
    This generator expects to perform inserts, updates, and deletes on a
    table, and selects from a view. If you want to perform selects directly
    from the table, simply use the table name in both @TableName and 
    @ViewName.

The Upsert Procedure:
    If ID (Primary Key) is supplied it will perform an Update. Otherwise it 
    will perform an Insert. This generator is hard-coded to avoid inserting
    or updating these particular fields:
                                        Created
                                        CreatedBy
                                        Modified
                                        ModifiedBy
                                     
                                        <The Primary Key Field>
    That's because in my databases I use those field names for audit, and they
    are never modified except internally within the database. You can modify
    the part of this procedure that performs this function to suit your needs.

    This generator always uses the Parameter name @ID to represent the Primary
    key defined for the table. This is my preference but you can modify to suit.

The Select Procedure:
    If ID (Primary Key) is supplied it will select a single row from the View 
    (Table) whose name you provide. Otherwise it will select all rows. If the 
    @ISACTIVE_SEL variable is set to 1 (True), then the Select Procedure expects
    your View (Table) to have a bit-type field named 'IsActive'. My tables are 
    standardized to this. If @ISACTIVE_SEL = 1 the Select Procedure will have an
    additional parameter called @IsActive (bit). When @ID is not supplied, and 
    @IsActive is not supplied, the procedure selects all rows. When @ID is not
    supplied, and @IsActive is supplied, the procedure selects all rows where
    the field IsActive matches the parameter @IsActive

The Delete Procedure:
    The Delete Pocedure requires that the Key value be supplied.


    --Casey W Little
    --Kaciree Software Solutions, LLC
    Version 1.00
*/


--Type Your Database Name in this Use statement:
USE [LasMargaritasDB]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*MODIFY THE VALUES BELOW TO SUIT YOUR NEEDS*/
DECLARE @DBName nvarchar(100)=N'LasMargaritasDB';
DECLARE @TableName nvarchar(100)=N'WeightTicket';
DECLARE @ViewName nvarchar(100)=N'WeightTicket';
DECLARE @OrderBy nvarchar(100)=N'Folio';
DECLARE @OrderByDir nvarchar(4)=N'ASC';
DECLARE @AUTHOR nvarchar(50) ='MQ';
DECLARE @DESC nvarchar(100) =''; -- Ex. 'User Data' will return 'Description : Upsert User Data'
DECLARE @ISACTIVE_SEL bit =0; --Set to 1 if your table has a Bit field named IsActive
/*DO NOT MODIFY BELOW THIS LINE!!!*/

DECLARE @NNND char(23) ='NOT_NULLABLE_NO_DEFAULT';
DECLARE @NNWD char(22) ='NOT_NULLABLE_W_DEFAULT';
DECLARE @NBLE char(8) ='NULLABLE';
DECLARE @LEGEND nvarchar(max);
DECLARE @PRIMARY_KEY nvarchar(100);


--Set up Legend
    SET @LEGEND = N'USE [' + @DBName + N'];' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'GO' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'SET ANSI_NULLS ON' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'GO' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'SET QUOTED_IDENTIFIER ON' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'GO' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + CHAR(13) + CHAR(10) 

    SET @LEGEND = @LEGEND + N'-- ===================================================================' + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'-- Author      : ' + @AUTHOR + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'-- Create date : ' + CONVERT(nvarchar(30),GETDATE(),101) + CHAR(13) + CHAR(10) 
    SET @LEGEND = @LEGEND + N'-- Revised date: ' + CHAR(13) + CHAR(10) 

--Get Primary Key Field
SELECT TOP 1 @PRIMARY_KEY = COLUMN_NAME 
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE OBJECTPROPERTY(OBJECT_ID(constraint_name), 'IsPrimaryKey') = 1 AND TABLE_NAME = @TableName AND TABLE_CATALOG = @DBName;

DECLARE TableCol Cursor FOR 
SELECT c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH
    , IIF(c.COLUMN_NAME='RowVersion',@NBLE,IIF(c.COLUMN_NAME=@PRIMARY_KEY,@NBLE,IIF(c.IS_NULLABLE = 'NO' AND c.COLUMN_DEFAULT IS NULL,@NNND,IIF(c.IS_NULLABLE = 'NO' AND c.COLUMN_DEFAULT IS NOT NULL,@NNWD,@NBLE)))) AS [NULLABLE_TYPE]
FROM INFORMATION_SCHEMA.Columns c INNER JOIN
    INFORMATION_SCHEMA.Tables t ON c.TABLE_NAME = t.TABLE_NAME
WHERE t.Table_Catalog = @DBName
    AND t.TABLE_TYPE = 'BASE TABLE'
    AND t.TABLE_NAME = @TableName
ORDER BY [NULLABLE_TYPE], c.ORDINAL_POSITION;

DECLARE @TableSchema varchar(100), @cTableName varchar(100), @ColumnName varchar(100);
DECLARE @DataType varchar(30), @CharLength int, @NullableType varchar(30);

DECLARE @PARAMETERS nvarchar(max);
DECLARE @INSERT_FIELDS nvarchar(max),@INSERT_VALUES nvarchar(max);
DECLARE @UPDATE_VALUES nvarchar(max);

SET @PARAMETERS ='';
SET @INSERT_FIELDS ='';
SET @INSERT_VALUES ='';
SET @UPDATE_VALUES ='';

-- open the cursor
OPEN TableCol

-- get the first row of cursor into variables
FETCH NEXT FROM TableCol INTO @TableSchema, @cTableName, @ColumnName, @DataType, @CharLength, @NullableType

WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @ColumnName NOT IN('Created','CreatedBy','Modified','ModifiedBy')
        BEGIN
            SET @PARAMETERS=@PARAMETERS + '@' + IIF(@ColumnName=@PRIMARY_KEY,'ID',@ColumnName) + ' ' + iif(@CharLength IS NULL,@DataType,@DataType + '(' + 
                CAST(@CharLength AS nvarchar(10)) + ')') +  IIF(@NullableType=@NNND OR @NullableType=@NNWD,',','=NULL,');
            IF @ColumnName <> @PRIMARY_KEY
                BEGIN
                    SET @INSERT_FIELDS=@INSERT_FIELDS + '[' + @ColumnName + '],';
                    SET @INSERT_VALUES=@INSERT_VALUES + '@' + IIF(@ColumnName=@PRIMARY_KEY,'ID',@ColumnName) + ',';
                    SET @UPDATE_VALUES=@UPDATE_VALUES + '[' + @ColumnName + ']=@' + IIF(@ColumnName=@PRIMARY_KEY,'ID',@ColumnName) + ',';
                END
        END

        FETCH NEXT FROM TableCol INTO @TableSchema, @cTableName, @ColumnName, @DataType, @CharLength, @NullableType
    END;

    SET @PARAMETERS=LEFT(@PARAMETERS,LEN(@PARAMETERS)-1)
    SET @INSERT_FIELDS=LEFT(@INSERT_FIELDS,LEN(@INSERT_FIELDS)-1)
    SET @INSERT_VALUES=LEFT(@INSERT_VALUES,LEN(@INSERT_VALUES)-1)
    SET @UPDATE_VALUES=LEFT(@UPDATE_VALUES,LEN(@UPDATE_VALUES)-1)

-- ----------------
-- clean up cursor
-- ----------------
CLOSE TableCol;
DEALLOCATE TableCol;

--Print Upsert Statement
    PRINT N'/****** Object:  StoredProcedure [dbo].[spUpsert' + @TableName + ']    Script Date: ' + CAST(GETDATE() AS nvarchar(30)) + '  ******/' + CHAR(13) + CHAR(10) 
    PRINT @LEGEND;
    PRINT N'-- Description : Upsert ' + @DESC + CHAR(13) + CHAR(10) 
    PRINT N'-- ===================================================================' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 
    PRINT N'CREATE PROCEDURE [dbo].[spUpsert' + @TableName  + ']' + CHAR(13) + CHAR(10);
    PRINT N'  (' + @PARAMETERS + N')' + CHAR(13) + CHAR(10);
    PRINT N'AS' + CHAR(13) + CHAR(10) 
    PRINT N'BEGIN' + CHAR(13) + CHAR(10)     
    PRINT N'  IF @Id IS NULL OR @Id = 0' + CHAR(13) + CHAR(10) 
    PRINT N'    BEGIN' + CHAR(13) + CHAR(10) 
    PRINT N'      INSERT INTO [dbo].[' + @TableName + ']' + CHAR(13) + CHAR(10) 
    PRINT N'        (' + @INSERT_FIELDS + N')' + CHAR(13) + CHAR(10) 
    PRINT N'      VALUES' + CHAR(13) + CHAR(10) 
    PRINT N'        (' + @INSERT_VALUES + N');' + CHAR(13) + CHAR(10) 
    PRINT N'     SELECT SCOPE_IDENTITY();' + CHAR(13) + CHAR(10) 
    PRINT N'    END' + CHAR(13) + CHAR(10) 
    PRINT N'  ELSE' + CHAR(13) + CHAR(10) 
    PRINT N'    BEGIN' + CHAR(13) + CHAR(10) 
    PRINT N'      UPDATE [dbo].[' + @TableName + ']' + CHAR(13) + CHAR(10) 
    PRINT N'        SET ' + @UPDATE_VALUES + CHAR(13) + CHAR(10) 
    PRINT N'        WHERE ([' + @PRIMARY_KEY + '] = @Id) ;' + CHAR(13) + CHAR(10) 
    PRINT N'      SELECT * FROM [dbo].[' + @ViewName + '] WHERE [Id] = @Id;' + CHAR(13) + CHAR(10) 
    PRINT N'    END' + CHAR(13) + CHAR(10) 
    PRINT N'END' + CHAR(13) + CHAR(10) 
    PRINT N'GO' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 


    --Print Select Statement
    PRINT N'/****** Object:  StoredProcedure [dbo].[spGet' + @TableName + ']    Script Date: ' + CAST(GETDATE() AS nvarchar(30)) + '  ******/' + CHAR(13) + CHAR(10) 
    PRINT @LEGEND;
    PRINT N'-- Description : Select ' + @DESC + CHAR(13) + CHAR(10) 
    PRINT N'-- ===================================================================' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 
    PRINT N'CREATE PROCEDURE [dbo].[spGet' + @TableName  + ']' + CHAR(13) + CHAR(10);
    PRINT N'  (@Id int=NULL' + IIF(@ISACTIVE_SEL = 1,', @IsActive bit=NULL','') + ')' + CHAR(13) + CHAR(10);
    PRINT N'AS' + CHAR(13) + CHAR(10) 
    PRINT N'BEGIN' + CHAR(13) + CHAR(10) 
    
    PRINT N'  IF @Id IS NULL OR @Id = 0' + CHAR(13) + CHAR(10) 

    IF @ISACTIVE_SEL = 1
        BEGIN
            PRINT N'    BEGIN' + CHAR(13) + CHAR(10) 
            PRINT N'      IF @IsActive IS NULL' + CHAR(13) + CHAR(10) 
            PRINT N'        SELECT * FROM [dbo].[' + @ViewName + '] ORDER BY [' + @OrderBy + '] ' + @OrderByDir + ';' + CHAR(13) + CHAR(10) 
            PRINT N'      ELSE' + CHAR(13) + CHAR(10) 
            PRINT N'        SELECT * FROM [dbo].[' + @ViewName + '] WHERE [isActive] = @IsActive ORDER BY [' + @OrderBy + '] ' + @OrderByDir + ';' + CHAR(13) + CHAR(10) 
            PRINT N'    END' + CHAR(13) + CHAR(10) 
        END
    ELSE
        PRINT N'    SELECT * FROM [dbo].[' + @ViewName + '] ORDER BY [' + @OrderBy + '] ' + @OrderByDir + ';' + CHAR(13) + CHAR(10) 

    PRINT N'  ELSE' + CHAR(13) + CHAR(10) 
    PRINT N'    SELECT * FROM [dbo].[' + @ViewName + '] WHERE [ID] = @Id;' + CHAR(13) + CHAR(10) 
    PRINT N'END' + CHAR(13) + CHAR(10) 
    PRINT N'GO' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 

    --Print Delete Statement
    PRINT N'/****** Object:  StoredProcedure [dbo].[spDelete' + @TableName + ']    Script Date: ' + CAST(GETDATE() AS nvarchar(30)) + '  ******/' + CHAR(13) + CHAR(10) 
    PRINT @LEGEND;
    PRINT N'-- Description : Delete ' + @DESC + CHAR(13) + CHAR(10) 
    PRINT N'-- ===================================================================' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 
    PRINT N'CREATE PROCEDURE [dbo].[spDelete' + @TableName  + ']' + CHAR(13) + CHAR(10);
    PRINT N'  (@Id int)' + CHAR(13) + CHAR(10);
    PRINT N'AS' + CHAR(13) + CHAR(10) 
    PRINT N'BEGIN' + CHAR(13) + CHAR(10)     
    PRINT N'  SET NOCOUNT ON;' + CHAR(13) + CHAR(10) 
    PRINT N'  DELETE FROM [dbo].[' + @TableName + '] WHERE [' + @PRIMARY_KEY + ']=@Id ' + CHAR(13) + CHAR(10) 
    PRINT N'  SELECT @@ROWCOUNT as [Rows Affected];' + CHAR(13) + CHAR(10) 
    PRINT N'END' + CHAR(13) + CHAR(10) 
    PRINT N'GO' + CHAR(13) + CHAR(10) 
    PRINT CHAR(13) + CHAR(10) 
