defmodule EctoMySQLExtras.TableIndexesSize do
  @moduledoc """
  Query the total size of indexes for each table in the Ecto Repo database.
  Primary indexes are not included since InnoDB uses it as the clustered index.

  Data is retrieved from the `information_schema` database and the `tables` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title:
        "Total size of all the indexes on each table (excluding PRIMARY indexes), descending by size",
      order_by: [index_size: :DESC],
      args: [:table],
      columns: [
        %{name: :schema, type: :string},
        %{name: :name, type: :string},
        %{name: :type, type: :string},
        %{name: :engine, type: :string},
        %{name: :index_size, type: :bytes}
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
      TABLE_TYPE AS `type`,
      ENGINE AS `engine`,
      INDEX_LENGTH AS `index_size`
    FROM information_schema.tables
    WHERE TABLE_SCHEMA = DATABASE()
    AND #{where_table}
    ORDER BY `index_size` DESC;
    """
  end
end
