Postgrex.Types.define(Publit.PostgresTypes,
                      [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
                      [json: Poison])
