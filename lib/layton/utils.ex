defmodule Layton.Utils do
  def json_to_struct(kind, json) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, v}, acc ->
      case Map.fetch(json, Atom.to_string(k)) do
        {:ok, jv} ->
          if is_map(v) && Map.has_key?(v, :__struct__) do
            %{acc | k => json_to_struct(Map.get(v, :__struct__), jv)}
          else
            %{acc | k => jv}
          end

        :error ->
          acc
      end
    end)
  end

  # This is Dangerous because it can create too many unwanted atoms
  def json_to_atom_map(json) do
    for {key, val} <- json, into: %{}, do: {String.to_atom(key), val}
  end

  def format_errors(errors) do
    errors
    |> Enum.map(&do_prettify/1)
    |> Enum.concat()
  end

  defp do_prettify({field_name, message}) when is_bitstring(message) do
    human_field_name =
      field_name
      |> Atom.to_string()
      |> String.replace("_", " ")
      |> String.capitalize()

    human_field_name <> " " <> message
  end

  defp do_prettify({field_name, {message, variables}}) do
    compound_message = do_interpolate(message, variables)
    do_prettify({field_name, compound_message})
  end

  defp do_interpolate(string, [{name, value} | rest]) do
    n = Atom.to_string(name)
    msg = String.replace(string, "%{#{n}}", do_to_string(value))
    do_interpolate(msg, rest)
  end

  defp do_interpolate(string, []), do: string
  defp do_to_string(value) when is_integer(value), do: Integer.to_string(value)
  defp do_to_string(value) when is_bitstring(value), do: value
  defp do_to_string(value) when is_atom(value), do: Atom.to_string(value)
end
