# Publit

# Arc
Arc stores images and requires config, remember to config
`config/prod.exs`, `config/dev.exs` and `config/test.exs`

```elixir
config :arc,
  storage: Arc.Storage.S3, # or Arc.Storage.Local
  bucket: {:system, "AWS_S3_BUCKET"}, # if using Amazon S3
```


```elixir
defmodule UserMacro do
  defmacro is_user(u) do
    quote do
      u = unquote(u)
      if u.__struct__ == Publit.User, do: true, else: false
    end
  end
  defmacro is_user_client(u) do
    quote do
      u = unquote(u)
      if u.__struct__ == Publit.User, do: true, else: false
    end
  end
end

defmodule Uno do
  def uno(u) when is_map(u) && (u.__struct__ == Publit.UserClient) do
    IO.puts "user_client"
  end

  def uno(u) do
    IO.puts "other"
  end
end

```


```sql
select o.id, d.name, d.price, d.quantity from orders o, jsonb_to_recordset(o.details) as d(price numeric, name text, quantity int)
```

```
# Init file
#!/bin/sh

### BEGIN INIT INFO
# Provides:          publit
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Plug Application: publit
### END INIT INFO

export MIX_ENV=prod
export PORT=42357
export HOME=/home/deploy/deployments/publit

[ -f $HOME/.env ] && export $(cat $HOME/.env)

/home/deploy/deployments/publit/bin/publit "$1" "$2
```

mix edeliver update production --branch=master --start-deploy

mix edeliver build release
mix edeliver deploy release to production
mix edeliver start production

mix edeliver build upgrade --auto-version=git-revision
mix edeliver build upgrade --from=03b88d8 --run-migrations
mix edeliver build upgrade --from=cab9bc9

mix edeliver deploy upgrade to production

mix edeliver upgrade

`.deliver/config`

```
pre_erlang_clean_compile() {
  status "Installing NPM dependencies"
  __sync_remote "
    [ -f ~/.profile ] && source ~/.profile
    set -e

    cd '$BUILD_AT'
    npm install $SILENCE
  "

  status "Building static files"
  __sync_remote "
    [ -f ~/.profile ] && source ~/.profile
    set -e

    cd '$BUILD_AT'
    mkdir -p priv/static
    npm run deploy $SILENCE
  "

  status "Running phoenix.digest"
  __sync_remote "
    [ -f ~/.profile ] && source ~/.profile
    set -e

    cd '$BUILD_AT'
    APP='$APP' MIX_ENV='$TARGET_MIX_ENV' $MIX_CMD phoenix.digest $SILENCE
  "
}
```


425b5ebe-0299-440f-9446-42f18fded63d | b66ba320-d01a-433a-958e-7a77f9cf23b7 | {324489d4-c482-4ef5-a06c-91ed57914d59} | error  | {"body": "{\"error\":\"Please supply the device tokens as an array of strings.\"}", "headers": {"Date": "Tue, 16 May 2017 11:51:36 GMT", "Vary": "Accept-Encoding", "Server": "nginx/1.8.0", "Connection": "keep-alive", "Content-Type": "application/json; charset=utf-8", "Content-Length": "67"}, "status_code": 400} | 2017-05-16 11:51:35.894032 | 2017-05-16 11:51:36.249101

```
cb_ok = fn(resp) -> IO.inspect(resp) end
cb_error = fn(resp) -> IO.puts "Error" end

msg = %{
  message: "Hola Boris desde local",
  data: %{
    status: "calling",
    order_call: %{name: "JEJEJE"}
  }
}

{:ok, pid} = Publit.MessagingService.send_message_trans(tokens, msg, cb_ok, cb_error)
```
