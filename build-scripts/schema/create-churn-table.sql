create table churn_history (
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
  cust_service_calls int not null,
  churn int   
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

CREATE FUNCTION will_churn(state char(10),acc_length int,area_code int,int_plan char(10),vmail_plan char(10),vmail_msg int,day_mins decimal,day_calls int,eve_mins decimal,eve_calls int,night_mins decimal,night_calls int,int_mins decimal, int_calls int,cust_service_calls int) RETURNS char(10) alias aws_sagemaker_invoke_endpoint endpoint name 'auroramlendpoint-A0es6rj6YFwD';
