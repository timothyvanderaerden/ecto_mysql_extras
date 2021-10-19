# Ecto MySQL Extras

[![Hex](https://img.shields.io/hexpm/v/ecto_mysql_extras.svg)](https://hex.pm/packages/ecto_mysql_extras)
[![CI](https://github.com/timothyvanderaerden/ecto_mysql_extras/actions/workflows/ci.yml/badge.svg)](https://github.com/optimise-group/bifrost/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/timothyvanderaerden/ecto_mysql_extras/branch/main/graph/badge.svg?token=IJMNEMI6CE)](https://codecov.io/gh/timothyvanderaerden/ecto_mysql_extras)

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
    {:ecto_mysql_extras, "~> 0.3.0"}
  ]
end
```

### MySQL/MariaDB configuration

The configured user should have read (SELECT) access on the `mysql`, `information_schema` and `performance_schema` database. Specifaccly for the following schemas:

* `mysql.innodb_index_stats`
* `performance_schema.table_io_waits_summary_by_index_usage`

An example on how to achieve this can be found in `docker/init/init.sql`.

### Performance schema

The performance schema is enabled by default for MySQL databases but not for MariaDB. To enable this add `performance_schema=ON` to `my.cnf`.

More information: https://mariadb.com/kb/en/performance-schema-overview/

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
