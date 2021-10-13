defmodule EctoMySQLExtras.LongRunningQueries do
  @moduledoc """
  Query all long running queries.

  Data is retrieved from the `information_schema` database and the `plugins` table.
  The `:threshold` argument is in milliseconds. This means that the duration is also
  displayed in milliseconds. At this moment it isn't converted to a more human readable
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
        %{name: :tid, type: :integer},
        %{name: :user, type: :string},
        %{name: :host, type: :string},
        %{name: :duration, type: :integer},
        %{name: :query, type: :string},
        %{name: :qid, type: :integer},
        %{name: :memory_used, type: :bytes},
        %{name: :max_memory_used, type: :bytes}
      ]
    }
  end

  def query(args \\ []) do
    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      ID AS `id`,
      TID AS `tid`,
      USER AS `user`,
      HOST AS `host`,
      TIME_MS AS `duration`,
      INFO AS `query`,
      QUERY_ID AS `qid`,
      MEMORY_USED AS `memory_used`,
      MAX_MEMORY_USED AS `max_memory_used`
    FROM information_schema.PROCESSLIST
    WHERE DB = DATABASE()
    AND STATE <> ''
    AND TIME_MS > #{args[:threshold]}
    ORDER BY `duration` DESC;
    """
  end
end
