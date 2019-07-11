defmodule EctoFilter do
  @moduledoc """
  Aims in building database queries using data as filtering conditions.

  ## Filtering conditions

  Filtering conditions are represented as tuples consisting of field name, filtering rule
  and value to filter by. For example, `{:first_name, :equal, "Bob"}` will select all records
  with the `"Bob"` value of the `:first_name` field.
  You can use multiple conditions, in that case they will be combined in query.

  Also, it is possible to build queries based on field values of associated models.
  This can be achieved by condition nesting: `{:organization, nil, [{:name, :like, "acme"}]}` will
  select only records with the `:name` field of their associated as the `:organization` entity
  matching with the `"acme"` value.

  ## Operators

  Every filtering condition is handled by the corresponding operator — a function which takes
  the Ecto query and the filtering condition and returns the query with the filtering condition applied.

  Usually operators are defined as `c:apply/4` callback implementations in the filter module.

  EctoFilter includes default operators for [field value comparison](EctoFilter.Operators.Comparison.html),
  [array inclusion checking](EctoFilter.Operators.Inclusion.html),
  [matching values with pattern](EctoFilter.Operators.PatternMatching.html) and filtering by
  [values of the associated entities' fields](EctoFilter.Operators.Association.html).

  Also, operators for dealing with [PostgreSQL JSON/JSONB fields](EctoFilter.Operators.JSON.html)
  are available.

  ## Extending

  It is possible to implement custom filtering logic by defining custom filter modules.
  See examples below for more information.

  ## Examples:

  #### Basic filtering

      iex> Repo.insert!(%User{first_name: "Bob"})
      iex> Repo.insert!(%User{first_name: "Alice"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([])
      ...>   |> Repo.all()
      iex> length(result)
      2

      iex> Repo.insert!(%User{email: "bob@example.com"})
      iex> Repo.insert!(%User{email: "alice@example.com"})
      iex> result =
      ...>   User
      ...>   |> EctoFilter.filter([{:email, :equal, "alice@example.com"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).email
      "alice@example.com"

  #### Building custom filter

      iex> defmodule CustomFilter do
      ...>   use EctoFilter
      ...>
      ...>   def apply(query, {:name, :full_text_search, value}, _, User) do
      ...>     where(
      ...>       query,
      ...>       [..., u],
      ...>       fragment("to_tsvector(concat_ws(' ', ?, ?)) @@ plainto_tsquery(?)", u.first_name, u.last_name, ^value)
      ...>     )
      ...>   end
      ...>
      ...>   def apply(query, condition, type, context), do: super(query, condition, type, context)
      ...> end
      iex> Repo.insert!(%User{first_name: "Bob", last_name: "Doe"})
      iex> Repo.insert!(%User{first_name: "Alice", last_name: "Roe"})
      iex> result =
      ...>   User
      ...>   |> CustomFilter.filter([{:name, :full_text_search, "alice roe"}])
      ...>   |> Repo.all()
      iex> length(result)
      1
      iex> hd(result).first_name
      "Alice"

  """

  @type condition :: {field :: atom, rule :: atom, value :: any}
  @type field_type :: Ecto.Type.t() | Ecto.Embedded.t() | Ecto.Association.t()

  @callback apply(
              query :: Ecto.Query.t(),
              condition :: condition(),
              type :: field_type(),
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
        with %{from: %{source: {_, context}}} <- Ecto.Queryable.to_query(query) do
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

  @doc """
  Adds filtering conditions to the query.
  """
  @spec filter(query :: Ecto.Query.t(), conditions :: [condition()]) :: Ecto.Query.t()
  defdelegate filter(query, conditions), to: __MODULE__.Default

  @spec introspect(queryable :: Ecto.Queryable.t(), field :: atom) :: field_type()
  def introspect(queryable, field) do
    schema_meta = &queryable.__schema__(&1, field)
    schema_meta.(:association) || schema_meta.(:embed) || schema_meta.(:type)
  end
end
