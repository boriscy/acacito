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


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

#environment :default do
#  set pos_start_hook: "rel/hooks/post_start"
#end

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"Ih^K<621iVNZpS`uh>ONgwqa({mQx.r3_z>A0OWJks.^a^l[8Yy3j7%6[XX^U!i]"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"Dc5lW6Pzo8IGZ4XD~/5tg6H3cw$9c<Blijsul|i4wES@(FPF7Z>qPBHPEMoY98Zs"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :publit do
  set version: current_version(:publit)
end

