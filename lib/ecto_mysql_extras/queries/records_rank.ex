defmodule EctoMySQLExtras.RecordsRank do
  @moduledoc """

  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title:
        "All tables and the number of rows in each table ordered by number of rows descending",
      order_by: [estimated_count: :DESC],
      args: [:table],
      columns: [
        %{name: :schema, type: :string},
        %{name: :name, type: :string},
        %{name: :engine, type: :string},
        %{name: :estimated_count, type: :integer}
      ]
    }
  end

  def query(args \\ []) do
    where_table =
      if args[:table] do
        "TABLE_NAME = '#{args[:table]}'"
      else
        "TABLE_NAME IS NOT NULL"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      TABLE_SCHEMA AS `schema`,
      TABLE_NAME AS `name`,
      ENGINE AS `engine`,
      TABLE_ROWS AS `estimated_count`
    FROM information_schema.tables
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_TYPE != 'VIEW'
    AND #{where_table}
    ORDER BY `estimated_count` DESC;
    """
  end
end
