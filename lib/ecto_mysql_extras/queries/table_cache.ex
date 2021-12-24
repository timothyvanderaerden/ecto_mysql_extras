defmodule EctoMySQLExtras.TableCache do
  @moduledoc """
  InnoDB waits for redolog.

  Table cache ratio.

  - `cache_ratio`: The ratio of table cache usage for all threads.
  A good value should be less than 80%. Increase the table_open_cache variable until the percentage reaches a good value.
  - `hit_ratio`: The ratio of table cache hit usage.
  A good hit ratio value should be 90% and above. Otherwise, increase the table_open_cache variable until the hit ratio reaches a good value.

  Data is retrieved from the `performance_schema` or `information_schema` database and the `global_status` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Table cache ratio",
      columns: [
        %{name: :cache_ratio, type: :numeric},
        %{name: :hit_ratio, type: :numeric}
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
      (opened.variable_value / cache.variable_value) * 100 AS cache_ratio,
      (open.variable_value / opened.variable_value) * 100 AS hit_ratio
    FROM
      #{schema}.global_status opened,
      #{schema}.global_status cache,
      #{schema}.global_status open
    WHERE
      opened.variable_name = 'opened_tables' AND
      cache.variable_name = 'table_open_cache_hits' AND
      open.variable_name = 'open_tables';
    """
  end
end
