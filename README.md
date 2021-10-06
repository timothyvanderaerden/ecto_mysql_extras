# Ecto MySQL Extras

This library provides performance insight information on MySQL (and MariaDB) databases.
It's heavily based upon [Ecto PSQL Extras](https://github.com/pawurb/ecto_psql_extras), it reuses
most of the design.

At this moment it doesn't work with the Ecto Stats page from [Phoenix Live Dashboard](https://github.com/phoenixframework/phoenix_live_dashboard).
But since the design should be more or less the same it should work with some small changes, at this moment a
[fork](https://github.com/timothyvanderaerden/phoenix_live_dashboard) of Live Dashboard can be used.

Currently only `InnoDB` is supported, other engines may work but not all queries will return all or correct data.

## Installation

The package can be installed by adding `ecto_mysql_extras` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_mysql_extras, "~> 0.1.0"}
  ]
end
```

### MySQL/MariaDB configuration

The configured user should have read (SELECT) access on the `mysql` database. Following schemas are being used:

* `innodb_index_stats`

The configured user should also have read access on the `information_schema` database, but in most cases this the default
behavior on both MySQL and MariaDB.

An example on how to achieve this can be found in `docker/init/init.sql`.

## Usage

To run a query:

```elixir
EctoMySQLExtras.plugins(MyApp.Repo)
```
This will return a `%MyXQL.Result{}` struct. If you want to display it in a more human readable (ASCII) way:

```elixir
EctoMySQLExtras.plugins(MyApp.Repo, format: :ascii)
```

To view all available queries:

```elixir
EctoMySQLExtras.queries()
```


## Ecto MySQL Extras differences

Except for the "obvious" difference that `Ecto MySQL Extras` provides information on MySQL (MariaDB) databases and `Ecto PSQL Extras` on PostgreSQL databases, there are some small differences. Below is a list which could be usefull if you're already using `Ecto PSQL Extras` and want to try `Ecto MySQL Extras`.

* `:table_rex` is an optional dependency.
* The default format is `:raw` instead of `:ascii`.
