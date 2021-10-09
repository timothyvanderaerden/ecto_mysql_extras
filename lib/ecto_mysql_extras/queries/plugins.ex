defmodule EctoMySQLExtras.Plugins do
  @moduledoc """
  Query all installed plugins.

  Data is retrieved from the `information_schema` database and the `plugins` table.
  """
  @behaviour EctoMySQLExtras

  def info do
    %{
      title: "Available and installed plugins",
      columns: [
        %{name: :name, type: :string},
        %{name: :version, type: :string},
        %{name: :status, type: :string},
        %{name: :type, type: :string},
        %{name: :description, type: :string}
      ]
    }
  end

  def query(_args \\ []) do
    """
    /* ECTO_MYSQL_EXTRAS: #{info().title} */

    SELECT
      PLUGIN_NAME AS `name`,
      PLUGIN_VERSION AS `version`,
      PLUGIN_STATUS AS `status`,
      PLUGIN_TYPE AS `type`,
      PLUGIN_DESCRIPTION AS `description`
    FROM information_schema.plugins;
    """
  end
end
