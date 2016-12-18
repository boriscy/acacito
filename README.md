# Publit

# Arc
Arc stores images and requires config, remember to config
`config/prod.exs`, `config/dev.exs` and `config/test.exs`

```elixir
config :arc,
  storage: Arc.Storage.S3, # or Arc.Storage.Local
  bucket: {:system, "AWS_S3_BUCKET"}, # if using Amazon S3
```

```sql
create or replace function update_org_tags(uuid)
returns void as $$
begin

end;
$$ LANGUAGE plpgsql;
```
