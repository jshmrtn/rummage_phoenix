%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "apps/*/lib",
          "apps/*/test",
          "apps/*/mix.exs",
          "config/*.exs",
          "mix.exs",
          ".formatter.exs"
        ],
        excluded: []
      },
      checks: [
        # For others you can also set parameters
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Design.TagTODO, exit_status: 0},
        # Allow Namespaces for broader Alias
        {Credo.Check.Design.AliasUsage, priority: :low, if_nested_deeper_than: 2}
      ]
    }
  ]
}
