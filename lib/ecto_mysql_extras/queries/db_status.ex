defmodule EctoMySQLExtras.DbStatus do
  @moduledoc """
  Query global status.

  Data is retrieved from the `performance_schema` database and the `global_status` table.
  It also provides `InnoDB` specific variables.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "MySQL global status",
      columns: [
        %{name: :name, type: :string},
        %{name: :value, type: :string}
      ]
    }
  end

  def query(args \\ []) do
    schema =
      if args[:db] == :mysql do
        "performance_schema"
      else
        if args[:major_version] == 10 and args[:minor_version] < 5 do
          "information_schema"
        else
          "performance_schema"
        end
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT VARIABLE_NAME AS `name`, VARIABLE_VALUE AS `value`
    FROM #{schema}.global_status
    WHERE VARIABLE_NAME IN (
      'Aborted_clients',
      'Aborted_connects',
      'Access_denied_errors',
      'Busy_time',
      'Bytes_received',
      'Bytes_sent',
      'Connections',
      'Max_used_connections',
      'Open_files',
      'Rows_read',
      'Rows_sent')
    ORDER BY VARIABLE_NAME;

    """
  end
end
