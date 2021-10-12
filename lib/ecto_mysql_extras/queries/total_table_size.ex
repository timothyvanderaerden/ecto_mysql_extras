defmodule EctoMySQLExtras.TotalTableSize do
  @moduledoc """
  Query the total size of each table in the Ecto Repo database.

  Data is retrieved from the `information_schema` database and the `tables` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Size of the tables (including indexes), descending by size",
      order_by: [size: :DESC],
      args: [:table],
      columns: [
        %{name: :schema, type: :string},
        %{name: :name, type: :string},
        %{name: :engine, type: :string},
        %{name: :size, type: :bytes}
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
      CAST(ROUND(DATA_LENGTH + INDEX_LENGTH) AS UNSIGNED) AS `size`
    FROM information_schema.tables
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_TYPE <> 'VIEW'
    AND #{where_table}
    ORDER BY `size` DESC;
    """
  end
end
