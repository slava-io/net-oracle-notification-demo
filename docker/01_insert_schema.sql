CONN ADYENSYNC/development;

-- Print current active user
SHOW USER;

CREATE TABLE VAN_COUNTRY (
    COUNTRYID                 NUMBER(*, 0)      NOT NULL,
    COUNTRYCODE               VARCHAR2(3 BYTE)  NOT NULL CONSTRAINT "CKT_COUNTRY_countrycode" CHECK (COUNTRYCODE =
                                                                                                     upper(
                                                                                                         COUNTRYCODE)),
    COUNTRY                   VARCHAR2(40 BYTE) NOT NULL,
    DEFAULTVATID              NUMBER(*, 0),
    VATNUMBERLENGTH           NUMBER(*, 0),
    TELEPHONECOUNTRYCODE      VARCHAR2(20 BYTE),
    POSTALCODEPICTUREFORMAT   VARCHAR2(50 BYTE),
    POSTALCODELOOKUPAVAILABLE CHAR              NOT NULL,
    CURRENCYID                NUMBER(*, 0),
    VATCHECKTYPEID            NUMBER(*, 0),
    VATREGULAREXPR            VARCHAR2(60 BYTE),
    CONSTRAINT PK_VAN_COUNTRY PRIMARY KEY (COUNTRYID)
);

/

CREATE TABLE VAN_SUBSIDIARY (
    SUBSIDIARYID                   NUMBER(*, 0)      NOT NULL,
    SUBSIDIARY                     VARCHAR2(40 BYTE) NOT NULL,
    EXTERNALADMINISTRATION         VARCHAR2(40 BYTE),
    COMPANYID                      NUMBER(*, 0),
    SHAREDSTOCKBASESUBSIDIARYID    NUMBER(*, 0),
    RETURNSTOCKLOCATIONID          NUMBER(*, 0),
    SUPPLIERID                     NUMBER(*, 0),
    CUSTOMERID                     NUMBER(*, 0),
    EXPORTADMINISTRATION           VARCHAR2(40 BYTE),
    TERMSOFUSECPC                  BLOB,
    VATCOUNTRYID                   NUMBER(*, 0)      NOT NULL,
    CPCTASKHANDLINGSTOCKLOCATIONID NUMBER(*, 0)      NOT NULL,
    CONSTRAINT PK_VAN_SUBSIDIARY PRIMARY KEY (SUBSIDIARYID),
    CONSTRAINT FK_VAN_SUBSIDIARY_SUBSIDIARY FOREIGN KEY (SHAREDSTOCKBASESUBSIDIARYID) REFERENCES VAN_SUBSIDIARY (SUBSIDIARYID),
    CONSTRAINT FK_VAN_SUBSIDIARY_VATCOUNTRYID FOREIGN KEY (VATCOUNTRYID) REFERENCES VAN_COUNTRY (COUNTRYID)
);

/

CREATE TABLE VAN_LANGUAGE (
    LANGUAGEID      NUMBER(*, 0)      NOT NULL,
    LANGUAGE        VARCHAR2(40 BYTE) NOT NULL,
    LANGUAGEISOCODE VARCHAR2(6 BYTE)  NOT NULL,
    LOCALE          VARCHAR2(5 BYTE)  NOT NULL,
    CONSTRAINT PK_VAN_LANGUAGE PRIMARY KEY (LANGUAGEID),
    CONSTRAINT UK_VAN_LANGUAGE_LANGUAGE UNIQUE (LANGUAGE),
    CONSTRAINT UK_VAN_LANGUAGE_LOCALE UNIQUE (LOCALE)
);

/

CREATE TABLE VAN_IDENTITY (
    IDENTITYID           NUMBER(*, 0) NOT NULL,
    REGISTRATIONDATETIME DATE         NOT NULL,
    COMPANYID            NUMBER(*, 0) NOT NULL,
    CONSTRAINT PK_VAN_IDENTITY PRIMARY KEY (IDENTITYID)
);

/

CREATE SEQUENCE SEQ_VAN_IDENTITYID NOCACHE;

CREATE OR REPLACE TRIGGER TIB_VAN_IDENTITY
BEFORE INSERT
    ON VAN_IDENTITY
FOR EACH ROW
    BEGIN
        --  Column "IDENTITYID" uses sequence SEQ_VAN_IDENTITYID
        SELECT SEQ_VAN_IDENTITYID.NEXTVAL
        INTO :NEW.IDENTITYID
        FROM DUAL;
    END;
/

CREATE TABLE VAN_IDENTITYROLESTATE (
    IDENTITYROLESTATEID NUMBER(*, 0)      NOT NULL,
    IDENTITYROLESTATE   VARCHAR2(40 BYTE) NOT NULL,
    CONSTRAINT PK_VAN_IDENTITYROLESTATE PRIMARY KEY (IDENTITYROLESTATEID)
);

