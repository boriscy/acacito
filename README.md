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

```


```sql
select o.id, d.name, d.price, d.quantity from orders o, jsonb_to_recordset(o.details) as d(price numeric, name text, quantity int)
```
