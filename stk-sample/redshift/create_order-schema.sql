CREATE TABLE orders_sorted (
    id bigint identity(0,1),
    public_id bigint identity(0,1),
    idempotency_key bigint identity(0,1),
    orders_uuid bigint identity(0,1),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,

    int_notnull_1 integer NOT NULL,
    int_notnull_2 integer NOT NULL,
    int_notnull_3 integer NOT NULL,
    int_notnull_4 integer NOT NULL,
    int_notnull_5 integer NOT NULL,
    int_notnull_6 integer NOT NULL,
    int_notnull_7 integer NOT NULL,
    int_notnull_8 integer NOT NULL,
    int_notnull_9 integer NOT NULL,
    int_notnull_10 integer NOT NULL,
    int_null_1 integer,
    int_null_2 integer,
    int_null_3 integer,
    int_null_4 integer,
    int_null_5 integer,
    int_null_6 integer,
    int_null_7 integer,
    int_null_8 integer,
    int_null_9 integer,
    int_null_10 integer,
    int_null_11 integer,
    int_null_12 integer,
    int_null_13 integer,
    int_null_14 integer,
    int_null_15 integer,
    int_null_16 integer,
    int_null_17 integer,
    int_null_18 integer,
    int_null_19 integer,
    int_null_20 integer,
    int_null_21 integer,
    int_null_22 integer,
    int_null_23 integer,

    bigint_nonull_1 bigint NOT NULL,
    bigint_nonull_2 bigint NOT NULL,
    bigint_nonull_3 bigint NOT NULL,
    bigint_null_1 bigint,
    bigint_null_2 bigint,
    bigint_null_3 bigint,
    bigint_null_4 bigint,
    bigint_null_5 bigint,
    bigint_null_6 bigint,
    bigint_null_7 bigint,
    bigint_null_8 bigint,
    bigint_null_9 bigint,
    bigint_null_10 bigint,
    bigint_null_11 bigint,
    bigint_null_12 bigint,
    bigint_null_13 bigint,
    bigint_null_14 bigint,
    bigint_null_15 bigint,
    bigint_null_16 bigint,

    timestamp_null_1 timestamp with time zone,
    timestamp_null_2 timestamp with time zone,
    timestamp_null_3 timestamp with time zone,
    timestamp_null_4 timestamp with time zone,
    timestamp_null_5 timestamp with time zone,
    timestamp_null_6 timestamp with time zone,
    timestamp_null_7 timestamp with time zone,
    timestamp_null_8 timestamp with time zone,
    timestamp_null_9 timestamp with time zone,
    timestamp_null_10 timestamp with time zone,
    timestamp_null_11 timestamp with time zone,
    timestamp_null_12 timestamp with time zone,
    timestamp_null_13 timestamp with time zone,
    timestamp_null_14 timestamp with time zone,
    timestamp_null_15 timestamp with time zone,
    timestamp_null_16 timestamp with time zone,
    timestamp_null_17 timestamp with time zone,
    timestamp_null_18 timestamp with time zone,
    timestamp_null_19 timestamp with time zone,
    timestamp_null_20 timestamp with time zone,
    timestamp_null_21 timestamp with time zone,
    timestamp_null_22 timestamp with time zone,
    timestamp_null_23 timestamp with time zone,
    timestamp_null_24 timestamp with time zone,
    timestamp_null_25 timestamp with time zone,
    timestamp_null_26 timestamp with time zone,
    timestamp_null_27 timestamp with time zone,

    text_notnull_1 text NOT NULL
);
alter table orders_sorted alter sortkey (updated_at);