/

CREATE TABLE VAN_ROLE (
    ROLEID       NUMBER(*, 0)      NOT NULL,
    ROLENAME     VARCHAR2(20 BYTE) NOT NULL,
    IMPLICITROLE CHAR              NOT NULL,
    CONSTRAINT PK_VAN_ROLE PRIMARY KEY (ROLEID)
);

/

CREATE TABLE VAN_IDENTITYROLE (
    IDENTITYROLEID      NUMBER(*, 0)              NOT NULL,
    IDENTITYID          NUMBER(*, 0)              NOT NULL,
    ROLEID              NUMBER(*, 0)              NOT NULL,
    EMAIL               VARCHAR2(100 BYTE)        NOT NULL,
    CUSTOMERID          NUMBER(*, 0),
    USERID              NUMBER(*, 0),
    IDENTITYROLESTATEID NUMBER(*, 0)              NOT NULL,
    PASSWORDHASH        VARCHAR2(64 BYTE)         NOT NULL,
    REGISTRATIONSHOPID  NUMBER(*, 0)              NOT NULL,
    LANGUAGEID          NUMBER(*, 0) DEFAULT NULL NOT NULL,
    CONSTRAINT PK_VAN_IDENTITYROLE PRIMARY KEY (IDENTITYROLEID),
    CONSTRAINT FK_VAN_IDENTITYROLE_IDENTITY FOREIGN KEY (IDENTITYID) REFERENCES VAN_IDENTITY (IDENTITYID),
    CONSTRAINT FK_VAN_IDENTITYROLE_LANGUAGE FOREIGN KEY (LANGUAGEID) REFERENCES VAN_LANGUAGE (LANGUAGEID),
    CONSTRAINT FK_VAN_IDENTITYROLE_ROLE FOREIGN KEY (ROLEID) REFERENCES VAN_ROLE (ROLEID),
    CONSTRAINT FK_VAN_IDNTTYROL_IDNTYROLSTATE FOREIGN KEY (IDENTITYROLESTATEID) REFERENCES VAN_IDENTITYROLESTATE (IDENTITYROLESTATEID)
);

/

CREATE SEQUENCE SEQ_VAN_IDENTITYROLEID NOCACHE;

/

CREATE UNIQUE INDEX VAN_IDENTROLESTATE_UNI_STATE
    ON VAN_IDENTITYROLESTATE (UPPER("IDENTITYROLESTATE"));
CREATE UNIQUE INDEX VAN_IDNTTYROL_UNI_CRENDETIALS
    ON VAN_IDENTITYROLE (UPPER("EMAIL"));

CREATE OR REPLACE TRIGGER TIB_VAN_IDENTITYROLE
BEFORE INSERT
    ON VAN_IDENTITYROLE
FOR EACH ROW
    BEGIN
        --  Column "IDENTITYROLEID" uses sequence SEQ_VAN_IDENTITYROLEID
        SELECT SEQ_VAN_IDENTITYROLEID.NEXTVAL
        INTO :NEW.IDENTITYROLEID
        FROM DUAL;
    END;
/

CREATE TABLE VAN_ADDRESS
(
    ADDRESSID        NUMBER NOT NULL
        CONSTRAINT PK_VAN_ADDRESS
        PRIMARY KEY,
    STREET           VARCHAR2(30),
    STREETNR         VARCHAR2(6),
    STREETNRADDITION VARCHAR2(6),
    POSTALCODE       VARCHAR2(8),
    CITY             VARCHAR2(30),
    COUNTRYID        NUMBER
        CONSTRAINT FK_VAN_ADDRESS_COUNTRY
        REFERENCES VAN_COUNTRY,
    LASTNAME         VARCHAR2(40),
    NAMEADDITIONS    VARCHAR2(10),
    FIRSTNAME        VARCHAR2(20),
    INITIALS         VARCHAR2(6),
    GENDER           VARCHAR2(1),
    ADDRESSEXTRA     VARCHAR2(30),
    ADDRESSADDITION  VARCHAR2(40),
    COMPANY          VARCHAR2(40),
    BUSNR            VARCHAR2(5)
);

/

CREATE SEQUENCE SEQ_VAN_ADDRESSID NOCACHE;

/

CREATE OR REPLACE TRIGGER TIB_VAN_ADDRESS
BEFORE INSERT
    ON VAN_ADDRESS
FOR EACH ROW
    BEGIN
        --  Column "CUSTOMERID" uses sequence SEQ_VAN_CUSTOMERID
        SELECT SEQ_VAN_ADDRESSID.NEXTVAL
        INTO :NEW.ADDRESSID
        FROM DUAL;
    END;
/

