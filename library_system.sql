-- Drop tables if they exist
DROP TABLE Library;
DROP TABLE Student;
DROP TABLE Staff;
DROP TABLE Book;

-- Create Library Table
CREATE TABLE Library (
    Library_Name VARCHAR(20),
    Location VARCHAR(20),
    Telephone NUMBER(10),
    E_mail VARCHAR(50),
    CONSTRAINT Library_ID_pk PRIMARY KEY (Library_Name)		
);

-- Create Student Table
CREATE TABLE Student (
    Student_ID NUMBER(20),
    Student_Name VARCHAR(20),
    Grade NUMBER(2),
    Telephone NUMBER(10),
    E_mail VARCHAR(50),
    CONSTRAINT Student_ID_pk PRIMARY KEY (Student_ID)
);

-- Create Staff Table
CREATE TABLE Staff (
    Staff_ID NUMBER(3),
    Staff_Name VARCHAR(20),
    Position VARCHAR(20),
	Telephone NUMBER(10),
    E_mail VARCHAR(50),
    CONSTRAINT Staff_ID_pk PRIMARY KEY (Staff_ID)
);

-- Create Book Table
CREATE TABLE Book (
    Book_ID NUMBER(4),
    Title VARCHAR(200),
    Author VARCHAR(50),
    Publisher VARCHAR(20),
    Quantity NUMBER(3),
    CONSTRAINT Book_ID_pk PRIMARY KEY (Book_ID)
);

