ssh -A deploy@acacito.com
```
MIX_ENV=prod mix compile
brunch build --production
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod
git rev-parse HEAD|head -c 8

cp tar.gz
tar -xjf 0.9.3+23434.tar.gz
bin/start
```