CREATE TABLE VAN_COMPANY
(
    COMPANYID                 NUMBER        NOT NULL
        CONSTRAINT PK_VAN_COMPANY
        PRIMARY KEY,
    COMPANY                   VARCHAR2(40)  NOT NULL,
    STREET                    VARCHAR2(30)  NOT NULL,
    STREETNR                  VARCHAR2(6)   NOT NULL,
    STREETNRADDITION          VARCHAR2(6),
    POSTALCODE                VARCHAR2(8)   NOT NULL,
    CITY                      VARCHAR2(30)  NOT NULL,
    COUNTRYID                 NUMBER        NOT NULL,
    EMAIL                     VARCHAR2(100) NOT NULL,
    TELEPHONE                 VARCHAR2(20)  NOT NULL,
    FAX                       VARCHAR2(20)  NOT NULL,
    BANKACCOUNTID             NUMBER        NOT NULL,
    SECONDARYBANKACCOUNTID    NUMBER,
    CODBANKACCOUNTID          NUMBER,
    DOMAIN                    VARCHAR2(100) NOT NULL,
    DELIVERYSTREET            VARCHAR2(30)  NOT NULL,
    DELIVERYSTREETNR          VARCHAR2(6)   NOT NULL,
    DELIVERYSTREETNRADDITION  VARCHAR2(6),
    DELIVERYPOSTALCODE        VARCHAR2(8)   NOT NULL,
    DELIVERYCITY              VARCHAR2(30)  NOT NULL,
    DELIVERYCOUNTRYID         NUMBER        NOT NULL,
    VATNUMBER                 VARCHAR2(20)  NOT NULL,
    COCNUMBER                 VARCHAR2(50)  NOT NULL,
    COMPANYLOGO               BLOB,
    MAINDISTRISTOCKLOCATIONID NUMBER        NOT NULL,
    RETURNEMAIL               VARCHAR2(100) NOT NULL,
    PARENTCOMPANYID           NUMBER,
    SHOPID                    NUMBER,
    GENERALLEDGERACCOUNT      VARCHAR2(10),
    GENERALLEDGERACCOUNTICL   VARCHAR2(10),
    RETURNTELEPHONE           VARCHAR2(20),
    OWNSTRANSPORTATION        CHAR          NOT NULL,
    RETURNFAX                 VARCHAR2(20),
    EMAILSENDERNAME           VARCHAR2(40)  NOT NULL,
    WWW                       VARCHAR2(100),
    SALESTELEPHONE            VARCHAR2(20)  NOT NULL,
    SALESFAX                  VARCHAR2(20)  NOT NULL,
    PURCHASETELEPHONE         VARCHAR2(20)  NOT NULL,
    PURCHASEFAX               VARCHAR2(20)  NOT NULL,
    SALESCOMPANY              VARCHAR2(40),
    SALESSTOCKLOCATIONID      NUMBER,
    PURCHASECOMPANY           VARCHAR2(40),
    PURCHASESTOCKLOCATIONID   NUMBER,
    ACCOUNTEMAIL              VARCHAR2(100) NOT NULL,
    FINANCETELEPHONE          VARCHAR2(20),
    FINANCEEMAIL              VARCHAR2(100),
    COMPLAINTSEMAIL           VARCHAR2(100),
    QUOTATIONEMAIL            VARCHAR2(100),
    EORICODE                  VARCHAR2(20),
    MAINDISTRISTOCKCLUSTERID  NUMBER        NOT NULL,
    INVOICEREMINDERTELEPHONE  VARCHAR2(20),
    INVOICEREMINDEREMAIL      VARCHAR2(100),
    INVOICEREMINDERSENDERNAME VARCHAR2(40),
    INVOICEEMAIL              VARCHAR2(100)
);
/

CREATE SEQUENCE SEQ_VAN_COMPANYID NOCACHE;
/

CREATE OR REPLACE TRIGGER TIB_VAN_COMPANY
BEFORE INSERT
    ON VAN_COMPANY
FOR EACH ROW
    BEGIN
        --  Column "COMPANYID" uses sequence SEQ_VAN_COMPANYID
        SELECT SEQ_VAN_COMPANYID.NEXTVAL
        INTO :NEW.COMPANYID
        FROM DUAL;
    END;
  /

