defmodule EctoMySQLExtras.Connections do
  @moduledoc """
  Query active connections.

    Data is retrieved from the `performance_schema` or `information_schema` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Active connections",
      columns: [
        %{name: :id, type: :integer},
        %{name: :user, type: :string},
        %{name: :host, type: :string},
        %{name: :db, type: :string},
        %{name: :command, type: :string},
        %{name: :time, type: :numeric},
        %{name: :state, type: :string},
        %{name: :info, type: :string}
      ]
    }
  end

  def query(args \\ [db: :mysql]) do
    schema =
      if args[:db] == :mysql do
        "performance_schema"
      else
        "information_schema"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT id, user, host, db, command, time, state, info
    FROM #{schema}.processlist;

    """
  end
end
