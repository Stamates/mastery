use Mix.Config

config :mastery_persistence, MasteryPersistence.Repo,
  database: "mastery_dev",
  hostname: "localhost"

config :mastery, :persistence_fn, &MasteryPersistence.record_response/2