CREATE TABLE VAN_CUSTOMER
(
    CUSTOMERID                    NUMBER NOT NULL PRIMARY KEY,
    CUSTOMERGROUPID               NUMBER,
    SHIPMENTADDRESSID             NUMBER NOT NULL,
    INVOICEADDRESSID              NUMBER NOT NULL,
    LANGUAGEID                    NUMBER NOT NULL,
    LASTNAME                      VARCHAR2(40),
    NAMEADDITIONS                 VARCHAR2(10),
    FIRSTNAME                     VARCHAR2(20),
    INITIALS                      VARCHAR2(6),
    GENDER                        VARCHAR2(1),
    EMAIL                         VARCHAR2(100),
    TELEPHONE                     VARCHAR2(20),
    FAX                           VARCHAR2(20),
    MOBILE                        VARCHAR2(20),
    BANKNUMBER                    VARCHAR2(34),
    COMPANY                       VARCHAR2(40),
    VATNUMBER                     VARCHAR2(20),
    VATNUMBERVALID                CHAR,
    VATNUMBERVALIDATIONUSERID     NUMBER,
    VATNUMBERVALIDATIONDATETIME   DATE,
    REGISTRATIONDATE              DATE,
    TELEPHONEINDEX                VARCHAR2(20),
    MOBILEINDEX                   VARCHAR2(20),
    B2BCUSTOMER                   CHAR   NOT NULL,
    COMPANYTYPEID                 NUMBER,
    ACCOUNTMANAGERID              NUMBER,
    COMPANYCUSTOMERID             NUMBER,
    COMPANYSORTID                 NUMBER,
    COCNUMBER                     VARCHAR2(50),
    COCRECEIVED                   DATE,
    COCDATE                       DATE,
    PAYMENTTERM                   NUMBER,
    INVOICEDELIVERYMETHODID       NUMBER,
    DATEOFBIRTH                   DATE,
    MAXCREDIT                     NUMBER(14, 5),
    CREDITCUSTOMER                CHAR,
    CHECKAMOUNTADDRESS            NUMBER(14, 5),
    EMPLOYEECOUNT                 NUMBER,
    FINANCIALCONTACTINITIALS      VARCHAR2(6),
    FINANCIALCONTACTNAMEADDITIONS VARCHAR2(10),
    FINANCIALCONTACTLASTNAME      VARCHAR2(40),
    FINANCIALCONTACTTELEPHONE     VARCHAR2(20),
    FINANCIALCONTACTTELEPHONEALT  VARCHAR2(20),
    FINANCIALCONTACTFAX           VARCHAR2(20),
    FINANCIALCONTACTEMAIL         VARCHAR2(100),
    INVOICEEMAIL                  VARCHAR2(100),
    EXPORTCUSTOMER                CHAR   NOT NULL,
    CUSTOMERROLEID                NUMBER,
    CUSTOMERBRANCHID              NUMBER,
    CUSTOMERFUNCTIONID            NUMBER,
    PERSONID                      VARCHAR(40 BYTE)
);

/

CREATE INDEX VAN_CUSTOMER_IDX_PERSONID
    ON VAN_CUSTOMER (PERSONID)
/

CREATE SEQUENCE SEQ_VAN_CUSTOMERID NOCACHE;

/

CREATE OR REPLACE TRIGGER TIB_VAN_CUSTOMER
BEFORE INSERT
    ON VAN_CUSTOMER
FOR EACH ROW
    BEGIN
        --  Column "CUSTOMERID" uses sequence SEQ_VAN_CUSTOMERID
        SELECT SEQ_VAN_CUSTOMERID.NEXTVAL
        INTO :NEW.CUSTOMERID
        FROM DUAL;

        -- Set ExportCustomer to 'N' if not specified
        IF :NEW.EXPORTCUSTOMER IS NULL
        THEN
            :NEW.EXPORTCUSTOMER := 'N' /*[VAN_CONST.BOOLEAN_FALSE]*/;
        END IF;

        -- If this Customer is an ExportCustomer, it is also a B2BCustomer
        IF :NEW.EXPORTCUSTOMER = 'Y' /*[VAN_CONST.BOOLEAN_TRUE]*/
        THEN
            :NEW.B2BCUSTOMER := 'Y' /*[VAN_CONST.BOOLEAN_TRUE]*/;
        END IF;

        -- Set B2BCustomer to 'N' if not specified
        IF :NEW.B2BCUSTOMER IS NULL
        THEN
            :NEW.B2BCUSTOMER := 'N' /*[VAN_CONST.BOOLEAN_FALSE]*/;
        END IF;

        -- Set language to local language if not specified
        IF :NEW.LANGUAGEID IS NULL
        THEN
            :NEW.LANGUAGEID := 1 /* 1 [VAN_CONST.LOCAL_LANGUAGE]*/;
        END IF;

        IF :NEW.REGISTRATIONDATE IS NULL
        THEN
            :NEW.REGISTRATIONDATE := sysdate;
        END IF;

        IF :NEW.INVOICEDELIVERYMETHODID IS NULL
        THEN
            :NEW.INVOICEDELIVERYMETHODID := 2 /*[VAN_CONST.INVOICEDELIVERYMETHOD_EMAIL]*/;
        END IF;

    END;
/

