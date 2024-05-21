WITH
-- Task 1: Extract and Clean Data
extracted_users AS (
  SELECT *
  FROM SQLII.RAW_DATA.USERS
  ORDER BY USER_ID
),
extracted_rx_orders AS (
  SELECT *
  FROM SQLII.RAW_DATA.RX_ORDERS
  ORDER BY USER_ID
),
extracted_appointments AS (
  SELECT *
  FROM SQLII.RAW_DATA.APPOINTMENTS
  WHERE USER_ID IS NOT NULL -- remove invalid records
  ORDER BY USER_ID
),

-- Task 2: De-duplicated Appointments
appointment_status AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY user_id, appointment_date ORDER BY created_date DESC) AS rn -- the most recent row with latest status for each appointment
  FROM extracted_appointments
),

final_appointment_status AS (
  SELECT *
  FROM appointment_status
  WHERE rn = 1
),

-- Task 3: Finding the first Completed appointment per user
ranked_completed_appts AS (
  SELECT *
  FROM (
    SELECT 
      *,
      ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY appointment_date) AS rn_first_appt
    FROM final_appointment_status -- using the CTE you created above
    WHERE appointment_status = 'Completed'
  ) a
  WHERE rn_first_appt = 1
),

-- Task 4: Finding the first Prescription Order after the completed appointment
first_orders AS (
  SELECT 
    ro.user_id,
    ro.order_id,
    ro.order_date,
    ro.order_value,
    ROW_NUMBER() OVER (PARTITION BY ro.user_id ORDER BY ro.order_date) AS row_num
  FROM SQLII.RAW_DATA.RX_ORDERS ro
  JOIN ranked_completed_appts rca ON ro.user_id = rca.user_id
  WHERE ro.order_date > rca.appointment_date
),

first_order_per_user AS (
  SELECT *
  FROM first_orders
  WHERE row_num = 1
),

-- Combining Insights into with_appts
with_appts AS (
  SELECT extracted_users.user_id,
         extracted_users.created_at::date AS user_sign_up_date,
         rca.appointment_date AS first_appointment_completed_date
  FROM extracted_users
  JOIN ranked_completed_appts rca
  ON rca.user_id = extracted_users.user_id
  ORDER BY 1, 2, 3
),

-- Combining Insights into with_orders
with_orders AS (
  SELECT eu.user_id,
         eu.user_sign_up_date,
         wa.first_appointment_completed_date,
         fo.order_id AS first_rx_order_number,
         fo.order_value,
         fo.order_date AS first_rx_order_date
  FROM extracted_users eu
  LEFT JOIN with_appts wa ON wa.user_id = eu.user_id
  LEFT JOIN first_order_per_user fo ON eu.user_id = fo.user_id
),

-- Aggregating Orders
with_orders_agg AS (
  SELECT user_id, 
         user_sign_up_date, 
         first_appointment_completed_date,
         first_rx_order_number, 
         SUM(order_value) AS first_order_value, 
         first_rx_order_date
  FROM with_orders
  GROUP BY user_id, user_sign_up_date, first_appointment_completed_date, first_rx_order_number, first_rx_order_date
  ORDER BY 1
),

-- Calculating Turnaround Times
final AS (
  SELECT *,
         DATE_TRUNC('week', user_sign_up_date)::date AS signup_week,
         DATEDIFF('day', user_sign_up_date, first_appointment_completed_date) AS first_appointment_tat,
         DATEDIFF('day', first_appointment_completed_date, first_rx_order_date) AS first_rx_order_tat
  FROM with_orders_agg
  ORDER BY 1
)

-- Create the view
CREATE OR REPLACE VIEW WORKSPACE_FEYISAYO.PUBLIC.first_user_journey AS
SELECT *
FROM final;

-- Verify the view creation
SELECT * 
FROM WORKSPACE_FEYISAYO.PUBLIC.first_user_journey
ORDER BY user_id
LIMIT 10;

-- Create the final operational metrics view
CREATE OR REPLACE VIEW WORKSPACE_FEYISAYO.PUBLIC.first_user_journey_weekly AS
SELECT 
    signup_week, 
    COUNT(user_id) AS users_signed_up,
    ROUND(AVG(first_appointment_tat), 2) AS avg_days_to_first_appointment,
    ROUND(AVG(first_rx_order_tat), 2) AS avg_days_to_first_rx_order,
    ROUND(COUNT(first_appointment_tat) * 100.0 / COUNT(*), 2) AS pct_users_with_appointment,
    ROUND(COUNT(first_rx_order_number) * 100.0 / COUNT(*), 2) AS pct_users_with_rx_order,
    ROUND(AVG(first_order_value), 2) AS avg_first_order_value
FROM WORKSPACE_FEYISAYO.PUBLIC.first_user_journey 
GROUP BY signup_week
ORDER BY signup_week DESC;

-- Verify the view creation
SELECT * 
FROM WORKSPACE_FEYISAYO.PUBLIC.first_user_journey_weekly
ORDER BY signup_week DESC;
