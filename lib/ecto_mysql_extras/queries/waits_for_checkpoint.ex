defmodule EctoMySQLExtras.WaitsForCheckpoint do
  @moduledoc """
  InnoDB waits for checkpoint.

  The ratio of how often InnoDB needs to read or create a page where no clean pages are available.
  A good ratio value should stay below 1.

  If `innodb_buffer_pool_wait_free` (`wait_counter`) is greater than 0, it is a strong indicator that the InnoDB buffer pool is too small,
  and operations had to wait on a checkpoint.

  Data is retrieved from the `performance_schema` or `information_schema` database and the `global_status` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title:
        "The ratio of how often InnoDB needs to read or create a page where no clean pages are available",
      columns: [
        %{name: :ratio, type: :numeric},
        %{name: :wait_counter, type: :integer}
      ]
    }
  end

  def query(args \\ []) do
    schema =
      if args[:db] == :mysql do
        "performance_schema"
      else
        "information_schema"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      (wait_free.variable_value / write_requests.variable_value) AS ratio,
      wait_free.variable_value AS wait_counter
    FROM
      #{schema}.global_status wait_free,
      #{schema}.global_status write_requests
    WHERE
      wait_free.variable_name = 'innodb_buffer_pool_wait_free' AND
      write_requests.variable_name = 'innodb_buffer_pool_write_requests';
    """
  end
end
