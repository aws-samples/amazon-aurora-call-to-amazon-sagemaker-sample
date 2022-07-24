select
getdate(),
getdate(),
floor(random() * 10000 + 1)::int
from generate_series(1,100000,1);
