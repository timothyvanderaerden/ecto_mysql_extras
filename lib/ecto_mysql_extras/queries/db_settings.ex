defmodule EctoMySQLExtras.DbSettings do
  @moduledoc """
  Query global variables.

  Data is retrieved from the `performance_schema` or `information_schema` database and the `global_variables` table.
  It also provides `InnoDB` specific variables.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "MySQL global variables",
      columns: [
        %{name: :name, type: :string},
        %{name: :value, type: :string}
      ]
    }
  end

  def query(args \\ [db: :mysql]) do
    schema =
      if args[:db] == :mysql do
        "performance_schema"
      else
        "information_schema"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT VARIABLE_NAME AS `name`, VARIABLE_VALUE AS `value`
    FROM #{schema}.global_variables
    WHERE VARIABLE_NAME IN (
      'INNODB_BUFFER_POOL_INSTANCES',
      'INNODB_BUFFER_POOL_SIZE',
      'INNODB_FLUSH_LOG_AT_TRX_COMMIT',
      'INNODB_FLUSH_METHOD',
      'INNODB_IO_CAPACITY_MAX',
      'INNODB_IO_CAPACITY',
      'INNODB_LOG_FILE_SIZE',
      'INNODB_STRICT_MODE',
      'INNODB_THREAD_CONCURRENCY',
      'KEY_BUFFER_SIZE',
      'MAX_CONNECTIONS',
      'MAX_HEAP_TABLE_SIZE',
      'OPEN_FILES_LIMIT',
      'QUERY_CACHE_SIZE',
      'SYNC_BINLOG',
      'TABLE_OPEN_CACHE',
      'THREAD_CACHE_SIZE',
      'THREAD_POOL_SIZE',
      'TMP_TABLE_SIZE',
      'WAIT_TIMEOUT')
    ORDER BY VARIABLE_NAME;

    """
  end
end
