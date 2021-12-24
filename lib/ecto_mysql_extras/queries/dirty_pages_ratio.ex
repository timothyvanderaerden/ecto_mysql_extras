defmodule EctoMySQLExtras.DirtyPagesRatio do
  @moduledoc """
  InnoDB dirty pages ratio.

  The ratio of how often InnoDB needs to be flushed. During the write-heavy load,
  it is normal that this percentage increases. A good value should be 75% and below.


  Data is retrieved from the `performance_schema` or `information_schema` database and the `global_status` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "InnoDB Dirty Pages Ratio",
      columns: [
        %{name: :ratio, type: :numeric},
        %{name: :total_pages, type: :integer}
      ]
    }
  end

  def query(args \\ []) do
    schema =
      if args[:db] == :mysql do
        "performance_schema"
      else
        "information_schema"
      end

    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      ((dirty.variable_value / total.variable_value) * 100) AS ratio,
      total.variable_value AS total_pages
    FROM
      #{schema}.global_status dirty,
      #{schema}.global_status total
    WHERE
      dirty.variable_name = 'innodb_buffer_pool_pages_dirty' AND
      total.variable_name = 'innodb_buffer_pool_pages_total';
    """
  end
end