CREATE TABLE TMP_VAN_CUSTOMERPERSON (
  IDENTITYROLEID NUMBER(*,0) NOT NULL,
  PERSONID VARCHAR2(40 BYTE) NOT NULL,
  CUSTOMERID NUMBER(*,0),
  CONSTRAINT pk_tmp_van_customerperson PRIMARY KEY (IDENTITYROLEID, PERSONID)
);

/

CREATE TABLE VAN_IDENTITYROLEPREFERENCE (
  identityroleid NUMBER(*,0) NOT NULL,
  paymentmethodid NUMBER(*,0),
  paymentissuerid NUMBER(*,0),
  stocklocationid NUMBER(*,0),
  carrierdropofflocationid NUMBER(*,0),
  identityroleccaliasid NUMBER(*,0),
  CONSTRAINT pk_van_identityrolepreference PRIMARY KEY (identityroleid)
);
/

CREATE TABLE VAN_PAYMENTMETHOD (
  paymentmethodid NUMBER(*,0) NOT NULL,
  paymentmethod VARCHAR2(40 BYTE) NOT NULL,
  paymentdueperiod NUMBER(*,0) NOT NULL,
  "ACTIVE" CHAR NOT NULL,
  banknumberrequiredforrefund CHAR NOT NULL,
  availableforinvitetopay CHAR NOT NULL,
  displaytext VARCHAR2(40 BYTE),
  autoverificationamount NUMBER(9,2),
  CONSTRAINT pk_van_paymentmethod PRIMARY KEY (paymentmethodid)
);
/

CREATE SEQUENCE SEQ_VAN_PAYMENTMETHODID NOCACHE;
/

CREATE TABLE VAN_PAYMENTISSUER (
  paymentissuerid NUMBER(*,0) NOT NULL,
  paymentmethodid NUMBER(*,0) NOT NULL,
  issuerreference VARCHAR2(40 BYTE),
  paymentissuer VARCHAR2(40 BYTE) NOT NULL,
  "ACTIVE" CHAR NOT NULL,
  issuerbic VARCHAR2(20 BYTE),
  issuerimageid NUMBER(*,0),
  CONSTRAINT pk_van_paymentissuer PRIMARY KEY (paymentissuerid)
);
/

CREATE SEQUENCE SEQ_VAN_PAYMENTISSUERID NOCACHE;
/

CREATE TABLE VAN_IDENTITYROLECCALIAS (
  identityroleccaliasid NUMBER(*,0) NOT NULL,
  identityroleid NUMBER(*,0) NOT NULL,
  paymentissuerid NUMBER(*,0) NOT NULL,
  creditcardalias VARCHAR2(50 BYTE) NOT NULL,
  creditcardowner VARCHAR2(100 BYTE) NOT NULL,
  creditcardnumber VARCHAR2(20 BYTE) NOT NULL,
  expirationdate DATE NOT NULL,
  CONSTRAINT pk_van_identityroleccalias PRIMARY KEY (identityroleccaliasid)
);
/

CREATE SEQUENCE SEQ_VAN_IDENTITYROLECCALIASID NOCACHE;
/

CREATE TABLE VAN_USER (
  userid NUMBER(*,0) NOT NULL,
  username VARCHAR2(64 BYTE) NOT NULL,
  lastname VARCHAR2(40 BYTE) NOT NULL,
  nameadditions VARCHAR2(10 BYTE),
  firstname VARCHAR2(20 BYTE),
  initials VARCHAR2(6 BYTE),
  gender VARCHAR2(1 BYTE),
  email VARCHAR2(100 BYTE),
  "PASSWORD" VARCHAR2(64 BYTE),
  "ACTIVE" CHAR NOT NULL,
  stocklocationid NUMBER(*,0) NOT NULL,
  roaming CHAR NOT NULL,
  stockroaming CHAR NOT NULL,
  stockstocklocationid NUMBER(*,0) NOT NULL,
  hashpin VARCHAR2(256 BYTE) NOT NULL,
  hashpassword VARCHAR2(256 BYTE) NOT NULL,
  lastlogin DATE,
  employeenumber VARCHAR2(6 BYTE),
  mobile VARCHAR2(20 BYTE),
  systemuser CHAR NOT NULL,
  teamid NUMBER(*,0),
  expirydate DATE,
  customerid NUMBER(*,0),
  CONSTRAINT pk_van_user PRIMARY KEY (userid)
);
/

CREATE SEQUENCE SEQ_VAN_USERID NOCACHE;
/

