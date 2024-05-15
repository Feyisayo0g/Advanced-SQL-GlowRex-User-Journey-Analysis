# HealthTech-Company-User-Journey-Analysis
A Comprehensive Report on User Engagement and Operational Efficiency

### Introduction
HealthTech Company, a leader in dermatological care, offers personalized skincare through telehealth appointments and quarterly product deliveries. The goal of this project is to analyze the user journey from sign-up to their first appointment and first Rx order, identifying key metrics and potential operational delays. This analysis will help the healthtech company improve user engagement, enhance service efficiency, and ultimately increase revenue by providing actionable insights into user behavior.

### Methodology
- Data Collection: Data was collected from the SQLII database, RAW_DATA schema, which includes the users, appointments, and rx_orders tables.
- Data Cleaning: Removed invalid records (e.g., null user_id).
- Deduplication: Ensured only the latest status for each appointment and identified the first completed appointment and first Rx order for each user.
- Metrics Calculation: Calculated key metrics such as average time to first appointment, average time to first Rx order, and percentages of users completing each step.
- Rationale: The final report structure was designed to provide comprehensive insights into user behavior and service efficiency. By focusing on key milestones in the user journey, GlowRex can identify and address potential delays or inefficiencies, improving overall user satisfaction and retention.

### Data Analysis
- User Signup and Appointment Analysis:
  ``` sql
  # CTE definition
  WITH extracted_users AS (
    SELECT 
        user_id,
        created_at::date AS signup_date,
        DATE_TRUNC('week', created_at)::date AS signup_week
    FROM 
        SQLII.RAW_DATA.USERS
),
```
``` sql
with_appts AS (
    SELECT 
        ap.user_id,
        MIN(ap.appointment_date)::date AS first_appointment_date,
        DATEDIFF(day, eu.signup_date, MIN(ap.appointment_date)) AS first_appointment_tat
    FROM 
        SQLII.RAW_DATA.APPOINTMENTS ap
    JOIN 
        extracted_users eu ON eu.user_id = ap.user_id
    WHERE 
        ap.appointment_status = 'Completed'
    GROUP BY 
        ap.user_id, eu.signup_date
)
```
- First Rx Order Analysis:
``` sql
#CTE definition
WITH first_orders AS (
    SELECT 
        fo.user_id,
        MIN(fo.transaction_date)::date AS first_rx_order_date,
        MIN(fo.order_number) AS first_rx_order_number,
        SUM(fo.item_amount) AS first_order_value,
        DATEDIFF(day, wa.first_appointment_date, MIN(fo.transaction_date)) AS first_rx_order_tat
    FROM 
        SQLII.RAW_DATA.RX_ORDERS fo
    JOIN 
        with_appts wa ON wa.user_id = fo.user_id
    GROUP BY 
        fo.user_id, wa.first_appointment_date
)
```
- Final Aggregated Metrics:
  ``` sql
  SELECT 
    signup_week, 
    COUNT(user_id) AS users_signed_up,
    ROUND(AVG(first_appointment_tat), 2) AS avg_days_to_first_appointment,
    ROUND(AVG(first_rx_order_tat), 2) AS avg_days_to_first_rx_order,
    ROUND(COUNT(first_appointment_date) * 100.0 / COUNT(user_id), 2) AS pct_users_with_appointment,
    ROUND(COUNT(first_rx_order_number) * 100.0 / COUNT(user_id), 2) AS pct_users_with_rx_order,
    ROUND(AVG(first_order_value), 2) AS avg_first_order_value
  ```
### Results
Key Metrics:
- Users Signed Up Each Week: Varied between 11 and 142.
- Average Days to First Appointment: Ranged from 25 to 49.88 days.
- Average Days to First Rx Order: Consistently between 4.26 and 11.07 days.
- Percentage of Users with Appointments: High, between 89.29% and 100%.
- Percentage of Users with Rx Orders: Between 69.64% and 90.63%.
- Average First Order Value: Ranged from $243.44 to $415.89.
  
### Notable Trends:
- Shorter wait times for appointments correlated with higher first order values.
- Weeks with the quickest access to appointments saw higher user engagement and spending.

### Conclusion
There is a clear correlation between shorter wait times for appointments and higher average first order values. Users are more likely to make higher-value purchases when they experience prompt appointments.

### Recommendations:
- Optimize Appointment Scheduling: Implement strategies to reduce appointment wait times, such as expanding availability and using automated scheduling.
- Enhance Follow-Up: Strengthen follow-up communications to maintain engagement and encourage order placement.
- Monitor and Adjust: Continuously monitor key metrics to quickly identify and address any operational inefficiencies.
- Improve Perceived Value: Emphasize the benefits of quick appointments and effective treatments in marketing to attract and retain users.


  


