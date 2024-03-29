/****
This SQL script was generated by the Configure Data Synchronization
dialog box. This script contains statements that create the
change-tracking columns, deleted-items table, and triggers on the
server database. These database objects are required by Synchronization
Services to successfully synchronize data between client and server
databases. For more information, see the
‘How to: Configure a Database Server for Synchronization’ topic in Help.
****/


IF @@TRANCOUNT > 0
set ANSI_NULLS ON 
set QUOTED_IDENTIFIER ON 

GO
BEGIN TRANSACTION;


IF @@TRANCOUNT > 0
ALTER TABLE [dbo].[gan_Proveedores] 
ADD [LastEditDate] DateTime NULL CONSTRAINT [DF_gan_Proveedores_LastEditDate] DEFAULT (GETUTCDATE()) WITH VALUES
GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
ALTER TABLE [dbo].[gan_Proveedores] 
ADD [CreationDate] DateTime NULL CONSTRAINT [DF_gan_Proveedores_CreationDate] DEFAULT (GETUTCDATE()) WITH VALUES
GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[gan_Proveedores_Tombstone]')) 
BEGIN 
CREATE TABLE [dbo].[gan_Proveedores_Tombstone]( 
    [ganProveedorID] Int NOT NULL,
    [DeletionDate] DateTime NULL
) ON [PRIMARY] 
END 

GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
ALTER TABLE [dbo].[gan_Proveedores_Tombstone] ADD CONSTRAINT [PKDEL_gan_Proveedores_Tombstone_ganProveedorID]
   PRIMARY KEY CLUSTERED
    ([ganProveedorID])
    ON [PRIMARY]
GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[gan_Proveedores_DeletionTrigger]') AND type = 'TR') 
   DROP TRIGGER [dbo].[gan_Proveedores_DeletionTrigger] 

GO
CREATE TRIGGER [dbo].[gan_Proveedores_DeletionTrigger] 
    ON [dbo].[gan_Proveedores] 
    AFTER DELETE 
AS 
SET NOCOUNT ON 
UPDATE [dbo].[gan_Proveedores_Tombstone] 
    SET [DeletionDate] = GETUTCDATE() 
    FROM deleted 
    WHERE deleted.[ganProveedorID] = [dbo].[gan_Proveedores_Tombstone].[ganProveedorID] 
IF @@ROWCOUNT = 0 
BEGIN 
    INSERT INTO [dbo].[gan_Proveedores_Tombstone] 
    ([ganProveedorID], DeletionDate)
    SELECT [ganProveedorID], GETUTCDATE()
    FROM deleted 
END 

GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[gan_Proveedores_UpdateTrigger]') AND type = 'TR') 
   DROP TRIGGER [dbo].[gan_Proveedores_UpdateTrigger] 

GO
CREATE TRIGGER [dbo].[gan_Proveedores_UpdateTrigger] 
    ON [dbo].[gan_Proveedores] 
    AFTER UPDATE 
AS 
BEGIN 
    SET NOCOUNT ON 
    UPDATE [dbo].[gan_Proveedores] 
    SET [LastEditDate] = GETUTCDATE() 
    FROM inserted 
    WHERE inserted.[ganProveedorID] = [dbo].[gan_Proveedores].[ganProveedorID] 
END;
GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;


IF @@TRANCOUNT > 0
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[gan_Proveedores_InsertTrigger]') AND type = 'TR') 
   DROP TRIGGER [dbo].[gan_Proveedores_InsertTrigger] 

GO
CREATE TRIGGER [dbo].[gan_Proveedores_InsertTrigger] 
    ON [dbo].[gan_Proveedores] 
    AFTER INSERT 
AS 
BEGIN 
    SET NOCOUNT ON 
    UPDATE [dbo].[gan_Proveedores] 
    SET [CreationDate] = GETUTCDATE() 
    FROM inserted 
    WHERE inserted.[ganProveedorID] = [dbo].[gan_Proveedores].[ganProveedorID] 
END;
GO
IF @@ERROR <> 0 
     ROLLBACK TRANSACTION;
COMMIT TRANSACTION;
