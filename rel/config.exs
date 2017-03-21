# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"D&.&1:fI~J4IwDGLC;4TodAg?o~1rRdfrwGE,G|>pq.*9/<o(,7k;*Vz^JY$ns@["
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"RGc(HhrO*@iPi,!E8N1Jqw:~.EntwZk47h=|(&nc~mgZh<UG[NV%gXawuY3IM<G="
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :publit do
  set version: current_version(:publit)
end

