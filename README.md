# misc postgres queries

Write/email reports for regularly used queries

## Setup

```bash
git clone https://github.com/ldss-jm/misc_postgres_queries
bundle install
```

Sierra credentials (and permissions) are needed if using tasks that connect to Sierra. In the `misc_postgres_queries` folder you created during the above, create a `sierra_prod.secret` yaml file with Sierra DB credentials as described [here](https://github.com/UNC-Libraries/sierra-postgres-utilities).

## Notes
- `spr_dupe.rb` depends on <https://github.com/UNC-Libraries/Cataloging_Scripts> being present in the same parent directory as `misc_postgres_queries`
