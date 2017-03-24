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


mix edeliver build release
mix edeliver deploy release to production
mix edeliver start production

mix edeliver build upgrade --auto-version=git-revision
