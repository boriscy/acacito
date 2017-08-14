Change version for deployment
```
ssh -A deploy@acacito.com
cd repos/publit
git pull origin master
MIX_ENV=prod mix deps.get
MIX_ENV=prod mix compile
MIX_ENV=dev mix ecto.migrate
yarn
yarn run deploy
MIX_ENV=prod mix phoenix.digest
MIX_ENV=prod mix release --env=prod

rm -r ~/tmp
mkdir ~/tmp

# Careful with the version
cp  _build/prod/rel/publit/releases/0.9.11/publit.tar.gz ~/tmp/

cd /home/deploy/tmp/
tar -xzf publit.tar.gz
bin/publit start
```
