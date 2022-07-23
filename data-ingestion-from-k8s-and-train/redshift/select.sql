select count(int_notnull_1),sum(int_notnull_4),avg(int_notnull_8) from orders_sorted where idempotency_key>floor(random() * 10000 + 1)::bigint group by int_notnull_1,int_notnull_4,int_notnull_8;
