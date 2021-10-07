defmodule EctoMySQLExtras do
  @moduledoc """
  Documentation for `EctoMySQLExtras`.
  """

  @callback info :: %{
              required(:title) => String.t(),
              required(:columns) => [%{name: atom(), type: atom()}],
              optional(:order_by) => [{atom(), :ASC | :DESC}],
              optional(:args) => [atom()]
            }

  @type repo() :: module() | {module(), node()}

  @spec queries(repo()) :: map()
  def queries(_repo \\ nil) do
    %{
      index_size: EctoMySQLExtras.IndexSize,
      plugins: EctoMySQLExtras.Plugins,
      table_indexes_size: EctoMySQLExtras.TableIndexesSize,
      table_size: EctoMySQLExtras.TableSize,
      total_index_size: EctoMySQLExtras.TotalIndexSize,
      total_table_size: EctoMySQLExtras.TotalTableSize
    }
  end

  @spec query(atom(), repo(), keyword()) :: :ok | MyXQL.Result.t()
  def query(query_name, repo, opts \\ []) do
    query_module = Map.fetch!(queries(), query_name)
    opts = default_opts(opts)

    result = query!(repo, query_module.query(opts))

    format(
      Keyword.fetch!(opts, :format),
      query_module.info(),
      result
    )
  end

  defp query!({repo, node}, query) do
    case :rpc.call(node, repo, :query!, [query]) do
      {:badrpc, {:EXIT, {:undef, _}}} ->
        raise "repository is not defined on remote node"

      {:badrpc, error} ->
        raise "cannot send query to remote node #{inspect(node)}. Reason: #{inspect(error)}"

      result ->
        result
    end
  end

  defp query!(repo, query) do
    repo.query!(query)
  end

  @spec index_size(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def index_size(repo, opts \\ []), do: query(:index_size, repo, opts)

  @spec plugins(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def plugins(repo, opts \\ []), do: query(:plugins, repo, opts)

  @spec table_indexes_size(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def table_indexes_size(repo, opts \\ []), do: query(:table_indexes_size, repo, opts)

  @spec table_size(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def table_size(repo, opts \\ []), do: query(:table_size, repo, opts)

  @spec total_index_size(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def total_index_size(repo, opts \\ []), do: query(:total_index_size, repo, opts)

  @spec total_table_size(atom(), keyword()) :: :ok | MyXQL.Result.t()
  def total_table_size(repo, opts \\ []), do: query(:total_table_size, repo, opts)

  defp default_opts(opts) do
    default = [format: :raw]

    Keyword.merge(default, opts)
  end

  defp format(:raw, _info, result), do: result

  if Code.ensure_loaded?(TableRex) do
    defp format(:ascii, info, result) do
      names = Enum.map(info.columns, & &1.name)
      types = Enum.map(info.columns, & &1.type)

      rows =
        if result.rows == [] do
          [["No results", nil]]
        else
          Enum.map(result.rows, &parse_row(&1, types))
        end

      rows
      |> TableRex.quick_render!(names, info.title)
      |> IO.puts()
    end

    defp parse_row(list, types) do
      list
      |> Enum.zip(types)
      |> Enum.map(&format_value/1)
    end

    defp format_value({%Decimal{} = value, _}), do: Decimal.to_string(value)
    defp format_value({string, :string}), do: String.replace(string, "\n", "")
  else
    defp format(:ascii, _info, _result) do
      IO.warn("""
      If you want to display query results in ASCII format you should add `table_rex` as a dependency.
      """)
    end
  end
end
