defmodule EctoMySQLExtras.UnusedIndexes do
  @moduledoc """
  Query all unused indexes.

  Data is retrieved from the `performance_schema` database and the `table_io_waits_summary_by_index_usage` table.
  The database should be running for a while since unused indexes are tracked based on IO activity.
  An index is considered unused when it has 0 hits and almost unused when it has 50 hits or less. The latter can however
  be configured by passing: `min_hits` as an argument. Also indexes of small tables (less than 5 pages) are excluded.
  Primary keys are excluded from the query.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Unused and almost unused indexes",
      order_by: [index_hits: :DESC],
      args: [:min_hits],
      default_args: [min_hits: 50],
      columns: [
        %{name: :schema, type: :string},
        %{name: :table, type: :string},
        %{name: :index, type: :string},
        %{name: :pages, type: :integer},
        %{name: :size, type: :bytes},
        %{name: :index_hits, type: :integer}
      ]
    }
  end

  def query(args \\ []) do
    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      u.OBJECT_SCHEMA AS `schema`,
      u.OBJECT_NAME AS `table`,
      u.INDEX_NAME AS `index`,
      s.`pages`,
      s.`size`,
      u.COUNT_STAR AS `index_hits`
    FROM performance_schema.table_io_waits_summary_by_index_usage u
    LEFT JOIN (
    	SELECT
    		table_name,
    		index_name,
      		CAST(SUM(stat_value) AS UNSIGNED) AS `pages`,
      		CAST(ROUND(SUM(stat_value)*@@innodb_page_size) AS UNSIGNED) AS `size`
    	FROM mysql.innodb_index_stats
    	WHERE database_name = DATABASE()
    	AND stat_name = 'size'
    	GROUP BY table_name, index_name
    ) s ON u.OBJECT_NAME = s.table_name AND u.INDEX_NAME = s.index_name
    WHERE u.OBJECT_SCHEMA = DATABASE()
    AND u.COUNT_STAR < #{args[:min_hits]}
    AND s.`pages` > 5
    AND s.index_name != 'PRIMARY'
    ORDER BY `index_hits` DESC;
    """
  end
end
