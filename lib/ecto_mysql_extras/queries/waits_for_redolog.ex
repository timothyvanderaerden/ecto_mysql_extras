defmodule EctoMySQLExtras.WaitsForRedolog do
  @moduledoc """
  InnoDB waits for redolog.

  The ratio of redo log contention.
  A good ratio value should stay below 1.

  Check `innodb_log_waits` and if it continues to increase then it is a strong indicator that the InnoDB buffer pool is too small.
  It can also mean that the disks are too slow and cannot sustain the disk IO, perhaps due to peak write load.

  Data is retrieved from the `performance_schema` or `information_schema` database and the `global_status` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "The ratio of redo log contention",
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
      (waits.variable_value / writes.variable_value) AS ratio,
      waits.variable_value AS wait_counter
    FROM
      #{schema}.global_status waits,
      #{schema}.global_status writes
    WHERE
      waits.variable_name = 'innodb_log_waits' AND
      writes.variable_name = 'innodb_log_writes';
    """
  end
end
