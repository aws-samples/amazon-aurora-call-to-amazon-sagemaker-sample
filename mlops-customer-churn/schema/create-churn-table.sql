CREATE EXTENSION "uuid-ossp";

CREATE TABLE churn (
 id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
 state char(10) NOT NULL,
 acc_length int NOT NULL,
 area_code int NOT NULL,
 phone char(10) NOT NULL,
 int_plan char(10) NOT NULL,
 vmail_plan char(10) NOT NULL,
 vmail_msg int NOT NULL,
 day_mins  decimal NOT NULL,
 day_calls int NOT NULL,
 day_charge char(10) NOT NULL,
 eve_mins decimal NOT NULL,
 eve_calls int NOT NULL,
 eve_charge char(10) NOT NULL,
 night_mins decimal NOT NULL,
 night_calls int NOT NULL,
 night_charge char(10) NOT NULL,
 int_mins decimal NOT NULL,
 int_calls int NOT NULL,
 int_charge char(10) NOT NULL,
 cust_service_calls int NOT NULL
);


create table subscriber_stats (
  state  char(10) not null,
  acc_length int not null,
  area_code int not null,
  int_plan char(10) not null,
  vmail_plan char(10) not null,
  vmail_msg int not null,
  day_mins decimal not null,
  day_calls int not null,
  eve_mins decimal not null,
  eve_calls int not null,
  night_mins decimal not null,
  night_calls int not null,
  int_mins decimal not null,
  int_calls int not null,
  cust_service_calls int not null
); 

create function will_churn (in state VARCHAR(2048), in acc_length INT8,in area_code INT8,in int_plan VARCHAR, 
    in vmail_plan VARCHAR, in vmail_msg INT8, in day_mins FLOAT8, in day_calls INT8, 
    in eve_mins FLOAT8, in eve_calls INT8, in night_mins FLOAT8, in night_calls INT8, 
    in int_mins FLOAT8, in int_calls INT8, in cust_service_calls INT8,
    in max_rows_per_batch INT default NULL,
    out expected_to_churn VARCHAR) 
AS $$
   select aws_sagemaker.invoke_endpoint('auroramlendpoint-gFsrj8OMA7KP', NULL,
    state, acc_length, area_code, int_plan, vmail_plan,
    vmail_msg, day_mins, day_calls, eve_mins, eve_calls,
    night_mins, night_calls, int_mins, int_calls, cust_service_calls)
   $$ LANGUAGE SQL STABLE PARALLEL SAFE COST 5000;
