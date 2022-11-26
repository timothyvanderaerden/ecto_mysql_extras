defmodule EctoMySQLExtras.OutputAscii do
  @moduledoc """
  Output MySQL queries to ASCII format using `:table_rex` library.
  """
  if Code.ensure_loaded?(TableRex) do
    def format(info, result) do
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

    def format_value({nil, _}), do: ""
    def format_value({integer, :bytes}) when is_integer(integer), do: format_bytes(integer)
    def format_value({string, :string}), do: String.replace(string, "\n", "")
    def format_value({other, _}), do: inspect(other)

    defp format_bytes(bytes) do
      cond do
        bytes >= memory_unit(:TB) -> format_bytes(bytes, :TB)
        bytes >= memory_unit(:GB) -> format_bytes(bytes, :GB)
        bytes >= memory_unit(:MB) -> format_bytes(bytes, :MB)
        bytes >= memory_unit(:KB) -> format_bytes(bytes, :KB)
        true -> format_bytes(bytes, :B)
      end
    end

    defp format_bytes(bytes, :B) when is_integer(bytes), do: "#{bytes} bytes"

    defp format_bytes(bytes, unit) when is_integer(bytes) do
      value = bytes / memory_unit(unit)
      "#{:erlang.float_to_binary(value, decimals: 1)} #{unit}"
    end

    defp memory_unit(:TB), do: 1024 * 1024 * 1024 * 1024
    defp memory_unit(:GB), do: 1024 * 1024 * 1024
    defp memory_unit(:MB), do: 1024 * 1024
    defp memory_unit(:KB), do: 1024
  else
    def format(_info, _result) do
      IO.warn("""
      If you want to display query results in ASCII format you should add `table_rex` as a dependency.
      """)
    end
  end
end
