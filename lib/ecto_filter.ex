defmodule EctoFilter do
  @moduledoc """
  Documentation for EctoFilter.
  """

  @callback apply(
              Ecto.Query.t(),
              {field :: atom, rule :: atom, value :: any},
              type :: any,
              context :: Ecto.Queriable.t()
            ) :: Ecto.Query.t()

  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)

      import unquote(__MODULE__), only: [introspect: 2]

      import Ecto.Query

      use EctoFilter.Operators

      def filter(query, conditions \\ [], context \\ nil)

      def filter(query, [], _), do: query

      def filter(query, conditions, nil) do
        with %{from: {_, context}} <- Ecto.Queryable.to_query(query) do
          filter(query, conditions, context)
        else
          _ -> raise "Unable to get filter context from #{inspect(query)}"
        end
      end

      def filter(query, [{field, operation, value} | tail], context) do
        type = introspect(context, field)

        query
        |> __MODULE__.apply({field, operation, value}, type, context)
        |> filter(tail, context)
      end

      defoverridable unquote(__MODULE__)
    end
  end

  defdelegate filter(query, conditions), to: __MODULE__.Default

  def introspect(queryable, field) do
    schema_meta = &queryable.__schema__(&1, field)
    schema_meta.(:association) || schema_meta.(:embed) || schema_meta.(:type)
  end
end
