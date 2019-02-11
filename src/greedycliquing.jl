"""
    mutable struct GreedyClique
        vertices::BitArray
        mutuals::BitArray
    end

# Arguments
- `vertices::BitArray`: Vertices in the subgraph that defines a clique. BitVector ranging
    over the number of vertex in the full graph that are true if identifies as a member of
    the clique and false otherwise.
- `mutuals::BitArray`: Vertices that neighbour the clique (potential clique members)
"""
struct GreedyClique <: AbstractClique
    mutuals::BitArray
    vertices::BitArray
    function GreedyClique(m::AbstractVector{Bool}, v::AbstractVector{Bool})
        size(v) == size(m) || throw(DimensionMismatch("size mismatch"))
        new(BitVector(m), BitVector(v))
    end
end

"""
    vertices(c::GreedyClique) -> BitArray

Return vertices of a clique as a logical vector.

"""
vertices(c::GreedyClique) = c.vertices

"""
    mutuals(c::GreedyClique) -> BitArray

Return mutual neighbours (potential clique members) as a logical vector.

"""
mutuals(c::GreedyClique) = c.mutuals

"""

    mergeable(c1::GreedyCliqye, c2::GreedyClique) -> Bool

Compare two cliques. They can be merged if the mutuals (neighbours) of one clique (C1)
AND the vertices of the other clique (c2) match the vertices of c2.

"""
function mergeable(c1::GreedyClique, c2::GreedyClique)
     can = all(mutuals( c1 ) .& vertices( c2 ) .== vertices(c2))
end

"""
    union(c1::GreedyClique, c2::GreedyClique) -> GreedyClique

    Merges two cliques

"""
function Base.union(c1::GreedyClique, c2::GreedyClique)
    GreedyClique(mutuals(c1) .& mutuals(c2), vertices(c1) .| vertices(c2))
end

"""
    greedycliquing(A::AbstractMatrix{Bool},  minsize::Int)

Greedy Cliquing Algorithm based off of:
https://gitlab.invenia.ca/invenia/autopredictor/blob/develop/Tools/PreProcessing/GreedyCliquing.m

Splits an adjacency matrix into cliques [1] and remaining non-cliquable
nodes. Compared to a previous version that acheives
maximum node set reduction through optimal cliquing, this version
finds a maximal clique, removes its nodes from the adjacency matrix,
and repeats until no cliques can be found. More discussion can be
found in this [2] Google doc.

[1] http://en.wikipedia.org/wiki/Clique_(graph_theory)
[2] https://docs.google.com/a/invenia.ca/document/d/1lLRfQT_TFJi1bTfIu_jGxDs1u9A9HYKX5s4Zta3VRNg/edit?usp=sharing


# Arguments
- `A::AbstractMatrix{Bool}`: Adjacency Matrix
- `minsize::Int`: Min greedyclique Size

# Returns
- `cliques::Array{Clique}`: Vector array of type Clique
- `singletons::Vector{Bool}`: Vector array of Bool. These indicate nodes not in a clique (singletons)

"""
function greedycliquing(m::AbstractMatrix{Bool}, minsize::Int)
    A = copy(m)
    removediagonal!(A)
    m, n = size(A)
    cliques = GreedyClique[]
    num_nodes_left = m
    nodes_left = fill(true, (m, 1))

    debug(LOGGER, "Searching for cliques within adjacency matrix A($m, $n)")

    for i in 1:m
        push!(cliques, anymaxclique(A))
        currSize = count(vertices(cliques[i]))
        num_nodes_left -= currSize

        if currSize < minsize
            debug(LOGGER, "Maximal clique at $i is less than the minimum size $minsize ($currSize)")
            pop!(cliques)
            break
        elseif num_nodes_left == 0

            # These two lines not in the original MATLAB code but needed
            v = vertices(cliques[i])
            nodes_left[v] .= false
            break
        end

        v = vertices(cliques[i])
        nodes_left[v] .= false
        A[v, :] .= false
        A[:, v] .= false

    end
    cliques = Clique[Clique(vertices(c)) for c in cliques]
    singletons = nodes_left[:]
    return cliques, singletons
end

"""
    anymaxclique(A::AbstractMatrix{Bool})

Finds any maximal clique in the adjacency matrix. To find a
maximal clique, it sorts the nodes by number of neighbours then if the
node can be added to the clique, it adds it to the clique. Note that this is not the
maximum clique.

# Arguments
- `A::AbstractMatrix{Bool}`: Adjacency Matrix
# Returns
- `Clique`: One of the maximal cliques in the adjaceny matrix.
"""
function anymaxclique(A::AbstractMatrix{Bool})
    numNeighbours = vec(sum(A, dims=2))
    m, n = size(A)
    maxSize = maximum(numNeighbours)
    idx = sortperm(numNeighbours, rev=true)
    clique = GreedyClique(A[idx[1], :], ind2log(idx[1], m))
    vertexCount = 1
    for i in idx[2:end]
        currC = GreedyClique(A[i, :], ind2log(i, m))
        if mergeable(clique, currC)
            clique = union(clique, currC)
            vertexCount += 1
            if vertexCount > maxSize
                return clique
            end
        end
    end
    return clique
end

# Sets square logical matrix diagonal to false.
removediagonal!(A::AbstractMatrix{Bool}) = (A[diagind(A)] .= false; nothing)

# Create a Bool vector of length n that is true at the index of idx and false otherwise
ind2log(idx::Integer, n::Int) = setindex!(fill(false, (n,)), true, idx)
