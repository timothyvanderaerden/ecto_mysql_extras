defmodule EctoMySQLExtras.Output do
  @moduledoc """
  Output MySQL queries to the requested format.

  Formats:
  * `raw`: The raw MySQL query result (%MyXQL.Result{})
  * `ascii`: The query result formatted to ASCII.
  """
  import EctoMySQLExtras.OutputAscii

  def format(:raw, _info, result), do: result
  def format(:ascii, info, result), do: format(info, result)
end
