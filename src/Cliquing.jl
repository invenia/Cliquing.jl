module Cliquing

export AbstractCliquer,
    AbstractClique,
    Clique,
    correlate,
    clique,
    threshold,
    fetch,
    transform,
    process
export GreedyClique,
    greedycliquing

# import used so we can add docstrings without adding new methods
import Base: filter
import Forecasters: fetch, transform
using Memento
using LinearAlgebra

const LOGGER = getlogger(@__MODULE__)

function __init__()
    # https://invenia.github.io/Memento.jl/latest/faq/pkg-usage.html
    Memento.register(LOGGER)
end

abstract type AbstractCliquer end  # Defines a cliquing route
abstract type AbstractClique end  # Defines a clique object

struct Clique <: AbstractClique
    head::BitVector
    member::BitVector

    function Clique(head::AbstractVector{Bool}, member::AbstractVector{Bool})
        size(head) == size(member) || throw(DimensionMismatch("size mismatch"))
        new(BitVector(head), BitVector(member))
    end
end

function Clique(member::AbstractVector{Bool}; allowsingle=false)
    head = falses(length(member))
    head[findfirst(member)] = true
    @assert sum(member) > 1
    Clique(head, member)
end
head(c::Clique) = c.head
member(c::Clique) = c.member
sizeindex(c::Clique) = length(head(c))


"""
    correlate(de::AbstractCliquer, args...; kwargs...) -> Matrix{<:Real}
"""
function correlate end

"""
    clique(de::AbstractCliquer, args...; kwargs...) -> Array{Clique}
"""
function clique end

"""
    threshold(de::AbstractCliquer, args...; kwargs...) -> Matrix{Bool}
"""
function threshold end

"""
    fetch(df::AbstractCliquer, args...; kwargs...)

Defines the data-grabbing function
"""
function fetch end

function transform end

function filter end

"""
    process(df::AbstractCliquer, args...; kwargs...)

Defines the data-grabbing function.
"""
function process end

# Put all the algorithmic routines in here.
include("greedycliquing.jl")

end