CREATE TABLE VAN_CARRIERDROPOFFLOCATION (
  carrierdropofflocationid NUMBER(*,0) NOT NULL,
  shipmentcarrierid NUMBER(*,0) NOT NULL,
  carrierdropofflocationname VARCHAR2(60 BYTE) NOT NULL,
  carrierdropofflocationcode VARCHAR2(20 BYTE) NOT NULL,
  street VARCHAR2(30 BYTE) NOT NULL,
  streetnr VARCHAR2(6 BYTE) NOT NULL,
  streetnraddition VARCHAR2(6 BYTE),
  busnr VARCHAR2(5 BYTE),
  postalcode VARCHAR2(8 BYTE) NOT NULL,
  city VARCHAR2(30 BYTE) NOT NULL,
  countryid NUMBER(*,0) NOT NULL,
  telephone VARCHAR2(20 BYTE),
  carrierdropofflocationtypeid NUMBER(*,0) NOT NULL,
  shipmentcarriergroupid NUMBER(*,0) NOT NULL,
  CONSTRAINT pk_van_carrierdropofflocation PRIMARY KEY (carrierdropofflocationid)
);
/

CREATE TABLE VAN_CARRIERDROPOFFLOCATIONTYPE (
  carrierdropofflocationtypeid NUMBER(*,0) NOT NULL,
  carrierdropofflocationtype VARCHAR2(20 BYTE) NOT NULL,
  CONSTRAINT pk_van_carrierdropofflocationt PRIMARY KEY (carrierdropofflocationtypeid)
);
/

CREATE TABLE VAN_SIMCUSTOMER (
  simcustomerid NUMBER(*,0) NOT NULL,
  companyid NUMBER(*,0),
  identityroleid NUMBER(*,0),
  customerid NUMBER(*,0),
  email VARCHAR2(100 BYTE) NOT NULL,
  optin CHAR NOT NULL,
  gender VARCHAR2(1 BYTE),
  nameadditions VARCHAR2(10 BYTE),
  firstname VARCHAR2(20 BYTE),
  lastname VARCHAR2(40 BYTE),
  initials VARCHAR2(6 BYTE),
  b2bcustomer CHAR NOT NULL,
  dateofbirth DATE,
  telephone VARCHAR2(20 BYTE),
  confirmed CHAR NOT NULL,
  companyname VARCHAR2(40 BYTE),
  firstnewsletteroptindate DATE,
  firstnewsletteroptinsourceid NUMBER(*,0),
  languageid NUMBER(*,0) DEFAULT null NOT NULL,
  CONSTRAINT pk_van_simcustomer PRIMARY KEY (simcustomerid)
);
/

CREATE SEQUENCE SEQ_VAN_SIMCUSTOMERID NOCACHE;
/

CREATE TABLE VAN_SIMCUSTOMERCOMMUNICATION (
  simcustomercommunicationid NUMBER(*,0) NOT NULL,
  simcustomerid NUMBER(*,0) NOT NULL,
  simcommunicationtypeid NUMBER(*,0) NOT NULL,
  "ACTIVE" CHAR NOT NULL,
  CONSTRAINT pk_van_simcustomercommunicatio PRIMARY KEY (simcustomercommunicationid)
);
/

CREATE TABLE VAN_SIMCOMMUNICATIONTYPE (
  simcommunicationtypeid NUMBER(*,0) NOT NULL,
  simcommunicationtype VARCHAR2(100 BYTE) NOT NULL,
  "ACTIVE" CHAR NOT NULL,
  activedefault CHAR NOT NULL,
  CONSTRAINT pk_van_simcommunicationtype PRIMARY KEY (simcommunicationtypeid)
);
/

CREATE TABLE VAN_PENDINGPAYMENT
(
  pendingpaymentid       INTEGER not null,
  paymentmethodid        INTEGER not null,
  pendingpaymentdatetime DATE not null,
  currencyid             INTEGER not null,
  amount                 NUMBER(14,5) not null,
  amountlocal            NUMBER(14,5) not null,
  roundamount            NUMBER(14,5) not null,
  userid                 INTEGER not null,
  paymentid              INTEGER,
  invoiceid              INTEGER,
  orderid                INTEGER,
  customerid             INTEGER,
  paymentreference       VARCHAR2(50),
  paymentsubreference    VARCHAR2(50),
  stocklocationid        INTEGER,
  invitetopayid          NUMBER,
  paymenttransactionid   INTEGER,
  CONSTRAINT pk_van_pendingpayment PRIMARY KEY (pendingpaymentid)
);
/