-- Create Transactions Table
CREATE TABLE Transactions (
    Transactions_ID NUMBER(20),
    Book_ID NUMBER(4),
    Student_ID NUMBER(3),
    Staff_ID NUMBER(3),
	Transaction_Type VARCHAR(10),
    Borrow_Date TIMESTAMP,
    Return_Date TIMESTAMP,
	
    CONSTRAINT Transactions_ID_pk PRIMARY KEY (Transactions_ID),
    CONSTRAINT Transactions_fk_Book FOREIGN KEY (Book_ID) REFERENCES Book(Book_ID),
    CONSTRAINT Transactions_fk_Student FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    CONSTRAINT Transactions_fk_Staff FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

DESC Library
DESC Student
DESC Book

INSERT INTO Library ( Library_Name, Location, Telephone, E_mail )VALUES ( 'WK_Library', ' West Kowloon',12345678,'123@gmail.com' );
INSERT INTO Library ( Library_Name, Location, Telephone, E_mail )VALUES ('HHB_Library', 'Hung HOM Bay',12345679,'124@gmail.com');
INSERT INTO Library ( Library_Name, Location, Telephone, E_mail )VALUES ('TSW_Library','Tin Shui Wai',12345670,'125@gmail.com');
INSERT INTO Library ( Library_Name, Location, Telephone, E_mail )VALUES ('TM_Library','Tuen Mun',12345680,'126@gmail.com');
INSERT INTO Library ( Library_Name, Location, Telephone, E_mail )VALUES ('ST_Library','Sha Tin',12345666,'127@gmail.com');


INSERT INTO Student (Student_ID, Student_Name, Grade , Telephone, E_mail )VALUES (100, 'Mary' ,1,34567812,'543@gmail.com' );
INSERT INTO Student (Student_ID, Student_Name, Grade , Telephone, E_mail )VALUES (101, 'May' ,3,34567813,'542@gmail.com' );
INSERT INTO Student (Student_ID, Student_Name, Grade , Telephone, E_mail )VALUES (102, 'Malloy' ,4,34567814,'541@gmail.com' );
INSERT INTO Student (Student_ID, Student_Name, Grade , Telephone, E_mail )VALUES (103, 'Maria' ,2,34567815,'544@gmail.com' );
INSERT INTO Student (Student_ID, Student_Name, Grade , Telephone, E_mail )VALUES (104, 'Macy' ,1,34567816,'545@gmail.com' );

INSERT INTO Staff (Staff_ID, Staff_Name, Position , Telephone, E_mail )VALUES (10, 'Tom' ,'Chief Librarian',87654321,'321@gmail.com' );
INSERT INTO Staff (Staff_ID, Staff_Name, Position , Telephone, E_mail )VALUES (11,'Tim', 'Assistant Librarian',87654322,'322@gmail.com');
INSERT INTO Staff (Staff_ID, Staff_Name, Position , Telephone, E_mail )VALUES (12,'Tommy','Library Assistant',87654323,'323@gmail.com');
INSERT INTO Staff (Staff_ID, Staff_Name, Position , Telephone, E_mail )VALUES (13,'Tony','Library Assistant',87654324,'324@gmail.com');
INSERT INTO Staff (Staff_ID, Staff_Name, Position , Telephone, E_mail )VALUES (14,'Tristian','Library Assistant',87654325,'325@gmail.com');

INSERT INTO Book (Book_ID, Title, Author, Publisher,  Quantity)VALUES (1001, 'International Business: Concepts, Cases and Exercises' ,'Frank F.Cotae','Routledge',10 );
INSERT INTO Book (Book_ID, Title, Author, Publisher,  Quantity)VALUES (1002, "Policy Solutions for Economic Growth in a Developing Country: Perspectives on Afghanistan's Trade and Development" ,'Nassir Ul Haq Wani','Emerald Group Pub',10 );
INSERT INTO Book (Book_ID, Title, Author, Publisher,  Quantity)VALUES (1003, 'Mastering Screenplay Form and Style' ,'Mick Hurbis-Cherrier','Focal Pr',10 );
INSERT INTO Book (Book_ID, Title, Author, Publisher,  Quantity)VALUES (1004, 'My English Language Journey' ,'Ghassoub Sharif Mustafa','Austin Macauley',10 );
INSERT INTO Book (Book_ID, Title, Author, Publisher,  Quantity)VALUES (1005, 'Unexpected: The Autobiography' ,'Greg Rutherford','Simon & Schuster Ltd',10 );

select * from Library;
select * from Student;
select * from Staff;
select * from Book;

-- Create the trigger
CREATE OR REPLACE TRIGGER enforce_quantity_constraint
BEFORE INSERT ON transactions
FOR EACH ROW
DECLARE
    v_current_quantity NUMBER;
BEGIN
    -- Get the current quantity of the book
    SELECT Quantity INTO v_current_quantity
    FROM Book
    WHERE Book_ID = :NEW.Book_ID;

    -- Check if the transaction is a borrow operation
    IF :NEW.Transaction_Type = 'BORROW' THEN
        -- Ensure there are enough available copies to borrow
        IF v_current_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'No available copies of this book.');
        END IF;
    END IF;
END;
/

-- Create Sequence for Transaction IDs
CREATE SEQUENCE transaction_seq
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  NOCACHE
  NOCYCLE;

-- Package Specification
CREATE OR REPLACE PACKAGE library_system AS
  PROCEDURE borrow_book(
    p_book_id IN NUMBER,
    p_student_id IN NUMBER,
    p_staff_id IN NUMBER
  );

  PROCEDURE return_book(
    p_transaction_id IN NUMBER
  );

  FUNCTION get_available_books RETURN SYS_REFCURSOR;

  FUNCTION get_borrowed_books(
    p_student_id IN NUMBER
  ) RETURN SYS_REFCURSOR;
END library_system;
/

