defmodule EctoMySQLExtras.CacheHit do
  @moduledoc """
  Query cache hit rate.

  Data is retrieved from the `information_schema` database and the `plugins` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Query cache hit rate",
      columns: [
        %{name: :hit_ratio, type: :numeric},
        %{name: :hit_ratio_all_queries, type: :numeric},
        %{name: :misses, type: :integer}
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
      Qcache_hits / (Qcache_hits + Qcache_inserts) AS hit_ratio,
      Qcache_hits / (QCache_hits + Com_select) AS hit_ratio_all_queries,
      Com_select AS misses
    FROM
      (SELECT VARIABLE_VALUE AS Qcache_hits
        FROM #{schema}.global_status WHERE VARIABLE_NAME = 'Qcache_hits')
        AS from_Qcache_hits,
      (SELECT VARIABLE_VALUE AS Qcache_inserts
        FROM #{schema}.global_status WHERE VARIABLE_NAME = 'Qcache_inserts')
        AS from_Qcache_inserts,
      (SELECT VARIABLE_VALUE AS Com_select
        FROM #{schema}.global_status WHERE VARIABLE_NAME = 'Com_select')
        AS from_Com_select;

    """
  end
end
