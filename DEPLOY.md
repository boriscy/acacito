Change version for deployment
```
ssh -A deploy@acacito.com
cd repos/publit
git pull origin master
MIX_ENV=dev mix ecto.migrate
MIX_ENV=prod mix compile
npm run deploy
yarn run deploy
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod
git_rev=`git rev-parse HEAD|head -c 8`
ver="0.9.3+$git_rev"

cp  _build/prod/rel/publit/releases/0.9.4+de65ea0d/publit.tar.gz ~/tmp/

cd /home/deploy/tmp/
tar -xzf publit.tar.gz
bin/publit start
```
