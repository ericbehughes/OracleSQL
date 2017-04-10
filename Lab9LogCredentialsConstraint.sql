CREATE TABLE Credentials
(
UserID VARCHAR2(64),
Hash VARCHAR2(64) NOT NULL,
Salt VARCHAR2(64) NOT NULL,
  CONSTRAINT Credentials_UserID_pk PRIMARY KEY(Userid)
);

  CREATE TABLE RentalLog
(
LogID VARCHAR2(64),
RentalID VARCHAR2(64),
Log_Date DATE NOT NULL,
RentedOrReturned VARCHAR2(64) NOT NULL CHECK(RentedOrReturned IN('Rented', 'Returned')),
  CONSTRAINT RentalLog_LogID_Pk PRIMARY KEY (LogID),
  
  CONSTRAINT RentalLog_RentalID_fk FOREIGN KEY (RentalID)
  REFERENCES Rentals(RentalID)
);


CONSTRAINT FOR CURRENT DATE BELOW
----------------------------------------------

CREATE OR REPLACE TRIGGER trg_check_dates
  BEFORE INSERT OR UPDATE ON RentalLog
  FOR EACH ROW
BEGIN
  IF( :new.Log_Date != CURRENT_DATE )
  THEN
    RAISE_APPLICATION_ERROR( -20001, 'Invalid Log_Date: Log_Date must be todays date');
  END IF;
END;


-----------------------------------------TEST DATA BELOW----------------------------------------------------
CREATE TABLE Credentials
(
UserID VARCHAR2(64),
Hash VARCHAR2(64) NOT NULL,
Salt VARCHAR2(64) NOT NULL,
  CONSTRAINT Credentials_UserID_pk PRIMARY KEY(Userid)
);

  CREATE TABLE RentalLog
(
LogID VARCHAR2(64),
RentalID VARCHAR2(64),
Log_Date DATE NOT NULL,
RentedOrReturned VARCHAR2(64) NOT NULL CHECK(RentedOrReturned IN('Rented', 'Returned')),
  CONSTRAINT RentalLog_LogID_Pk PRIMARY KEY (LogID),
  
  CONSTRAINT RentalLog_RentalID_fk FOREIGN KEY (RentalID)
  REFERENCES Rentals(RentalID)
);

INSERT INTO Credentials VALUES ('C1001', 'NUAEFB92TN94137988532NH', 'ASFONGO478924T0');

CREATE OR REPLACE TRIGGER trg_check_dates
  BEFORE INSERT OR UPDATE ON RentalLog
  FOR EACH ROW
BEGIN
  IF( :new.Log_Date != CURRENT_DATE )
  THEN
    RAISE_APPLICATION_ERROR( -20001, 'Invalid Log_Date: Log_Date must be todays date');
  END IF;
END;

INSERT INTO RentalLog VALUES ('2', '0001', CURRENT_DATE, 'Returned');
