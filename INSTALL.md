Check article about gatling https://dennisreimann.de/articles/phoenix-deployment-gatling-ubuntu-digital-ocean.html


## Create user deploy

```
sudo visudo -f /etc/sudoers.d/deploy
```

edit the file `/etc/sudoers.d/deploy` with:

```
deploy  ALL=(ALL) NOPASSWD:ALL
```


## Erlang/Elixir

```
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb && rm erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install -y esl-erlang elixir
```

## Node.js

```
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs build-essential
```

## Nginx

```
sudo apt-get install nginx
```


## PostgreSQL


```
sudo apt-get install postgresql-9.6 libpq-dev postgresql-contrib-9.6
sudo apt-get install postgresql-9.6-postgis-2.3
```

create user `deploy` and database `acacito`

```
sudo -u postgres createuser -s -P deploy
sudo -u postgres createdb acacito
```


# Image magick

```
sudo apt-get install imagemagick
```


## Deploy

### Distillery

Adding Distillery to your project
Just add the following to your deps list in mix.exs:

```
defp deps do
  [{:distillery, "~> 0.9"}]
end
```

run `mix deps.get, compile`

Now distillery will create a rel dir with the comand

`mix release init`

the command create the file `rel/config.exs`

Now let's build the release with

`sudo mix release`

Now we can run gatling to make sure it deploys


### Config phoenix

Edit the file `config/prod.exs` to look like

```
use Mix.Config

config :publit, Publit.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: "http", host: "acacito.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  # Distillery release config
  root: ".",
  server: true,
  version: Mix.Project.config[:version]


config :publit, Publit.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info


# Configure your database
config :publit, Publit.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool_size: 20,
  types: Publit.PostgresTypes


config :phoenix, :serve_endpoints, true


# arc
config :arc,
  storage: Arc.Storage.S3,
  bucket: "acacito"

# aws
config :ex_aws,
  access_key_id: System.get_env["AMAZON_KEY_ID"],
  secret_access_key: System.get_env["AMAZON_SECRET_KEY"],
  region: "sa-east-1",
  s3: [
    scheme: "https://",
    host: "s3-sa-east-1.amazonaws.com",
    region: "sa-east-1"
  ]

config :publit, :message_api, Publit.MessageApi
```

Add in you server `/etc/environment`

```

MIX_ENV=prod

LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"


export SECRET_KEY_BASE=my_secret_key_base

export AMAZON_KEY_ID=my_amazon_key_id
export AMAZON_SECRET_KEY=my_amazon_secret_key

export FIREBASE_SERVER_KEY=my_firebase_server_key

export DB_USERNAME=deploy
export DB_PASSWORD=my_db_password
export DB_DATABASE=acacito
export DB_HOSTNAME=localhost

export SECRET_KEY_BASE=asecretkey

export PUBLIT_USERNAME=postgres
export PUBLIT_PASSWORD=postgres
export PUBLIT_DATABASE=publit_dev
export PUBLIT_HOSTNAME=localhost

export PUSHY_SECRET_API_KEY_CLI=pushy_cli
export PUSHY_SECRET_API_KEY_TRANS=pushy_trans

export NEXMO_API_KEY=nex_api_key
export NEXMO_API_SECRET=nex_api_secret

MIX_ENV=prod
```


## Letsencrypt

https://gist.github.com/cecilemuller/a26737699a7e70a7093d4dc115915de8

sudo letsencrypt certonly --standalone -w /var/www/letsencrypt -d www.acacito.com -d acacito.com -d app.acacito.com -d cli.acacito.com --email boriscyber@gmail.com --agree-tos
