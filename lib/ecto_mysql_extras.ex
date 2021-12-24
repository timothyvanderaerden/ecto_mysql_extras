defmodule EctoMySQLExtras do
  @moduledoc """
  Documentation for `EctoMySQLExtras`.
  """
  import EctoMySQLExtras.Output

  @callback info :: %{
              required(:title) => String.t(),
              required(:columns) => [%{name: atom(), type: atom()}],
              optional(:order_by) => [{atom(), :ASC | :DESC}],
              optional(:args) => [atom()],
              optional(:default_args) => list()
            }

  @type repo() :: module() | {module(), node()}

  @check_database [
    :db_settings,
    :db_status,
    :dirty_pages_ratio,
    :long_running_queries,
    :waits_for_checkpoint,
    :waits_for_redolog
  ]

  @spec queries(repo()) :: map()
  def queries(_repo \\ nil) do
    %{
      db_settings: EctoMySQLExtras.DbSettings,
      db_status: EctoMySQLExtras.DbStatus,
      dirty_pages_ratio: EctoMySQLExtras.DirtyPagesRatio,
      index_size: EctoMySQLExtras.IndexSize,
      long_running_queries: EctoMySQLExtras.LongRunningQueries,
      plugins: EctoMySQLExtras.Plugins,
      records_rank: EctoMySQLExtras.RecordsRank,
      table_indexes_size: EctoMySQLExtras.TableIndexesSize,
      table_size: EctoMySQLExtras.TableSize,
      total_index_size: EctoMySQLExtras.TotalIndexSize,
      total_table_size: EctoMySQLExtras.TotalTableSize,
      unused_indexes: EctoMySQLExtras.UnusedIndexes,
      waits_for_checkpoint: EctoMySQLExtras.WaitsForCheckpoint,
      waits_for_redolog: EctoMySQLExtras.WaitsForRedolog
    }
  end

  @doc """
  Run a query with `name`, on `repo`, in the given `format`.
  The `repo` can be a module name or a tuple like `{module, node}`.

  ## Options
    * `:format` - The format that results will return. Accepts `:ascii` or `:raw`.
      If `:ascii` a nice table printed in ASCII - a string will be returned.
      Otherwise a result struct will be returned. This option is required.

    * `:args` - Overwrites the default arguments for the given query. You can
      check the defaults of each query in its modules defined in this project.
  """
  @spec query(atom(), repo(), keyword()) :: :ok | MyXQL.Result.t()
  def query(query_name, repo, opts \\ []) do
    query_module = Map.fetch!(queries(), query_name)
    opts = default_opts(opts, query_module.info[:default_args])

    result =
      query!(
        repo,
        query_module.query(Keyword.fetch!(opts, :args) |> database_opts(repo, query_name))
      )

    format(
      Keyword.fetch!(opts, :format),
      query_module.info,
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

  # Not sure if this is the best way to retrieve the database
  defp get_database_and_version(repo) do
    version =
      query!(repo, "SHOW VARIABLES LIKE 'version'")
      |> (&Enum.at(&1.rows, 0)).()
      |> (&Enum.at(&1, 1)).()
      |> String.downcase()

    which_database(version) ++ which_version(version)
  end

  @spec db_settings(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def db_settings(repo, opts \\ []), do: query(:db_settings, repo, opts)

  @spec db_status(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def db_status(repo, opts \\ []), do: query(:db_status, repo, opts)

  @spec dirty_pages_ratio(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def dirty_pages_ratio(repo, opts \\ []), do: query(:dirty_pages_ratio, repo, opts)

  @spec index_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def index_size(repo, opts \\ []), do: query(:index_size, repo, opts)

  @spec long_running_queries(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def long_running_queries(repo, opts \\ []), do: query(:long_running_queries, repo, opts)

  @spec records_rank(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def records_rank(repo, opts \\ []), do: query(:records_rank, repo, opts)

  @spec plugins(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def plugins(repo, opts \\ []), do: query(:plugins, repo, opts)

  @spec table_indexes_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def table_indexes_size(repo, opts \\ []), do: query(:table_indexes_size, repo, opts)

  @spec table_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def table_size(repo, opts \\ []), do: query(:table_size, repo, opts)

  @spec total_index_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def total_index_size(repo, opts \\ []), do: query(:total_index_size, repo, opts)

  @spec total_table_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def total_table_size(repo, opts \\ []), do: query(:total_table_size, repo, opts)

  @spec unused_indexes(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def unused_indexes(repo, opts \\ []), do: query(:unused_indexes, repo, opts)

  @spec waits_for_checkpoint(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def waits_for_checkpoint(repo, opts \\ []), do: query(:waits_for_checkpoint, repo, opts)

  @spec waits_for_redolog(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def waits_for_redolog(repo, opts \\ []), do: query(:waits_for_redolog, repo, opts)

  defp default_opts(opts, nil), do: default_opts(opts, [])

  defp default_opts(opts, default_args) do
    format = Keyword.get(opts, :format, :raw)

    args =
      Keyword.merge(
        default_args || [],
        opts[:args] || []
      )

    [
      format: format,
      args: args
    ]
  end

  defp database_opts(opts, repo, query) when query in @check_database do
    database = get_database_and_version(repo)
    Keyword.merge(database, opts)
  end

  defp database_opts(opts, _repo, _query), do: opts

  defp which_database(version) do
    if String.contains?(version, "mariadb") do
      [db: :mariadb]
    else
      [db: :mysql]
    end
  end

  defp which_version(version) do
    semver = String.split(version, ".")
    major_version = semver |> Enum.at(0) |> String.to_integer()
    minor_version = semver |> Enum.at(1) |> String.to_integer()

    [version: version, major_version: major_version, minor_version: minor_version]
  end
end
