Student Name: Wong Tsz Fung
Student No.: 23043094S
-- ============================================================

SET SERVEROUTPUT ON;

-- ------------------------------------------------------------
-- 1. Clean up objects from a previous run
--    Ignore ORA-00942 / ORA-02289 / ORA-04043 when absent.
-- ------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP PACKAGE library_system';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-4043) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE transaction_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-2289) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Transactions CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Library CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Student CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Staff CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Book CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE NOT IN (-942) THEN RAISE; END IF;
END;
/

-- ------------------------------------------------------------
-- 2. Create tables
-- ------------------------------------------------------------

CREATE TABLE Library (
    Library_Name VARCHAR2(20) CONSTRAINT Library_ID_pk PRIMARY KEY,
    Location     VARCHAR2(50),
    Telephone    VARCHAR2(15),
    E_mail       VARCHAR2(100)
);

CREATE TABLE Student (
    Student_ID   NUMBER(20) CONSTRAINT Student_ID_pk PRIMARY KEY,
    Student_Name VARCHAR2(50) NOT NULL,
    Grade        NUMBER(2),
    Telephone    VARCHAR2(15),
    E_mail       VARCHAR2(100)
);

CREATE TABLE Staff (
    Staff_ID   NUMBER(3) CONSTRAINT Staff_ID_pk PRIMARY KEY,
    Staff_Name VARCHAR2(50) NOT NULL,
    Position   VARCHAR2(30),
    Telephone  VARCHAR2(15),
    E_mail     VARCHAR2(100)
);

CREATE TABLE Book (
    Book_ID   NUMBER(4) CONSTRAINT Book_ID_pk PRIMARY KEY,
    Title     VARCHAR2(200) NOT NULL,
    Author    VARCHAR2(100),
    Publisher VARCHAR2(50),
    Quantity  NUMBER(3) DEFAULT 0 NOT NULL,
    CONSTRAINT Book_Quantity_ck CHECK (Quantity >= 0)
);

CREATE TABLE Transactions (
    Transactions_ID NUMBER(20) CONSTRAINT Transactions_ID_pk PRIMARY KEY,
    Book_ID         NUMBER(4) NOT NULL,
    Student_ID      NUMBER(20) NOT NULL,
    Staff_ID        NUMBER(3) NOT NULL,
    Transaction_Type VARCHAR2(10) NOT NULL,
    Borrow_Date     TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    Return_Date     TIMESTAMP,
    CONSTRAINT Transactions_fk_Book
        FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID),
    CONSTRAINT Transactions_fk_Student
        FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    CONSTRAINT Transactions_fk_Staff
        FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID),
    CONSTRAINT Transactions_Type_ck
        CHECK (Transaction_Type IN ('BORROW', 'RETURN')),
    CONSTRAINT Transactions_ReturnDate_ck
        CHECK (Return_Date IS NULL OR Return_Date >= Borrow_Date)
);

-- ------------------------------------------------------------
-- 3. Insert original sample data
-- ------------------------------------------------------------

INSERT INTO Library (Library_Name, Location, Telephone, E_mail)
VALUES ('WK_Library', 'West Kowloon', '12345678', '123@gmail.com');

INSERT INTO Library (Library_Name, Location, Telephone, E_mail)
VALUES ('HHB_Library', 'Hung Hom Bay', '12345679', '124@gmail.com');

INSERT INTO Library (Library_Name, Location, Telephone, E_mail)
VALUES ('TSW_Library', 'Tin Shui Wai', '12345670', '125@gmail.com');

INSERT INTO Library (Library_Name, Location, Telephone, E_mail)
VALUES ('TM_Library', 'Tuen Mun', '12345680', '126@gmail.com');

INSERT INTO Library (Library_Name, Location, Telephone, E_mail)
VALUES ('ST_Library', 'Sha Tin', '12345666', '127@gmail.com');

INSERT INTO Student (Student_ID, Student_Name, Grade, Telephone, E_mail)
VALUES (100, 'Mary', 1, '34567812', '543@gmail.com');

INSERT INTO Student (Student_ID, Student_Name, Grade, Telephone, E_mail)
VALUES (101, 'May', 3, '34567813', '542@gmail.com');

INSERT INTO Student (Student_ID, Student_Name, Grade, Telephone, E_mail)
VALUES (102, 'Malloy', 4, '34567814', '541@gmail.com');

INSERT INTO Student (Student_ID, Student_Name, Grade, Telephone, E_mail)
VALUES (103, 'Maria', 2, '34567815', '544@gmail.com');

INSERT INTO Student (Student_ID, Student_Name, Grade, Telephone, E_mail)
VALUES (104, 'Macy', 1, '34567816', '545@gmail.com');

INSERT INTO Staff (Staff_ID, Staff_Name, Position, Telephone, E_mail)
VALUES (10, 'Tom', 'Chief Librarian', '87654321', '321@gmail.com');

INSERT INTO Staff (Staff_ID, Staff_Name, Position, Telephone, E_mail)
VALUES (11, 'Tim', 'Assistant Librarian', '87654322', '322@gmail.com');

