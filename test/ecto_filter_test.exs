defmodule EctoFilterTest do
  use EctoFilter.DataCase

  doctest EctoFilter

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

    test "not equal" do
      users = for email <- ~w(foo@bar.baz example@example.com), do: insert(:user, email: email)
      expected_result = hd(users)

      condition = [{:email, :not_equal, "example@example.com"}]

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
      author = insert(:user)
      author2 = insert(:user)

      insert_list(2, :post, title: "Here is acme news", author: author)
      insert_list(4, :post, title: "Also acme posts", author: author2)
      insert_list(8, :post, title: "Skip that")

      condition = [
        {:posts, nil, [{:title, :like, "acme"}]}
      ]

      results = User |> do_filter(condition)

      assert 2 == length(results)
      assert MapSet.new([author, author2]) == MapSet.new(results)
    end
  end

  defp do_filter(filter_module \\ EctoFilter, repo \\ Repo, queryable, condition) do
    queryable
    |> filter_module.filter(condition)
    |> repo.all()
  end
end
