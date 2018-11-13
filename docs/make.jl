using Documenter, Cliquing

makedocs(;
    modules=[Cliquing],
    format=:html,
    pages=[
        "Home" => "index.md",
        "API" => "api.md"
    ],
    repo="https://gitlab.invenia.ca/invenia/Cliquing.jl/blob/{commit}{path}#L{line}",
    sitename="Cliquing.jl",
    authors="Invenia Technical Computing",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)
