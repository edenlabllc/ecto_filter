defmodule EctoFilterTest do
  use EctoFilter.DataCase

  defmodule CustomFilter do
    use EctoFilter

    def apply(query, {:name, :full_text_search, value}, _, User) do
      where(
        query,
        [..., u],
        fragment(
          "to_tsvector(concat_ws(' ', ?, ?)) @@ plainto_tsquery(?)",
          u.first_name,
          u.last_name,
          ^value
        )
      )
    end

    def apply(query, condition, type, context), do: super(query, condition, type, context)
  end

  defmodule JSONFilter do
    use EctoFilter
    use EctoFilter.Operators.JSON

    def apply(query, condition, type, context), do: super(query, condition, type, context)
  end

  describe "filtering" do
    test "with empty condition" do
      insert_list(2, :user)

      results = do_filter(User, [])

      assert 2 = length(results)
    end

    test "with custom operators" do
      users =
        for attrs <- [
              %{first_name: "Jane", last_name: "Roe"},
              %{first_name: "Jonh", last_name: "Doe"}
            ] do
          insert(:user, attrs)
        end

      expected_result = hd(users)

      condition = [{:name, :full_text_search, "jane roe"}]

      results = do_filter(CustomFilter, User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end
  end

  describe "comparison operations" do
    test "equal" do
      users = for email <- ~w(foo@bar.baz example@example.com), do: insert(:user, email: email)
      expected_result = hd(users)

      condition = [{:email, :equal, "foo@bar.baz"}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "equal with nil" do
      users = for email <- [nil, "example@example.com"], do: insert(:user, email: email)
      expected_result = hd(users)

      condition = [{:email, :equal, nil}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "not equal" do
      users = for email <- ~w(foo@bar.baz example@example.com), do: insert(:user, email: email)
      expected_result = hd(users)

      condition = [{:email, :not_equal, "example@example.com"}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "not equal with nil" do
      users = for email <- ["foo@bar.baz", nil], do: insert(:user, email: email)
      expected_result = hd(users)

      condition = [{:email, :not_equal, nil}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "less than or equal" do
      users = for age <- [17, 18], do: insert(:user, age: age)
      expected_result = hd(users)

      condition = [{:age, :less_than_or_equal, 17}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "greater than or equal" do
      users = for age <- [20, 19], do: insert(:user, age: age)
      expected_result = hd(users)

      condition = [{:age, :greater_than_or_equal, 20}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "less than" do
      users = for age <- [15, 25], do: insert(:user, age: age)
      expected_result = hd(users)

      condition = [{:age, :less_than, 20}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "greater than" do
      users = for age <- [21, 17], do: insert(:user, age: age)
      expected_result = hd(users)

      condition = [{:age, :greater_than, 18}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end
  end

  describe "pattern matching operations" do
    test "like" do
      users = for first_name <- ~w(Jane John), do: insert(:user, first_name: first_name)
      expected_result = hd(users)

      condition = [{:first_name, :like, "jan"}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end
  end

  describe "inclusion operations" do
    test "in array" do
      users = for status <- ~w(NEW ACTIVE), do: insert(:user, status: status)
      expected_result = hd(users)

      condition = [{:status, :in, ["NEW", "SUSPENDED"]}]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "array contains" do
      posts = for tags <- [~w(lorem ipum dolor), ~w(dolor sit amet)], do: insert(:post, tags: tags)

      expected_result = hd(posts)

      condition = [{:tags, :contains, "lorem"}]

      results = do_filter(Post, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end
  end

  describe "association operations" do
    test "with one cardinality" do
      organizations = for name <- ~w(Acme Globex), do: insert(:organization, name: name)
      users = for organization <- organizations, do: insert(:user, organization: organization)
      expected_result = hd(users)

      condition = [
        {:organization, nil, [{:name, :like, "acme"}]}
      ]

      results = do_filter(User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "with many cardinality" do
      author1 = insert(:user, first_name: "Bob")
      author2 = insert(:user, first_name: "Alice")

      insert_list(2, :post, title: "Here is acme news", author: author1)
      insert_list(4, :post, title: "Also acme posts", author: author2)
      insert_list(8, :post, title: "Skip that")

      condition = [
        {:posts, nil, [{:title, :like, "acme"}]}
      ]

      results = do_filter(User, condition)

      assert 2 == length(results)
      assert MapSet.new([author1.id, author2.id]) == MapSet.new(Enum.map(results, & &1.id))
    end

    test "with many cardinality through another association" do
      [post1, post2, post3 | _] = insert_list(4, :post)
      [author1, author2] = for name <- ~w(Bob Alice), do: insert(:user, first_name: name)

      for post <- [post1, post2], do: insert_pair(:comment, author: author1, post: post)
      for post <- [post2, post3], do: insert_pair(:comment, author: author2, post: post)

      condition = [
        {:comments_authors, nil, [{:first_name, :like, "bob"}]}
      ]

      results = do_filter(Post, condition)

      assert 2 == length(results)
      assert MapSet.new([post1.id, post2.id]) == MapSet.new(Enum.map(results, & &1.id))
    end
  end

  describe "JSON operators" do
    test "array contains" do
      users = for interests <- [~w(Art Books), ~w(Books Comics)], do: insert(:user, interests: interests)
      expected_result = hd(users)

      condition = [
        {:interests, :contains, "Art"}
      ]

      results = do_filter(JSONFilter, User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "conditions on map" do
      users = for settings <- [%{foo: "bar"}, %{foo: "baz"}], do: insert(:user, settings: settings)
      expected_result = hd(users)

      condition = [
        {:settings, nil, [{:foo, :equal, "bar"}]}
      ]

      results = do_filter(JSONFilter, User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "conditions on nested map" do
      users = for settings <- [%{foo: %{bar: "baz"}}], do: insert(:user, settings: settings)
      expected_result = hd(users)

      condition = [
        {:settings, nil,
         [
           {:foo, nil, [{:bar, :equal, "baz"}]}
         ]}
      ]

      results = do_filter(JSONFilter, User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end

    test "conditions on array of maps" do
      users =
        for addresses <- Enum.chunk_every([%{city: "Kyiv"}, %{city: "Berlin"}, %{city: "Chicago"}], 2) do
          insert(:user, addresses: addresses)
        end

      expected_result = hd(users)

      condition = [
        {:addresses, nil, [{:city, :equal, "Kyiv"}]}
      ]

      results = do_filter(JSONFilter, User, condition)

      assert 1 = length(results)
      assert expected_result.id == hd(results).id
    end
  end

  defp do_filter(filter_module \\ EctoFilter, repo \\ Repo, queryable, condition) do
    queryable
    |> filter_module.filter(condition)
    |> repo.all()
  end
end
