# r0uei
## Overview
**r0uei** is a vulnerable application.

## Setup
Execute the following commands one at a time.

```
git clone https://github.com/yu1hpa/r0uei.git
cd r0uei && docker compose up -d
docker compose exec r0uei /bin/sh
bundle exec rake db:migrate
bundle exec rake db:seed
```

## LICENSE
the Apache License, Version2.0.

## Author
yu1hpa