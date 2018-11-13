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

using Forecasters
using Memento
using Compat: Compat, @__MODULE__, nameof
using Compat.LinearAlgebra

const LOGGER = getlogger(@__MODULE__)

function __init__()
    # https://invenia.github.io/Memento.jl/latest/faq/pkg-usage.html
    Memento.register(LOGGER)
end

# TODO: make this a package, with a macro maybe
struct NotImplementedError <: Exception
    func_ref
    type_ref
end

function Base.showerror(io::IO, err::NotImplementedError)
    print(io, nameof(err.func_ref), " is not defined for ", nameof(err.type_ref), ".")
end

abstract type AbstractCliquer end #  Defines a cliquing route
abstract type AbstractClique end # Defines a clique object

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
function correlate(ac::AbstractCliquer, args...; kwargs...)
    # We could put the correlation method here too
    throw(NotImplementedError(correlate, typeof(ac)))
end

"""
    clique(de::AbstractCliquer, args...; kwargs...) -> Array{Clique}
"""
function clique(ac::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(clique, typeof(ac)))
end

"""
    threshold(de::AbstractCliquer, args...; kwargs...) -> Matrix{Bool}
"""
function threshold(agent::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(threshold, typeof(ac)))
end

"""
    fetch(df::AbstractCliquer, args...; kwargs...)

Defines the data-grabbing function
"""
function Forecasters.fetch(agent::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(fetch, typeof(ac)))
end

function Forecasters.transform(agent::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(transform, typeof(ac)))
end

function Base.filter(agent::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(filter, typeof(ac)))
end

"""
    process(df::AbstractCliquer, args...; kwargs...)

Defines the data-grabbing function.
"""
function process(agent::AbstractCliquer, args...; kwargs...)
    throw(NotImplementedError(process, typeof(ac)))
end

# Put all the algorithmic routines in here.
include("greedycliquing.jl")

end