create table VAN_ORDER
(
  orderid                    INTEGER not null,
  ipaddress                  VARCHAR2(15),
  customerid                 INTEGER not null,
  shopoutletid               INTEGER not null,
  paymentmethodid            INTEGER not null,
  currencyid                 INTEGER not null,
  discount                   NUMBER(14,5) not null,
  paymentdiscount            NUMBER(14,5) not null,
  discountvatid              INTEGER not null,
  orderdatetime              DATE not null,
  userid                     INTEGER not null,
  shipmentaddressid          INTEGER not null,
  invoiceaddressid           INTEGER not null,
  shipmentmethodid           INTEGER not null,
  paymentcost                NUMBER(14,5) not null,
  paymentcostvatid           INTEGER not null,
  shipmentcost               NUMBER(14,5) not null,
  shipmentcostvatid          INTEGER not null,
  vatfree                    CHAR(1) not null,
  deleted                    CHAR(1) not null,
  shipdate                   DATE,
  pickupdate                 DATE,
  expiredate                 DATE,
  allowpacking               CHAR(1) default 'N' not null,
  shopoutletorderid          INTEGER,
  customerreference          VARCHAR2(100),
  vatfreereasonid            INTEGER,
  pickupreadydatetime        DATE,
  stocklocationidx           INTEGER,
  prioritypreparedatetime    DATE,
  originatingorderid         INTEGER,
  communicateddeliverydate   DATE,
  assistuserid               INTEGER,
  shipmentcarrieridx         INTEGER,
  invoicedeliverymethodid    INTEGER not null,
  stockclaimfromdate         DATE,
  referrerid                 VARCHAR2(50),
  cartid                     INTEGER,
  allocationenddatetime      DATE,
  orderlinehash              VARCHAR2(40),
  shoppingcartid             INTEGER,
  actualpickupdatetime       DATE,
  carrierdropofflocationid   INTEGER,
  shipmentcarriergroupid     INTEGER,
  stockclusterid             INTEGER,
  forcedstocklocationid      INTEGER,
  deleteduserid              INTEGER,
  deleteddatetime            DATE,
  deliverydate               DATE,
  ipv6address                VARCHAR2(39),
  closedcommunitydiscountid  INTEGER,
  customermessage            VARCHAR2(4000),
  forcedshipmentcarriergrpid INTEGER,
  languageid                 INTEGER not null,
  saleschannelid             INTEGER,
  visittimeslotid            INTEGER,
  lastmodificationdatetime   DATE
);
/

create table VAN_INVOICE
(
  invoiceid                INTEGER not null,
  fiscalinvoiceid          INTEGER,
  customerid               INTEGER not null,
  shopid                   INTEGER not null,
  invoicedate              DATE not null,
  currencyid               INTEGER not null,
  vatfree                  CHAR(1) not null,
  discount                 NUMBER(14,5) not null,
  paymentdiscount          NUMBER(14,5) not null,
  discountvatid            INTEGER not null,
  lastname                 VARCHAR2(40),
  firstname                VARCHAR2(20),
  nameadditions            VARCHAR2(10),
  initials                 VARCHAR2(6),
  gender                   VARCHAR2(1) not null,
  company                  VARCHAR2(40),
  street                   VARCHAR2(30),
  streetnr                 VARCHAR2(6),
  streetnraddition         VARCHAR2(6),
  postalcode               VARCHAR2(8),
  city                     VARCHAR2(30),
  countryid                INTEGER,
  paymentmethodid          INTEGER,
  paymentduedate           DATE not null,
  userid                   INTEGER not null,
  creditinvoiceid          INTEGER,
  paymentcost              NUMBER(14,5) not null,
  paymentcostvatid         INTEGER not null,
  shipmentcost             NUMBER(14,5) not null,
  shipmentcostvatid        INTEGER not null,
  vatnumber                VARCHAR2(20),
  customerreference        VARCHAR2(100),
  subsidiaryid             INTEGER not null,
  remarks                  VARCHAR2(4000),
  addressaddition          VARCHAR2(40),
  lastprintdate            DATE,
  companyvatnumber         VARCHAR2(20),
  companycocnumber         VARCHAR2(50),
  companybanknumber        VARCHAR2(34),
  shopaddressid            INTEGER,
  fiscalrepresentcheck     CHAR(1),
  busnr                    VARCHAR2(5),
  vatfreereasonid          INTEGER,
  onhold                   CHAR(1),
  b2bcustomer              CHAR(1) not null,
  exportcustomer           CHAR(1) not null,
  creationdatetime         DATE,
  lastmodificationdatetime DATE
);
/

CREATE TABLE van_invitetopay (
  invitetopayid NUMBER(*,0) NOT NULL,
  invitetopaystateid NUMBER(*,0) NOT NULL,
  uniquereference CHAR(8 BYTE) NOT NULL,
  shopid NUMBER(*,0) NOT NULL,
  currencyid NUMBER(*,0) NOT NULL,
  amount NUMBER(14,5) NOT NULL,
  expirydatetime DATE NOT NULL,
  orderid NUMBER(*,0),
  invoiceid NUMBER(*,0),
  customerid NUMBER(*,0),
  customerinformation VARCHAR2(4000 BYTE),
  invitationuserid NUMBER(*,0) NOT NULL,
  invitationdatetime DATE NOT NULL,
  confirmationdatetime DATE,
  allowpaymentcost CHAR NOT NULL,
  leavepaymentmethod CHAR NOT NULL,
  sendsms CHAR DEFAULT 'N' NOT NULL,
  smsnumber VARCHAR2(200 BYTE),
  CONSTRAINT pk_van_invitetopay PRIMARY KEY (invitetopayid)
);
/

