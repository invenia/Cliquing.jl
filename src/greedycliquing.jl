"""
    struct GreedyClique
        vertices::BitArray
        mutuals::BitArray
    end

# Arguments
- `vertices::AbstractVector{Bool}`: Logical vector; true for each vertex that is a member
    of this clique.
- `mutuals::AbstractVector{Bool}`: Vertices that neighbour the clique (potential clique members)
"""
struct GreedyClique <: AbstractClique
    mutuals::BitArray
    vertices::BitArray
    function GreedyClique(m::AbstractVector{Bool}, v::AbstractVector{Bool})
        size(v) == size(m) || error(LOGGER, DimensionMismatch("size mismatch"))
        return new(BitVector(m), BitVector(v))
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

Compare two cliques. They can be merged if the mutuals (neighbours) of one clique (c1)
AND the vertices of the other clique (c2) match the vertices of c2.
"""
function mergeable(c1::GreedyClique, c2::GreedyClique)
    return all(mutuals(c1) .& vertices(c2) .== vertices(c2))
end

"""
    union(c1::GreedyClique, c2::GreedyClique) -> GreedyClique

Merges two cliques.
"""
function Base.union(c1::GreedyClique, c2::GreedyClique)
    return GreedyClique(mutuals(c1) .& mutuals(c2), vertices(c1) .| vertices(c2))
end

"""
    greedycliquing(A::AbstractMatrix{Bool}, minsize::Int)
    greedycliquing!(A::AbstractMatrix{Bool}, minsize::Int)

Greedy Cliquing Algorithm based off of previous MATLAB version.

Splits an adjacency matrix into cliques[^1] and remaining non-cliquable
nodes. Compared to a previous version that achieves
maximum node set reduction through optimal cliquing, this version
finds a maximal clique, removes its nodes from the adjacency matrix,
and repeats until no cliques can be found. More discussion can be
found in this[^2] Google doc.

[^1]: <http://en.wikipedia.org/wiki/Clique_(graph_theory)>
[^2]: Private Invenia document: <https://docs.google.com/a/invenia.ca/document/d/1lLRfQT_TFJi1bTfIu_jGxDs1u9A9HYKX5s4Zta3VRNg/edit?usp=sharing>

# Arguments
- `A::AbstractMatrix{Bool}`: Adjacency Matrix
- `minsize::Int`: Min greedyclique size

# Returns
- `cliques::Vector{Clique}`: Vector array of type Clique
- `singletons::Vector{Bool}`: Vector array of Bool. These indicate nodes not in a clique
"""
function greedycliquing(A::AbstractMatrix{Bool}, minsize::Integer)
    return greedycliquing!(collect(A), minsize)
end

# Avoid promoting BitMatrix to Matrix{Bool} as it has performance implications.
function greedycliquing(A::BitMatrix, minsize::Integer)
    return greedycliquing!(copy(A), minsize)
end

function greedycliquing!(A::Union{BitMatrix,Matrix{Bool}}, minsize::Integer)
    issymmetric(A) || error(LOGGER, ArgumentError("Input matrix not symmetric: $A"))
    removediagonal!(A)
    num_nodes = size(A, 1)
    singletons = fill(true, num_nodes)
    cliques = GreedyClique[]

    debug(LOGGER, "Searching for cliques within adjacency matrix A with $num_nodes nodes.")
    for i in 1:num_nodes
        push!(cliques, anymaxclique(A))
        clique_size = count(vertices(cliques[i]))
        num_nodes -= clique_size

        if clique_size < minsize
            # we won't always have found a maximal clique of at least size `minsize` yet, so
            # just remove it from our vector of Cliques
            pop!(cliques)
            break

        elseif num_nodes == 0
            # These two lines not in the original MATLAB code but needed
            v = vertices(cliques[i])
            singletons[v] .= false
            break
        end

        v = vertices(cliques[i])
        singletons[v] .= false
        A[v, :] .= false
        A[:, v] .= false
    end
    cliques = Clique[Clique(vertices(c)) for c in cliques]
    return cliques, singletons
end

"""
    anymaxclique(A::AbstractMatrix{Bool})

Finds any maximal clique in the adjacency matrix. To find a
maximal clique, it sorts the nodes by number of neighbours then if the
node can be added to the clique, it adds it to the clique. Note that this is not the
maximum clique.

# Arguments
- `A::AbstractMatrix{Bool}`: Adjacency Matrix.

# Returns
- `clique::GreedyClique`: One of the maximal cliques in the adjacency matrix.
"""
function anymaxclique(A::AbstractMatrix{Bool})
    numNeighbours = vec(sum(A; dims=2))
    m, n = size(A)
    maxSize = maximum(numNeighbours)
    idx = sortperm(numNeighbours; rev=true)
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
