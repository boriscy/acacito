Change version for deployment
```
ssh -A deploy@acacito.com
cd repos/publit
git pull origin master
MIX_ENV=dev mix ecto.migrate
MIX_ENV=prod mix compile
yarn run deploy
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod

rm -r ~/tmp
mkdir ~/tmp

cp  _build/prod/rel/publit/releases/0.9.9/publit.tar.gz ~/tmp/

cd /home/deploy/tmp/
tar -xzf publit.tar.gz
bin/publit start
```
