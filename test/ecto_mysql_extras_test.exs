defmodule EctoMySQLExtrasTest do
  use ExUnit.Case

  Logger.configure(level: :info)

  import EctoMySQLExtras.TestUtil
  import ExUnit.CaptureIO

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

    test "run index_size query with args" do
      result = EctoMySQLExtras.index_size(EctoMySQLExtras.TestRepo, table: "test")

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.IndexSize.info())
    end

    test "run table_indexes_size query with args" do
      result = EctoMySQLExtras.table_indexes_size(EctoMySQLExtras.TestRepo, table: "test")

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.TableIndexesSize.info())
    end

    test "run table_size query with args" do
      result = EctoMySQLExtras.table_size(EctoMySQLExtras.TestRepo, table: "test")

      assert length(result.columns) > 0
      assert result.columns == column_name_list(EctoMySQLExtras.TableSize.info())
    end

    test "run total_table_size query with args" do
      result = EctoMySQLExtras.total_table_size(EctoMySQLExtras.TestRepo, table: "test")

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

  describe "format_value" do
    test "bytes" do
      assert EctoMySQLExtras.Output.format_value({0, :bytes}) == "0 bytes"
      assert EctoMySQLExtras.Output.format_value({1000, :bytes}) == "1000 bytes"
      assert EctoMySQLExtras.Output.format_value({1024, :bytes}) == "1.0 KB"
      assert EctoMySQLExtras.Output.format_value({1200, :bytes}) == "1.2 KB"
      assert EctoMySQLExtras.Output.format_value({1024 * 1024, :bytes}) == "1.0 MB"
      assert EctoMySQLExtras.Output.format_value({1024 * 1200, :bytes}) == "1.2 MB"
      assert EctoMySQLExtras.Output.format_value({1024 * 1024 * 1024, :bytes}) == "1.0 GB"
      assert EctoMySQLExtras.Output.format_value({1024 * 1024 * 1200, :bytes}) == "1.2 GB"
      assert EctoMySQLExtras.Output.format_value({1024 * 1024 * 1024 * 1024, :bytes}) == "1.0 TB"

      assert EctoMySQLExtras.Output.format_value({1024 * 1024 * 1024 * 1024 * 1024, :bytes}) ==
               "1024.0 TB"
    end

    test "integer" do
      assert EctoMySQLExtras.Output.format_value({0, :integer}) == "0"
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
