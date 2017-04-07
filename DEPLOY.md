Change version for deployment
```
ssh -A deploy@acacito.com
cd repos/publit
git pull origin master
MIX_ENV=prod mix compile
npm run deploy
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod
git_rev=`git rev-parse HEAD|head -c 8`
ver="0.9.3+$git_rev"

cp  _build/prod/rel/publit/releases/0.9.4+de65ea0d/publit.tar.gz ~/tmp/

cp tar.gz
tar -xzf publit.tar.gz
bin/start
```
