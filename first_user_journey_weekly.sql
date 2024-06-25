create or replace view WORKSPACE_FEYISAYO.PUBLIC.FIRST_USER_JOURNEY_WEEKLY (
	USER_SIGNUP_WEEK,
	USERS_SIGNED_UP,
	AVG_DAYS_TO_FIRST_APPOINTMENT,
	AVG_DAYS_TO_FIRST_RX_ORDER,
	PCT_USERS_WITH_APPOINTMENT,
	PCT_USERS_WITH_RX_ORDER,
	AVG_FIRST_ORDER_VALUE
) as
(
SELECT 
    user_signup_week, 
    COUNT(USER_ID) AS users_signed_up,
    ROUND(AVG(first_appointment_tat), 2) AS avg_days_to_first_appointment,
    ROUND(AVG(first_rx_order_tat), 2) AS avg_days_to_first_rx_order,
    ROUND(COUNT(first_appointment_completed_date) * 100.0 / COUNT(*), 2) AS pct_users_with_appointment,
    ROUND(COUNT(first_rx_order_number) * 100.0 / COUNT(*), 2) AS pct_users_with_rx_order,
    ROUND(AVG(first_order_value), 2) AS avg_first_order_value
FROM WORKSPACE_FEYISAYO.PUBLIC.first_user_journey 
GROUP BY user_signup_week
ORDER BY user_signup_week DESC
)
