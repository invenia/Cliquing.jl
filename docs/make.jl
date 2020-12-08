using Documenter, Cliquing

makedocs(;
    modules=[Cliquing],
    format=Documenter.HTML(
        prettyurls=(get(ENV, "CI", nothing) == "true"),
        edit_link="main",
        canonical="https://invenia.github.io/Cliquing.jl/stable",
    ),
    pages=[
        "Home" => "index.md",
        "API" => "api.md"
    ],
    repo="https://github.com/invenia/Cliquing.jl/blob/{commit}{path}#L{line}",
    sitename="Cliquing.jl",
    authors="Invenia Technical Computing",
    checkdocs=:exports,
    strict=true,
)

deploydocs(;
    repo="github.com/invenia/Cliquing.jl",
    devbranch="main",
)
