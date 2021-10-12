defmodule EctoMySQLExtras.IndexSize do
  @moduledoc """
  Query the size of each index in the Ecto Repo database.

  Data is retrieved from the `mysql` database and the `innodb_index_stats` table.
  This query will only work for databases that use `InnoDB` engine.
  Primary keys are excluded from the query.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Size of the indexes, descending by size",
      order_by: [size: :DESC],
      args: [:table],
      columns: [
        %{name: :schema, type: :string},
        %{name: :name, type: :string},
        %{name: :index, type: :string},
        %{name: :pages, type: :integer},
        %{name: :size, type: :bytes}
      ]
    }
  end

  def query(args \\ []) do
    where_table =
      if args[:table] do
        "table_name = '#{args[:table]}'"
      else
        "table_name IS NOT NULL"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      database_name AS `schema`,
      table_name AS `name`,
      index_name AS `index`,
      CAST(SUM(stat_value) AS UNSIGNED) AS `pages`,
      CAST(ROUND(SUM(stat_value)*@@innodb_page_size) AS UNSIGNED) AS `size`
    FROM mysql.innodb_index_stats
    WHERE database_name = DATABASE()
    AND stat_name = 'size'
    AND index_name <> 'PRIMARY'
    AND #{where_table}
    GROUP BY table_name, index_name
    ORDER BY `size` DESC;
    """
  end
end
