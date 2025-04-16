--Question 1: 
SELECT 
  pickup_datetime,
  dropoff_datetime,
  dropoff_datetime - pickup_datetime AS ride_duration
FROM nyc_taxi_data
ORDER BY ride_duration DESC;

--Question 2:
SELECT 
  '2100-01-01 00:00:00'::timestamp AT TIME ZONE 'America/New_York' AS new_york_time,
  '2100-01-01 00:00:00'::timestamp AT TIME ZONE 'America/New_York' AT TIME ZONE 'Europe/London' AS london_time,
  '2100-01-01 00:00:00'::timestamp AT TIME ZONE 'America/New_York' AT TIME ZONE 'Africa/Johannesburg' AS johannesburg_time,
  '2100-01-01 00:00:00'::timestamp AT TIME ZONE 'America/New_York' AT TIME ZONE 'Europe/Moscow' AS moscow_time,
  '2100-01-01 00:00:00'::timestamp AT TIME ZONE 'America/New_York' AT TIME ZONE 'Australia/Melbourne' AS melbourne_time;

--Question 3:
SELECT
  CORR(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60.0, total_amount) AS corr_trip_time_total,
  POWER(CORR(EXTRACT(EPOCH FROM dropoff_datetime - pickup_datetime) / 60.0, total_amount), 2) AS r_squared_trip_time_total,
  CORR(trip_distance, total_amount) AS corr_distance_total,
  POWER(CORR(trip_distance, total_amount), 2) AS r_squared_distance_total
FROM nyc_taxi_data
WHERE dropoff_datetime - pickup_datetime <= INTERVAL '3 hours';
