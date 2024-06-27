CREATE OR REPLACE VIEW WORKSPACE_FEYISAYO.PUBLIC.first_user_journey AS
(
WITH 

-- Step 1: Extract and Clean Data

-- Extracting user data, casting USER_ID to INT, converting created_at to date, and truncating to week for weekly analysis
extracted_users AS (
  SELECT 
    USER_ID::int AS USER_ID, 
    created_at::date AS user_sign_up_date,
    DATE_TRUNC('week', created_at)::date AS user_signup_week
  FROM SQLII.RAW_DATA.USERS
),

-- Extracting prescription order data and casting USER_ID to INT
extracted_rx_orders AS (
  SELECT 
    CAST(USER_ID AS INT) AS USER_ID,
    TRANSACTION_DATE,
    ORDER_NUMBER,
    ITEM_AMOUNT
  FROM SQLII.RAW_DATA.RX_ORDERS
),

-- Extracting appointment data, casting USER_ID to INT, and filtering out invalid records
extracted_appointments AS (
  SELECT 
    CAST(USER_ID AS INT) AS USER_ID,
    APPOINTMENT_DATE,
    CREATED_DATE,
    APPOINTMENT_STATUS
  FROM SQLII.RAW_DATA.APPOINTMENTS
  WHERE USER_ID IS NOT NULL
),

-- Step 2: De-duplicated Appointments

-- Ranking appointment statuses by the latest created_date for each user and appointment_date
appointment_status_ranked AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY USER_ID, APPOINTMENT_DATE ORDER BY CREATED_DATE DESC) AS rn
  FROM extracted_appointments
),

-- Selecting the most recent appointment status for each user and appointment_date
latest_appointment_status AS (
  SELECT *
  FROM appointment_status_ranked
  WHERE rn = 1
),

-- Step 3: Finding the First Completed Appointment

-- Finding the earliest completed appointment date for each user
first_appointments AS (
  SELECT USER_ID, 
         MIN(APPOINTMENT_DATE) AS first_appointment_completed_date
  FROM latest_appointment_status
  WHERE APPOINTMENT_STATUS = 'Completed'
  GROUP BY USER_ID
),

-- Step 4: Finding the First Prescription Order after the Completed Appointment

-- Ranking orders by transaction_date and order_number for each user
ranked_orders AS (
  SELECT USER_ID, TRANSACTION_DATE, ORDER_NUMBER, ITEM_AMOUNT,
         ROW_NUMBER() OVER (PARTITION BY USER_ID ORDER BY TRANSACTION_DATE, ORDER_NUMBER) AS rn,
         DENSE_RANK() OVER (PARTITION BY USER_ID ORDER BY TRANSACTION_DATE, ORDER_NUMBER) AS dr,
         RANK() OVER (PARTITION BY USER_ID ORDER BY TRANSACTION_DATE, ORDER_NUMBER) AS r
  FROM extracted_rx_orders
),

-- Selecting the first prescription order for each user after their first completed appointment
first_orders AS (
  SELECT USER_ID, 
         ORDER_NUMBER AS first_rx_order_number,
         TRANSACTION_DATE AS first_rx_order_date,
         SUM(ITEM_AMOUNT) AS first_order_value
  FROM ranked_orders
  WHERE dr = 1
  GROUP BY USER_ID, ORDER_NUMBER, TRANSACTION_DATE
),

-- Step 5: Combining Insights

-- Combining user data with their first completed appointment and first prescription order
with_orders AS (
  SELECT extracted_users.USER_ID,
         extracted_users.user_sign_up_date,
         extracted_users.user_signup_week,
         first_appointments.first_appointment_completed_date,
         first_orders.first_rx_order_number,
         first_orders.first_order_value,
         first_orders.first_rx_order_date
  FROM extracted_users
  LEFT JOIN first_appointments ON first_appointments.USER_ID = extracted_users.USER_ID
  LEFT JOIN first_orders ON first_orders.USER_ID = first_appointments.USER_ID
),

-- Generating a summary of the user journey with calculated turnaround times
final AS (
  SELECT USER_ID, 
         user_sign_up_date,
         user_signup_week,
         DATEDIFF('day', user_sign_up_date, first_appointment_completed_date) AS first_appointment_tat,
         first_appointment_completed_date,
         DATEDIFF('day', first_appointment_completed_date, first_rx_order_date) AS first_rx_order_tat,
         first_rx_order_number,
         first_rx_order_date,
         first_order_value
  FROM with_orders
)

-- Selecting all records from the final CTE and ordering by USER_ID for a comprehensive view of the user journey
SELECT * 
FROM final
ORDER BY USER_ID
);