-- Package Body
CREATE OR REPLACE PACKAGE BODY library_system AS
  PROCEDURE borrow_book(
    p_book_id IN NUMBER,
    p_student_id IN NUMBER,
    p_staff_id IN NUMBER
  ) AS
  BEGIN

    -- Insert a new transaction record
    INSERT INTO transactions (Transactions_ID, Book_ID, Student_ID, Staff_ID, Transaction_Type, Borrow_Date, Return_Date)
    VALUES (transaction_seq.NEXTVAL, p_book_id, p_student_id, p_staff_id, 'BORROW', SYSTIMESTAMP, NULL);
    
	 -- Decrease the quantity of the book
    UPDATE Book
    SET Quantity = Quantity - 1
    WHERE Book_id = p_book_id;
	
	
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END borrow_book;

  PROCEDURE return_book(
    p_transaction_id IN NUMBER
  ) AS
  BEGIN
    -- Update the transaction record with return information
    UPDATE Transactions
    SET Transaction_Type = 'RETURN',
        Return_Date = SYSTIMESTAMP
    WHERE Transactions_ID = p_transaction_id;

    -- Increase the quantity of the book
    UPDATE Book
    SET Quantity = Quantity + 1
    WHERE Book_id = (SELECT Book_id FROM transactions WHERE Transactions_id = p_transaction_id);
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END return_book;


  FUNCTION get_available_books RETURN SYS_REFCURSOR AS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
    SELECT *
    FROM Book
    WHERE Quantity > 0;
    
    RETURN c;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END get_available_books;

  FUNCTION get_borrowed_books(
    p_student_id IN NUMBER
  ) RETURN SYS_REFCURSOR AS
    c SYS_REFCURSOR;
  BEGIN
    OPEN c FOR
    SELECT b.*
    FROM Book b
    INNER JOIN Transactions t ON b.Book_ID = t.Book_ID
    WHERE t.Student_ID = p_student_id;
    
    RETURN c;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END get_borrowed_books;
END library_system;
/



                                               -- Checkout Book
DECLARE
    v_student_id NUMBER;
    v_book_id NUMBER;
    v_staff_id NUMBER;
BEGIN
    -- Retrieve the IDs of the student, book, and staff
    SELECT Student_id INTO v_student_id FROM Student WHERE Student_name = 'Mary';
    SELECT Book_id INTO v_book_id FROM Book WHERE Title = 'My English Language Journey';
    SELECT Staff_id INTO v_staff_id FROM Staff WHERE staff_name = 'Tom';

    -- Execute the borrow_book procedure
    library_system.borrow_book(p_book_id => v_book_id, p_student_id => v_student_id, p_staff_id => v_staff_id);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Book borrowed successfully by Mary from staff Tom.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error borrowing book: ' || SQLERRM);
END;
/


/*                                                       -- Return Book
DECLARE 
    v_transaction_id NUMBER; 
BEGIN 
    -- Retrieve the transaction ID for the book borrowed by Mary 
    SELECT Transactions_ID INTO v_transaction_id 
    FROM Transactions t 
    JOIN Student s ON t.student_id = s.student_id 
    JOIN Book b ON t.book_id = b.book_id 
    WHERE s.Student_name = 'Mary' 
    AND t.Transaction_Type = 'BORROW' 
    AND b.Title = 'My English Language Journey'
    AND ROWNUM = 1; -- Limit the result to one row only
 
    -- Execute the return_book procedure 
    library_system.return_book(p_transaction_id => v_transaction_id); 
     
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('Book returned successfully by Mary.'); 
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('No borrowed book found for Mary.'); 
    WHEN OTHERS THEN 
        ROLLBACK; 
        DBMS_OUTPUT.PUT_LINE('Error returning book: ' || SQLERRM); 
END; 
/
*/

DESC Transactions

SELECT * FROM Transactions;


SELECT Student_Name, Grade, COUNT(*) AS Total_Books_Borrowed
FROM Student
JOIN Transactions ON Student.Student_ID = Transactions.Student_ID
WHERE Transaction_Type = 'BORROW'
GROUP BY Student_Name, Grade
HAVING COUNT(*) > 1
ORDER BY Total_Books_Borrowed DESC;

SELECT Transactions.Transactions_ID, Student.Student_Name, Book.Title, Transactions.Borrow_Date
FROM Transactions
JOIN Student ON Transactions.Student_ID = Student.Student_ID
JOIN Book ON Transactions.Book_ID = Book.Book_ID
ORDER BY Transactions.Borrow_Date DESC;

SELECT Student_Name, Grade
FROM Student
WHERE Student_ID IN (
    SELECT DISTINCT Student_ID
    FROM Transactions
    WHERE Transaction_Type = 'BORROW'
);