CREATE TABLE van_adyensepacontract (
  adyensepacontractid NUMBER(*,0) NOT NULL,
  initialinvitetopayid NUMBER(*,0) NOT NULL,
  contractdetailreference VARCHAR2(30 BYTE) NULL,
  startdate DATE NULL,
  expirationdate DATE NOT NULL,
  recurringamount NUMBER(14,5) NOT NULL,
  active CHAR DEFAULT 'N' NOT NULL,
  creationdatetime DATE DEFAULT sysdate NOT NULL,
  lastmodificationdatetime date null,
  CONSTRAINT pk_van_adyensepacontract PRIMARY KEY (adyensepacontractid)
);
/

COMMENT ON TABLE van_adyensepacontract IS 'Stores Adyen SEPA recurring payment contract identifiers';
COMMENT ON COLUMN van_adyensepacontract.adyensepacontractid IS 'Unique Adyen SEPA contract identifier';
COMMENT ON COLUMN van_adyensepacontract.initialinvitetopayid IS 'Foreign key to the invite to pay that initiated the contract.';
COMMENT ON COLUMN van_adyensepacontract.contractdetailreference IS 'Unqiue contract identifier generated by Adyen.';
COMMENT ON COLUMN van_adyensepacontract.startdate IS 'The start date of the contract.';
COMMENT ON COLUMN van_adyensepacontract.expirationdate IS 'The expiration date of the recurring payment.';
COMMENT ON COLUMN van_adyensepacontract.recurringamount IS 'The monthly amount to charge to the customer with the contract';
COMMENT ON COLUMN van_adyensepacontract.active IS 'Indicates whether the contract is currently active';
COMMENT ON COLUMN van_adyensepacontract.creationdatetime IS 'Record creation date and time';
COMMENT ON COLUMN van_adyensepacontract.lastmodificationdatetime IS 'Last record modification datetime';

CREATE TABLE van_paymenttransaction (
  paymenttransactionid        INTEGER not null,
  pendingpaymenttransactionid INTEGER not null,
  amount                      NUMBER(14,5) not null,
  description                 VARCHAR2(50),
  reference                   VARCHAR2(50),
  orderid                     INTEGER,
  invitetopayid               INTEGER,
  paymentmethodid             INTEGER,
  closed                      CHAR(1) not null,
  CONSTRAINT pk_van_paymenttransaction PRIMARY KEY (paymenttransactionid)
);
/

create table VAN_REFUNDPAYMENT
(
  refundpaymentid          INTEGER not null,
  userid                   INTEGER not null,
  refunddatetime           DATE not null,
  settlependingpaymentid   INTEGER,
  settlepaymentid          INTEGER,
  refundstateid            INTEGER,
  refundinfo               VARCHAR2(4000),
  refundfeedback           VARCHAR2(4000),
  creationdatetime         DATE default sysdate not null,
  lastmodificationdatetime DATE,
  paymentid                INTEGER not null,
  refundstageid            INTEGER not null,
  CONSTRAINT pk_van_refundpayment PRIMARY KEY (refundpaymentid)
);
/

create or replace package VAN_PKG_REFUND as
  procedure PRC_DENYREFUNDPAYMENT(P_REFUNDPAYMENTID in VAN_REFUNDPAYMENT.REFUNDPAYMENTID%type, P_REASON in varchar2 default null);
end VAN_PKG_REFUND;
/

create or replace package body VAN_PKG_REFUND as
  procedure PRC_DENYREFUNDPAYMENT(P_REFUNDPAYMENTID in VAN_REFUNDPAYMENT.REFUNDPAYMENTID%type, P_REASON in varchar2 default null)
  is
    cursor C_REFUND
    is
      select 
        rp.REFUNDINFO
      from 
        VAN_REFUNDPAYMENT rp 
      where 
        REFUNDPAYMENTID = P_REFUNDPAYMENTID;
        
    R_REFUND C_REFUND%rowtype;

  begin
     open C_REFUND;
     fetch C_REFUND into R_REFUND;
     close C_REFUND;
     
     update 
       VAN_REFUNDPAYMENT
     set 
       REFUNDSTAGEID = 5 /*Refund failed*/,
	   REFUNDINFO = P_REASON
     where 
       REFUNDPAYMENTID = P_REFUNDPAYMENTID;
     commit;
     
  end PRC_DENYREFUNDPAYMENT;

end VAN_PKG_REFUND;
/