# Glowrex-User-Journey-Analysis
A Comprehensive Report on User Engagement and Operational Efficiency

### Introduction
GlowRex stands at the forefront of dermatological care by offering a service designed to enhance users' skincare routines with expert guidance. Upon registering for a GlowRex membership, individuals embark on a personalized skincare journey, beginning with an initial telehealth appointment scheduled with a certified dermatologist. This allows the dermatologist to tailor a skincare regimen specifically to the user's unique needs, recommending specialized products. Following this personalized recommendation, users purchase the suggested products, which are then conveniently delivered to them on a quarterly basis for the rest of their membership period. This structured approach ensures that users continuously receive professional dermatological advice and high-quality skincare products, creating sustained skin health improvement.

### Project Objective
The project aims to provide two reports:

- Funnel report (first_user_journey): This report tracks each step in the user journey, from sign-up to the first appointment, from the first appointment to the first order, the total value of that first order, and the turnaround time between each step.
![First User Journey Table](![First User Journey Table](https://github.com/Feyisayo0g/HealthTech-Company-User-Journey-Analysis/blob/main/first_user_journey.png)
first_user_journey.png
- Weekly statistics report (first_user_journey_weekly): This report includes average turnaround times between each step and the total number of users signed up per week.
  ![First User Journey Table](![First User Journey Table](https://github.com/Feyisayo0g/HealthTech-Company-User-Journey-Analysis/blob/main/first_user_journey_weekly.png)

### Importance of the Final Report
By analyzing weekly statistics, GlowRex can identify delays or inefficiencies in the new user sign-up journey and investigate whether these are correlated with lower revenue. For example, the company can determine if a longer turnaround time to schedule an appointment correlates with a lower first order value. These insights will enable GlowRex to improve user engagement and increase revenue.

### Methodology
#### Data Collection
Data was collected from three primary sources within the GlowRex snowflake database:
- Users: Information on user registrations and sign-up dates.
- Appointments: Records of telehealth appointments, including appointment dates, creation dates, and statuses.
- Rx Orders: Data on product purchases, including transaction dates, order numbers, and item amounts.
#### Analysis
The analysis was conducted using SQL queries to transform and aggregate the data. The process involved the following steps:
- Data Extraction and Cleaning: Extract user, appointment, and order data, ensuring data integrity by removing invalid records.
- De-duplication: Rank and filter appointment data to retain only the latest status for each appointment.
- First Completed Appointment: Identify the earliest completed appointment for each user.
- First Prescription Order: Determine the first prescription order for each user after their first completed appointment, using subqueries to avoid window functions.

### Results
The analysis yielded the following key metrics and insights:
- Average Days to First Appointment: The average number of days from user signup to the first appointment.
- Average Days to First Rx Order: The average number of days from the first appointment to the first prescription order.
- Percentage of Users with Appointment: The percentage of users who completed at least one appointment.
- Percentage of Users with Rx Order: The percentage of users who placed at least one prescription order.
- Average First Order Value: The average value of the first prescription order.

### Conclusion and Recommendations
Based on the analysis, the following recommendations are made:
- Reduce Appointment Scheduling Delays: Implement measures to reduce the time between user signup and the first appointment, such as automated reminders and streamlined scheduling processes.
- Improve Engagement for No-Show Users: Develop strategies to re-engage users who missed their appointments, potentially through follow-up communications or incentives.
- Monitor Weekly Trends: Continuously monitor the weekly statistics report to identify and address any emerging delays or inefficiencies promptly.
- Enhance First Appointment Experience: Ensure that the first appointment is a positive and informative experience, encouraging users to follow through with product purchases.

By implementing these recommendations, GlowRex can enhance user engagement, improve the overall user experience, and increase revenue through higher first order values.
