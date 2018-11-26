defmodule Rummage.Phoenix.PaginateView do
  @moduledoc """
  View Helper for Pagination in Rummage for bootstrap views.

  Usage:

  ```elixir
  defmodule MyApp.ProductView do
    use MyApp.Web, :view
    use Rummage.Phoenix.View, only: [:paginate]
  end
  ```

  OR

  ```elixir
  defmodule MyApp.ProductView do
    use MyApp.Web, :view
    use Rummage.Phoenix.View
  end
  ```

  """

  use Rummage.Phoenix.ThemeAdapter
  import Rummage.Phoenix.Gettext

  @doc """
  This macro includes the helper functions for pagination

  Provides helper functions `pagination_link/3` for creating pagination links in an html.eex
  file of using `Phoenix`.

  Usage:
  Just add the following code in the index template. Make sure that you're passing
  rummage from the controller. Please look at the
  [README](https://github.com/Excipients/rummage_phoenix) for more details

  ```elixir
  pagination_link(@conn, @rummage)
  ```
  """
  def pagination_link(conn, rummage, opts \\ []) do
    pagination_links do
      [first_page_link(conn, rummage, opts)] ++
      [previous_page_link(conn, rummage, opts)] ++
      middle_page_links(conn, rummage, opts) ++
      [next_page_link(conn, rummage, opts)] ++
      [last_page_link(conn, rummage, opts)]
    end
  end

  def pagination_with_all_link(conn, rummage, opts \\ []) do
    pagination_links do
      [first_page_link(conn, rummage, opts)] ++
      [previous_page_link(conn, rummage, opts)] ++
      middle_page_links(conn, rummage, opts) ++
      [next_page_link(conn, rummage, opts)] ++
      [last_page_link(conn, rummage, opts)] ++
      [all_page_link(conn, rummage, opts)]
    end
  end

  def all_page_link(conn, rummage, opts) do
    paginate_params = rummage.paginate

    per_page = paginate_params.per_page
    label = opts[:all_label] || gettext("All")

    case per_page == -1 do
      true -> page_link "#", :disabled, do: label
      false ->
        page_link index_path(opts, [conn, :index,
          transform_params(rummage, -1, 1, opts)]), do: label
    end
  end

  # def per_page_link(conn, rummage, opts \\ []) do
  #   import Phoenix.HTML.Form

  #   paginate_params = rummage.paginate

  #   form_for conn, index_path(opts, [conn, :index]), [as: :params, method: :get], fn(form) ->
  #     input = number_input(form, :per_page, value: paginate_params.per_page)
  #     submit = submit("Set Per Page", class: "btn btn-default")
  #     [input, submit]
  #   end
  # end

  defp first_page_link(conn, rummage, opts) do
    paginate_params = rummage.paginate

    page = paginate_params.page
    per_page = paginate_params.per_page
    # max_page_links = String.to_integer(paginate_params["max_page_links"] || "4")
    label = opts[:first_label] || gettext("First")

    case page == 1 do
      true -> page_link "#", :disabled, do: label
      false ->
        page_link index_path(opts, [conn, :index,
          transform_params(rummage, per_page, 1, opts)]), do: label
    end
  end

  defp previous_page_link(conn, rummage, opts) do
    paginate_params = rummage.paginate

    page = paginate_params.page
    per_page = paginate_params.per_page
    label = opts[:previous_label] || gettext("Previous")

    case page <= 1 do
      true -> page_link "#", :disabled, do: label
      false ->
        page_link index_path(opts, [conn, :index,
          transform_params(rummage, per_page, page - 1, opts)]), do: label
    end
  end

  defp middle_page_links(conn, rummage, opts) do
    paginate_params = rummage.paginate

    page = paginate_params.page
    per_page = paginate_params.per_page
    max_page = paginate_params.max_page
    max_page_links = opts[:max_page_links] || Rummage.Phoenix.default_max_page_links

    lower_limit = cond do
      page <= div(max_page_links, 2) -> 1
      page >= (max_page - div(max_page_links, 2)) -> Enum.max([0, max_page - max_page_links]) + 1
      true -> page - div(max_page_links, 2)
    end

    upper_limit = lower_limit + max_page_links - 1

    Enum.map(lower_limit..upper_limit, fn(page_num) ->
      cond do
        page == page_num -> page_link "#", :active, do: page_num
        page_num > max_page -> ""
        true ->
          page_link index_path(opts, [conn, :index,
            transform_params(rummage, per_page, page_num, opts)]), do: page_num
      end
    end)
  end

  defp next_page_link(conn, rummage, opts) do
    paginate_params = rummage.paginate

    page = paginate_params.page
    per_page = paginate_params.per_page
    max_page = paginate_params.max_page
    label = opts[:next_label] || gettext("Next")

    case page >= max_page do
      true -> page_link "#", :disabled, do: label
      false ->
        page_link index_path(opts, [conn, :index,
          transform_params(rummage, per_page, page + 1, opts)]), do: label
    end
  end

  defp last_page_link(conn, rummage, opts) do
    paginate_params = rummage.paginate

    page = paginate_params.page
    per_page = paginate_params.per_page
    # max_page_links = String.to_integer(paginate_params["max_page_links"] || "4")
    max_page = paginate_params.max_page
    label = opts[:last_label] || gettext("Last")

    case page == max_page do
      true -> page_link "#", :disabled, do: label
      false ->
        page_link index_path(opts, [conn, :index,
          transform_params(rummage, per_page, max_page, opts)]), do: label
    end
  end

  defp transform_params(rummage, per_page, page, opts)
  defp transform_params(rummage, per_page, page, %{slugs: slugs, slugs_params: slugs_params}) do
    rummage = %{rummage: Map.put(rummage.params, "paginate", %{"per_page"=> per_page, "page"=> page})}
    slugs ++ Map.merge(rummage, slugs_params)
  end
  defp transform_params(rummage, per_page, page, _opts) do
    %{rummage:
        Map.put(rummage.params, :paginate,
        %{per_page: per_page, page: page})
    }
  end

  defp index_path(opts, params) do
    helpers = opts[:helpers]
    path_function_name = String.to_atom("#{opts[:struct]}_path")

    apply(helpers, path_function_name, params)
  end
end
