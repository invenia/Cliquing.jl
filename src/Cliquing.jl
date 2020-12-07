module Cliquing

using Memento
using LinearAlgebra

export AbstractClique, Clique
export GreedyClique, greedycliquing

const LOGGER = getlogger(@__MODULE__)

__init__() = Memento.register(LOGGER)

include("clique_type.jl")
include("greedycliquing.jl")

end
