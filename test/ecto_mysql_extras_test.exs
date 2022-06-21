defmodule EctoMySQLExtrasTest do
  use ExUnit.Case

  import EctoMySQLExtras.TestUtil
  import ExUnit.CaptureIO
  import ExUnit.CaptureLog

  describe "queries" do
    test "returns all queries and info" do
      for query <- EctoMySQLExtras.queries() do
        {query_name, query_module} = query
        assert is_atom(query_name)

        query_info = query_module.info()
        assert query_info.title

        for column <- query_info.columns do
          assert column.name
          assert column.type
        end
      end
    end
  end

  describe "query raw format" do
    setup do
      start_supervised!(EctoMySQLExtras.TestRepo)
      :ok
    end

    test "run query" do
      for query <- EctoMySQLExtras.queries() do
        {query_name, query_module} = query

        result = EctoMySQLExtras.query(query_name, EctoMySQLExtras.TestRepo)

        assert length(result.columns) > 0
        assert result.columns == column_name_list(query_module.info())
      end
    end

    test "test query with logging enabled" do
      logs =
        capture_log(fn ->
          EctoMySQLExtras.db_settings(EctoMySQLExtras.TestRepo, query_opts: [log: true])
        end)

      assert logs =~ "ECTO_MYSQL_EXTRAS: "
    end

    test "run index_size query with args" do
      result = EctoMySQLExtras.index_size(EctoMySQLExtras.TestRepo, args: [table: "test"])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.IndexSize.info())
    end

    test "run long_running_queries query with args" do
      result =
        EctoMySQLExtras.long_running_queries(EctoMySQLExtras.TestRepo, args: [threshold: 1000])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.LongRunningQueries.info())
    end

    test "run records_rank query with args" do
      result = EctoMySQLExtras.records_rank(EctoMySQLExtras.TestRepo, args: [table: "test"])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.RecordsRank.info())
    end

    test "run table_indexes_size query with args" do
      result = EctoMySQLExtras.table_indexes_size(EctoMySQLExtras.TestRepo, args: [table: "test"])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.TableIndexesSize.info())
    end

    test "run table_size query with args" do
      result = EctoMySQLExtras.table_size(EctoMySQLExtras.TestRepo, args: [table: "test"])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.TableSize.info())
    end

    test "run total_table_size query with args" do
      result = EctoMySQLExtras.total_table_size(EctoMySQLExtras.TestRepo, args: [table: "test"])

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.TotalTableSize.info())
    end
  end

  describe "query ascii format" do
    setup do
      start_supervised!(EctoMySQLExtras.TestRepo)
      :ok
    end

    test "run query" do
      for query <- EctoMySQLExtras.queries() do
        {query_name, query_module} = query

        execute_query = fn ->
          EctoMySQLExtras.query(query_name, EctoMySQLExtras.TestRepo, format: :ascii)
        end

        for columns <- query_module.info().columns do
          assert capture_io(execute_query) =~ "| #{columns.name}"
        end
      end
    end
  end

  describe "format_ascii" do
    test "bytes" do
      assert EctoMySQLExtras.OutputAscii.format_value({0, :bytes}) == "0 bytes"
      assert EctoMySQLExtras.OutputAscii.format_value({1000, :bytes}) == "1000 bytes"
      assert EctoMySQLExtras.OutputAscii.format_value({1024, :bytes}) == "1.0 KB"
      assert EctoMySQLExtras.OutputAscii.format_value({1200, :bytes}) == "1.2 KB"
      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1024, :bytes}) == "1.0 MB"
      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1200, :bytes}) == "1.2 MB"
      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1024 * 1024, :bytes}) == "1.0 GB"
      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1024 * 1200, :bytes}) == "1.2 GB"

      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1024 * 1024 * 1024, :bytes}) ==
               "1.0 TB"

      assert EctoMySQLExtras.OutputAscii.format_value({1024 * 1024 * 1024 * 1024 * 1024, :bytes}) ==
               "1024.0 TB"
    end

    test "integer" do
      assert EctoMySQLExtras.OutputAscii.format_value({0, :integer}) == "0"
    end
  end

  # Access queries directly since we don't care about the actual DB output
  # but we care about the query input itself.
  describe "database specific" do
    test "mysql" do
      assert EctoMySQLExtras.DbSettings.query(db: :mysql) =~ "performance_schema"

      assert EctoMySQLExtras.DbStatus.query(db: :mysql) =~ "performance_schema"

      assert EctoMySQLExtras.DirtyPagesRatio.query(db: :mysql) =~ "performance_schema"

      assert EctoMySQLExtras.LongRunningQueries.query(
               db: :mysql,
               version: "8.0.0",
               threshold: 500
             ) =~
               "performance_schema"

      assert EctoMySQLExtras.LongRunningQueries.query(
               db: :mysql,
               version: "5.7.0",
               threshold: 500
             ) =~
               "information_schema"

      assert EctoMySQLExtras.LongRunningQueries.query(
               db: :mysql,
               version: "8.0.0",
               threshold: 1000
             ) =~ "TIME > 1"

      assert EctoMySQLExtras.TableCache.query(db: :mysql) =~ "performance_schema"

      assert EctoMySQLExtras.WaitsForCheckpoint.query(db: :mysql) =~ "performance_schema"

      assert EctoMySQLExtras.WaitsForRedolog.query(db: :mysql) =~ "performance_schema"
    end

    test "mariadb" do
      assert EctoMySQLExtras.DbSettings.query(db: :mariadb) =~ "information_schema"

      assert EctoMySQLExtras.DbStatus.query(db: :mariadb, major_version: 10, minor_version: 5) =~
               "performance_schema"

      assert EctoMySQLExtras.DbStatus.query(db: :mariadb, major_version: 10, minor_version: 3) =~
               "information_schema"

      assert EctoMySQLExtras.DbStatus.query(db: :mariadb, major_version: 10, minor_version: 4) =~
               "information_schema"

      assert EctoMySQLExtras.DirtyPagesRatio.query(db: :mariadb) =~ "information_schema"

      assert EctoMySQLExtras.LongRunningQueries.query(db: :mariadb, threshold: 500) =~
               "information_schema"

      assert EctoMySQLExtras.LongRunningQueries.query(db: :mariadb, threshold: 500) =~
               "TIME_MS > 500"

      assert EctoMySQLExtras.TableCache.query(db: :mariadb) =~ "information_schema"

      assert EctoMySQLExtras.WaitsForCheckpoint.query(db: :mariadb) =~ "information_schema"

      assert EctoMySQLExtras.WaitsForRedolog.query(db: :mariadb) =~ "information_schema"
    end
  end

  describe "remote query" do
    setup context do
      if context[:distribution] do
        start_supervised!(EctoMySQLExtras.TestRepo)
        # Node names are configured in test_helper.exs
        node_name = Application.fetch_env!(:ecto_mysql_extras, :node_name)

        {:ok, node_name: node_name}
      else
        :ok
      end
    end

    @tag :distribution
    test "run query", %{node_name: node_name} do
      assert Node.connect(node_name)

      for query <- EctoMySQLExtras.queries() do
        {query_name, query_module} = query

        result = EctoMySQLExtras.query(query_name, {EctoMySQLExtras.TestRepo, node_name})

        assert length(result.columns) > 0
        assert result.columns == column_name_list(query_module.info())
      end
    end

    @tag :distribution
    test "run query with logging enabled", %{node_name: node_name} do
      assert Node.connect(node_name)

      logs =
        capture_log(fn ->
          EctoMySQLExtras.query(:db_settings, {EctoMySQLExtras.TestRepo, node_name},
            query_opts: [log: true]
          )
        end)

      assert logs =~ "ECTO_MYSQL_EXTRAS: "
    end

    @tag :distribution
    test "fails when repo is not available", %{node_name: node_name} do
      assert Node.connect(node_name)

      assert_raise RuntimeError, "repository is not defined on remote node", fn ->
        EctoMySQLExtras.query(:plugins, {EctoMySQLExtras.InvalidRepo, node_name})
      end
    end

    test "fails when node is not available" do
      node_name = :"nonexisting@127.0.0.1"

      assert_raise RuntimeError,
                   "cannot send query to remote node #{inspect(node_name)}. Reason: :nodedown",
                   fn ->
                     EctoMySQLExtras.query(:plugins, {EctoMySQLExtras.TestRepo, node_name})
                   end
    end
  end
end
