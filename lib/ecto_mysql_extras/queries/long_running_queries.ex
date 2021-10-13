defmodule EctoMySQLExtras.LongRunningQueries do
  @moduledoc """
  Query all long running queries.

  Data is retrieved from the `information_schema` database and the `plugins` table.
  The `:threshold` argument is in milliseconds. The duration for MySQL is displayed
  in seconds, for MariaDB this is in millieseconds.
  At this moment it isn't converted to a more human readable
  format.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "All queries longer than the threshold by descending duration",
      order_by: [duration: :DESC],
      args: [:threshold],
      default_args: [threshold: 500],
      columns: [
        %{name: :id, type: :integer},
        %{name: :thread, type: :integer},
        %{name: :user, type: :string},
        %{name: :host, type: :string},
        %{name: :duration, type: :integer},
        %{name: :query, type: :string},
        %{name: :memory_used, type: :bytes},
        %{name: :max_memory_used, type: :bytes}
      ]
    }
  end

  def query(args \\ [db: :mysql, version: "8.0.0"]) do
    query = """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    """

    query_db_specific =
      if args[:db] == :mysql do
        table =
          if String.starts_with?(args[:version], "5.7.") do
            "information_schema.PROCESSLIST"
          else
            "performance_schema.processlist"
          end

        """
        SELECT
          ID AS `id`,
          NULL AS `thread`,
          USER AS `user`,
          HOST AS `host`,
          TIME AS `duration`,
          INFO AS `query`,
          NULL AS `memory_used`,
          NULL AS `max_memory_used`
        FROM #{table}
        WHERE DB = DATABASE()
        AND COMMAND <> 'Sleep'
        AND TIME > #{args[:threshold] / 1000}
        ORDER BY `duration` DESC;
        """
      else
        """
        SELECT
          ID AS `id`,
          TID AS `thread`,
          USER AS `user`,
          HOST AS `host`,
          TIME_MS AS `duration`,
          INFO AS `query`,
          MEMORY_USED AS `memory_used`,
          MAX_MEMORY_USED AS `max_memory_used`
        FROM information_schema.PROCESSLIST
        WHERE DB = DATABASE()
        AND COMMAND <> 'Sleep'
        AND TIME_MS > #{args[:threshold]}
        ORDER BY `duration` DESC;
        """
      end

    query <> query_db_specific
  end
end