INSERT INTO Staff (Staff_ID, Staff_Name, Position, Telephone, E_mail)
VALUES (12, 'Tommy', 'Library Assistant', '87654323', '323@gmail.com');

INSERT INTO Staff (Staff_ID, Staff_Name, Position, Telephone, E_mail)
VALUES (13, 'Tony', 'Library Assistant', '87654324', '324@gmail.com');

INSERT INTO Staff (Staff_ID, Staff_Name, Position, Telephone, E_mail)
VALUES (14, 'Tristian', 'Library Assistant', '87654325', '325@gmail.com');

INSERT INTO Book (Book_ID, Title, Author, Publisher, Quantity)
VALUES (1001, 'International Business: Concepts, Cases and Exercises',
        'Frank F. Cotae', 'Routledge', 10);

INSERT INTO Book (Book_ID, Title, Author, Publisher, Quantity)
VALUES (1002, 'Policy Solutions for Economic Growth in a Developing Country: Perspectives on Afghanistan''s Trade and Development',
        'Nassir Ul Haq Wani', 'Emerald Group Pub', 10);

INSERT INTO Book (Book_ID, Title, Author, Publisher, Quantity)
VALUES (1003, 'Mastering Screenplay Form and Style',
        'Mick Hurbis-Cherrier', 'Focal Pr', 10);

INSERT INTO Book (Book_ID, Title, Author, Publisher, Quantity)
VALUES (1004, 'My English Language Journey',
        'Ghassoub Sharif Mustafa', 'Austin Macauley', 10);

INSERT INTO Book (Book_ID, Title, Author, Publisher, Quantity)
VALUES (1005, 'Unexpected: The Autobiography',
        'Greg Rutherford', 'Simon & Schuster Ltd', 10);

COMMIT;

-- ------------------------------------------------------------
-- 4. Trigger
--    Every inserted BORROW transaction decreases stock exactly
--    once. The UPDATE locks the relevant Book row and prevents
--    the available quantity from becoming negative.
-- ------------------------------------------------------------

CREATE OR REPLACE TRIGGER enforce_quantity_constraint
BEFORE INSERT ON Transactions
FOR EACH ROW
DECLARE
    v_rows_updated PLS_INTEGER;
BEGIN
    IF :NEW.Transaction_Type = 'BORROW' THEN
        UPDATE Book
           SET Quantity = Quantity - 1
         WHERE Book_ID = :NEW.Book_ID
           AND Quantity > 0;

        v_rows_updated := SQL%ROWCOUNT;

        IF v_rows_updated = 0 THEN
            RAISE_APPLICATION_ERROR(
                -20001,
                'Book does not exist or no available copies.'
            );
        END IF;
    END IF;
END;
/

-- ------------------------------------------------------------
-- 5. Sequence
-- ------------------------------------------------------------

CREATE SEQUENCE transaction_seq
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOCACHE
    NOCYCLE;

-- ------------------------------------------------------------
-- 6. Package specification
-- ------------------------------------------------------------

CREATE OR REPLACE PACKAGE library_system AS
    PROCEDURE borrow_book(
        p_book_id    IN NUMBER,
        p_student_id IN NUMBER,
        p_staff_id   IN NUMBER
    );

    PROCEDURE return_book(
        p_transaction_id IN NUMBER
    );

    FUNCTION get_available_books
        RETURN SYS_REFCURSOR;

    FUNCTION get_borrowed_books(
        p_student_id IN NUMBER
    ) RETURN SYS_REFCURSOR;
END library_system;
/

-- ------------------------------------------------------------
-- 7. Package body
-- ------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY library_system AS

    PROCEDURE borrow_book(
        p_book_id    IN NUMBER,
        p_student_id IN NUMBER,
        p_staff_id   IN NUMBER
    ) AS
    BEGIN
        -- The trigger decreases stock and rejects unavailable books.
        INSERT INTO Transactions (
            Transactions_ID,
            Book_ID,
            Student_ID,
            Staff_ID,
            Transaction_Type,
            Borrow_Date,
            Return_Date
        )
        VALUES (
            transaction_seq.NEXTVAL,
            p_book_id,
            p_student_id,
            p_staff_id,
            'BORROW',
            SYSTIMESTAMP,
            NULL
        );
    END borrow_book;


    PROCEDURE return_book(
        p_transaction_id IN NUMBER
    ) AS
        v_book_id Transactions.Book_ID%TYPE;
    BEGIN
        -- Lock the active borrowing record so it cannot be returned twice.
        SELECT Book_ID
          INTO v_book_id
          FROM Transactions
         WHERE Transactions_ID = p_transaction_id
           AND Transaction_Type = 'BORROW'
           AND Return_Date IS NULL
           FOR UPDATE;

        UPDATE Transactions
           SET Transaction_Type = 'RETURN',
               Return_Date = SYSTIMESTAMP
         WHERE Transactions_ID = p_transaction_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Borrowing transaction could not be updated.');
        END IF;

        UPDATE Book
           SET Quantity = Quantity + 1
         WHERE Book_ID = v_book_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'Book record not found while returning the book.');
        END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(
                -20002,
                'Transaction not found or book has already been returned.'
            );
    END return_book;


    FUNCTION get_available_books
        RETURN SYS_REFCURSOR
    AS
        c SYS_REFCURSOR;
    BEGIN
        OPEN c FOR
            SELECT *
              FROM Book
             WHERE Quantity > 0
             ORDER BY Book_ID;

        RETURN c;
    END get_available_books;


    FUNCTION get_borrowed_books(
        p_student_id IN NUMBER
    ) RETURN SYS_REFCURSOR
    AS
        c SYS_REFCURSOR;
    BEGIN
        OPEN c FOR
            SELECT b.*
              FROM Book b
              JOIN Transactions t
                ON b.Book_ID = t.Book_ID
             WHERE t.Student_ID = p_student_id
               AND t.Transaction_Type = 'BORROW'
               AND t.Return_Date IS NULL
             ORDER BY t.Borrow_Date DESC;

        RETURN c;
    END get_borrowed_books;

