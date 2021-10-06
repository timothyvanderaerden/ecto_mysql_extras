defmodule EctoMySQLExtras.TestUtil do
  @moduledoc false

  def column_name_list(info) do
    Enum.map(info.columns, fn column ->
      Atom.to_string(column.name)
    end)
  end
end
