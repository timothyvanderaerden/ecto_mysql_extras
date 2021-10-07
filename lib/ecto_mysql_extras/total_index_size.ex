defmodule EctoMySQLExtras.TotalIndexSize do
  @moduledoc """
  Query the total size of all indexes in the Ecto Repo database.

  Data is retrieved from the `information_schema` database and the `tables` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Total size of all indexes in MB",
      columns: [
        %{name: :size, type: :bytes}
      ]
    }
  end

  def query(_args \\ []) do
    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT CAST(COALESCE(SUM(ROUND(INDEX_LENGTH / 1024 / 1024)),0) AS UNSIGNED) AS `size`
    FROM information_schema.tables
    WHERE TABLE_SCHEMA = DATABASE();
    """
  end
end
