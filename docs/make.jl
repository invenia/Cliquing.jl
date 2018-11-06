using Documenter, Cliquing

makedocs(;
    modules=[Cliquing],
    format=:html,
    pages=[
        "Home" => "index.md",
    ],
    repo="https://gitlab.invenia.ca/invenia/Cliquing.jl/blob/{commit}{path}#L{line}",
    sitename="Cliquing.jl",
    authors="Eric Davies",
    assets=[
        "assets/invenia.css",
        "assets/logo.png",
    ],
)
