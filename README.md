# Ecto MySQL Extras

[![CI](https://github.com/timothyvanderaerden/ecto_mysql_extras/actions/workflows/ci.yml/badge.svg)](https://github.com/optimise-group/bifrost/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/timothyvanderaerden/ecto_mysql_extras/branch/main/graph/badge.svg?token=IJMNEMI6CE)](https://codecov.io/gh/timothyvanderaerden/ecto_mysql_extras)
[![Module Version](https://img.shields.io/hexpm/v/ecto_mysql_extras.svg)](https://hex.pm/packages/ecto_mysql_extras)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ecto_mysql_extras/)
[![Total Download](https://img.shields.io/hexpm/dt/ecto_mysql_extras.svg)](https://hex.pm/packages/ecto_mysql_extras)
[![License](https://img.shields.io/hexpm/l/ecto_mysql_extras.svg)](https://github.com/timothyvanderaerden/ecto_mysql_extras/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/timothyvanderaerden/ecto_mysql_extras.svg)](https://github.com/timothyvanderaerden/ecto_mysql_extras/commits/master)

This library provides performance insight information on MySQL (and MariaDB) databases.
It's heavily based upon [Ecto PSQL Extras](https://github.com/pawurb/ecto_psql_extras), it reuses most of the design.

Currently only `InnoDB` is supported, other engines may work but not all queries will return all or correct data.

The following databases are supported:

* MySQL >= 5.7, <= 8.0
* MariaDB >= 10.2, <= 10.6

Newer version are tested every week to check for any compatibility issues.

## Installation

The package can be installed by adding `:ecto_mysql_extras` to your list of dependencies in `mix.exs`:

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

The performance schema is enabled by default for MySQL databases but not for MariaDB. To enable this add `performance_schema=ON` to `my.cnf`. A restart is need to take effect.

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

### `db_settings`

```
EctoMySQLExtras.db_settings(MyApp.Repo, format: :ascii)

+--------------------------------------------+
|           MySQL global variables           |
+--------------------------------+-----------+
| name                           | value     |
+--------------------------------+-----------+
| INNODB_BUFFER_POOL_INSTANCES   | 1         |
| INNODB_BUFFER_POOL_SIZE        | 134217728 |
(truncated results for brevity)
```

Shows global variables for selected MySQL settings.

### `db_status`

```
EctoMySQLExtras.db_status(MyApp.Repo, format: :ascii)

+---------------------------------+
|       MySQL global status       |
+----------------------+----------+
| name                 | value    |
+----------------------+----------+
| Aborted_clients      | 100      |
| Aborted_connects     | 25       |
(truncated results for brevity)
```

Shows global status for selected MySQL server status.

### `index_size`

```
EctoMySQLExtras.index_size(MyApp.Repo, format: :ascii)

+---------------------------------------------------+
|      Size of the indexes, descending by size      |
+----------+-------+-------------+-------+----------+
| schema   | name  | index       | pages | size     |
+----------+-------+-------------+-------+----------+
| sportsdb | stats | IDX_stats_1 | 97    | 1.5 MB   |
| sportsdb | stats | IDX_stats_5 | 23    | 368.0 KB |
(truncated results for brevity)
```

Shows the size of each index in the database, excluding primary keys. Additionally a table can be passed to only get indexes from that table.

```
EctoMySQLExtras.index_size(MyApp.Repo, format: :ascii, args: [table: "my_table"])
```

### `long_running_queries`

```
EctoMySQLExtras.long_running_queries(MyApp.Repo, format: :ascii)

+------------------------------------------------------------------------------+
|         All queries longer than the threshold by descending duration         |
+----+--------+------+------+----------+-------+-------------+-----------------+
| id | thread | user | host | duration | query | memory_used | max_memory_used |
+----+--------+------+------+----------+-------+-------------+-----------------+
(truncated results for brevity)
```

Shows queries that have been running for longer than 0.5 seconds, descending by duration. The threshold can be configured and is represented in milliseconds, however for MySQL servers this is converted to seconds.

```
EctoMySQLExtras.long_running_queries(MyApp.Repo, format: :ascii, args: [threshold: 1000])
```

### `plugins`

```
EctoMySQLExtras.plugins(MyApp.Repo, format: :ascii)

+--------------------------------------------------------------------------------------------------------------------------------------+
|                                                     Available and installed plugins                                                  |
+-----------------------+---------+--------+----------------+--------------------------------------------------------------------------+
| name                  | version | status | type           | description                                                              |
+-----------------------+---------+--------+----------------+--------------------------------------------------------------------------+
| binlog                | 1.0     | ACTIVE | STORAGE ENGINE | This is a pseudo storage engine to represent the binlog in a transaction |
| mysql_native_password | 1.0     | ACTIVE | AUTHENTICATION | Native MySQL authentication                                              |
(truncated results for brevity)
```

Shows all installed plugins, their version and status.

### `records_rank`


```
EctoMySQLExtras.records_rank(MyApp.Repo, format: :ascii)

+-----------------------------------------------------------------------------------------+
|  All tables and the number of rows in each table ordered by number of rows descending   |
+-------------+------------------------------------------+-----------+--------------------+
| schema      | name                                     | engine    | estimated_count    |
+-------------+------------------------------------------+-----------+--------------------+
| sportsdb    | affiliations_events                      | InnoDB    | 13203              |
| sportsdb    | participants_events                      | InnoDB    | 8533               |
(truncated results for brevity)
```

Shows an estimated count of rows per table, descending by estimated count. Additionally a table can be passed to only get an estimated count from that table.

```
EctoMySQLExtras.records_rank(MyApp.Repo, format: :ascii, args: [table: "my_table"])
```

### `table_indexes_size`

```
EctoMySQLExtras.table_indexes_size(MyApp.Repo, format: :ascii)

+------------------------------------------------------------------------------------------------+
|  Total size of all the indexes on each table (excluding PRIMARY indexes), descending by size   |
+----------------+---------------------------------------------+--------------+------------------+
| schema         | name                                        | engine       | index_size       |
+----------------+---------------------------------------------+--------------+------------------+
| sportsdb       | stats                                       | InnoDB       | 3.3 MB           |
| sportsdb       | participants_events                         | InnoDB       | 880.0 KB         |
(truncated results for brevity)
```

Shows the total size of all indexes in a table, descending by size. Primary indexes are not included. This also requires InnoDB as engine. Additionally a table can be passed to only get the total size of all indexes from that table.

```
EctoMySQLExtras.table_indexes_size(MyApp.Repo, format: :ascii, args: [table: "my_table"])
```

### `table_size`

```
EctoMySQLExtras.table_size(MyApp.Repo, format: :ascii)

+----------------------------------------------------------------------+
|      Size of the tables (excluding indexes), descending by size      |
+----------+---------------------------------------+--------+----------+
| schema   | name                                  | engine | size     |
+----------+---------------------------------------+--------+----------+
| sportsdb | stats                                 | InnoDB | 1.5 MB   |
| sportsdb | participants_events                   | InnoDB | 496.0 KB |
(truncated results for brevity)
```

Shows the table size of each table in the database excluding indexes, descending by size. Additionally a table can be passed to only get the size from that table.

```
EctoMySQLExtras.table_size(MyApp.Repo, format: :ascii, args: [table: "my_table"])
```

### `total_index_size`

```
EctoMySQLExtras.total_index_size(MyApp.Repo, format: :ascii)

+-------------------------------------------------------------+
| Total size of all indexes (excluding PRIMARY indexes) in MB |
+-------------------------------------------------------------+
| size                                                        |
+-------------------------------------------------------------+
| 9.8 MB                                                      |
+-------------------------------------------------------------+
```

Shows the total index size of all tables in the database, primary indexes are not included.

### `total_table_size`

```
EctoMySQLExtras.total_table_size(MyApp.Repo, format: :ascii)

+----------------------------------------------------------------------+
|      Size of the tables (including indexes), descending by size      |
+----------+---------------------------------------+--------+----------+
| schema   | name                                  | engine | size     |
+----------+---------------------------------------+--------+----------+
| sportsdb | stats                                 | InnoDB | 4.8 MB   |
| sportsdb | participants_events                   | InnoDB | 1.3 MB   |
(truncated results for brevity)
```

Shows the total table size of each table in the database including indexes, descending by size. Additionally a table can be passed to only get the total size from that table.

```
EctoMySQLExtras.total_table_size(MyApp.Repo, format: :ascii, args: [table: "my_table"])
```

### `unused_indexes`

```
EctoMySQLExtras.unused_indexes(MyApp.Repo, format: :ascii)

+-----------------------------------------------------------------------------------------------------------------+
|                                        Unused and almost unused indexes                                         |
+----------+--------------------------+-------------------------------------------+-------+----------+------------+
| schema   | table                    | index                                     | pages | size     | index_hits |
+----------+--------------------------+-------------------------------------------+-------+----------+------------+
| sportsdb | stats                    | IDX_stats_1                               | 97    | 1.5 MB   | 0          |
| sportsdb | events                   | IDX_FK_eve_pub_id__pub_id                 | 6     | 96.0 KB  | 0          |
(truncated results for brevity)
```

Shows all the indexes that are not used, the database should be running for a while to have the best results since it's based upon IO activity. This also requires InnoDB as engine.

## Ecto MySQL Extras differences

Except for the "obvious" difference that `Ecto MySQL Extras` provides information on MySQL (MariaDB) databases and `Ecto PSQL Extras` on PostgreSQL databases, there are some small differences. Below is a list which could be useful if you're already using `Ecto PSQL Extras` and want to try `Ecto MySQL Extras`.

* `:table_rex` is an optional dependency.
* The default format is `:raw` instead of `:ascii`.

## Copyright and License

Copyright (c) 2021 Timothy Vanderaerden

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
