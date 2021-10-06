Code.require_file("support/test_repo.exs", __DIR__)

Application.put_env(:ecto_mysql_extras, :node_name, Node.self())

ExUnit.start()