END library_system;
/

-- ------------------------------------------------------------
-- 8. Test: borrow a book for Mary, handled by staff member Tom
--    The trigger automatically decreases Book.Quantity by 1.
-- ------------------------------------------------------------

DECLARE
    v_student_id Student.Student_ID%TYPE;
    v_book_id    Book.Book_ID%TYPE;
    v_staff_id   Staff.Staff_ID%TYPE;
BEGIN
    SELECT Student_ID
      INTO v_student_id
      FROM Student
     WHERE Student_Name = 'Mary';

    SELECT Book_ID
      INTO v_book_id
      FROM Book
     WHERE Title = 'My English Language Journey';

    SELECT Staff_ID
      INTO v_staff_id
      FROM Staff
     WHERE Staff_Name = 'Tom';

    library_system.borrow_book(
        p_book_id    => v_book_id,
        p_student_id => v_student_id,
        p_staff_id   => v_staff_id
    );

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Book borrowed successfully by Mary from staff Tom.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error borrowing book: ' || SQLERRM);
        RAISE;
END;
/

-- ------------------------------------------------------------
-- 9. Optional test: return the latest active borrowing record
--    Uncomment this block only when you want to test returning.
-- ------------------------------------------------------------

/*
DECLARE
    v_transaction_id Transactions.Transactions_ID%TYPE;
BEGIN
    SELECT Transactions_ID
      INTO v_transaction_id
      FROM (
            SELECT Transactions_ID
              FROM Transactions
             WHERE Student_ID = 100
               AND Book_ID = 1004
               AND Transaction_Type = 'BORROW'
               AND Return_Date IS NULL
             ORDER BY Borrow_Date DESC
           )
     WHERE ROWNUM = 1;

    library_system.return_book(v_transaction_id);
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Book returned successfully by Mary.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No active borrowing record found for Mary.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error returning book: ' || SQLERRM);
        RAISE;
END;
/
*/

-- ------------------------------------------------------------
-- 10. Original and useful verification queries
-- ------------------------------------------------------------

DESC Library;
DESC Student;
DESC Staff;
DESC Book;
DESC Transactions;

SELECT * FROM Library ORDER BY Library_Name;
SELECT * FROM Student ORDER BY Student_ID;
SELECT * FROM Staff ORDER BY Staff_ID;
SELECT * FROM Book ORDER BY Book_ID;
SELECT * FROM Transactions ORDER BY Transactions_ID;

-- Students with more than one currently active borrowing transaction
SELECT s.Student_Name,
       s.Grade,
       COUNT(*) AS Total_Books_Borrowed
  FROM Student s
  JOIN Transactions t
    ON s.Student_ID = t.Student_ID
 WHERE t.Transaction_Type = 'BORROW'
   AND t.Return_Date IS NULL
 GROUP BY s.Student_Name, s.Grade
HAVING COUNT(*) > 1
 ORDER BY Total_Books_Borrowed DESC;

-- Transaction history
SELECT t.Transactions_ID,
       s.Student_Name,
       b.Title,
       t.Transaction_Type,
       t.Borrow_Date,
       t.Return_Date
  FROM Transactions t
  JOIN Student s
    ON t.Student_ID = s.Student_ID
  JOIN Book b
    ON t.Book_ID = b.Book_ID
 ORDER BY t.Borrow_Date DESC;

-- Students who have borrowed at least one book (including past borrowing)
SELECT Student_Name, Grade
  FROM Student
 WHERE Student_ID IN (
       SELECT DISTINCT Student_ID
         FROM Transactions
        WHERE Transaction_Type IN ('BORROW', 'RETURN')
 )
 ORDER BY Student_ID;

-- Current available books
SELECT Book_ID, Title, Quantity
  FROM Book
 WHERE Quantity > 0
 ORDER BY Book_ID;

COMMIT;

PROMPT Library Management System setup and test completed.
