# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.6.3 (2024-12-23)
* Fix Elixir 1.17 deprecation warnings

### CI
* Add MySQL 8.4
* Add MariaDB 11.4
* Drop MySQL 5.7 and 8.1
* Drop MariaDB 10.4

## v0.6.2 (2024-02-03)
### Changed
* Relax `table_rex` version to `~> 3.1` or `~> 4.0`
* Bump deps
* Delete unused dependencies in `mix.lock`

### CI
* Add MySQL 8.1
* Add MariaDB 11.0 and 11.1
* Drop MariaDB 10.9 and 10.10

## v0.6.1 (2023-07-29)
### Changed
* Bump deps

### CI
* Support MariaDB 10.9, 10.10, 10.11
* Drop MariaDB 10.3

## v0.6.0 (2022-11-02)
### Added
* List active connections

## v0.5.0 (2022-05-25)
### Added
* Support `query_opts` with `log` option to enable/disable logging (disabled by default)

## v0.4.2 (2022-05-09)
### Changed
* Fix README.md links and docs

### CI
* Drop MariaDB 10.2

## v0.4.1 (2022-01-17)
### Changed
* Bump deps

## v0.4.0 (2021-12-24)
### Added
* InnoDB Dirty pages ratio query #11
* InnoDB Waits for checkpoint query #12
* InnoDB Waits for redolog query #13
* Table cache query #14

## v0.3.1 (2021-11-03)
### Changed
* Deleted `max_memory_used` from Long running queries
* Misc doc changes (#5)

### CI
* Add MariaDB 10.2, 10.3, 10.4

## v0.3.0 (2021-10-19)
### Added
* Query: Long running queries (#1)

### Changed
* Renamed `DBStatus` to `DbStatus`
* Pass query arguments inside `args` keyword list

### Fixed
* Convert Total table size to unsigned integer inside SQL query

### CI
* Add MariaDB 10.6

## v0.2.1 (2021-10-14)
### Fixed
* Compile error when table_rex isn't loaded

## v0.2.0 (2021-10-11)
### Added
* Query: DB settings
* Query: DB status
* Query: Unused indexes
* Query: Records rank

### Changed
* Delete views from query results
* Exclude Primary key from Index size query

### Fixed
* Don't convert total index size inside SQL query

### CI
* Add MySQL 5.7

## v0.1.0 (2021-10-07)
### Added
* Initial commit
* Query: Index Size
* Query: Plugins
* Query: Table indexes size
* Query: Table size
* Query: Total index size
* Query: Total table size
