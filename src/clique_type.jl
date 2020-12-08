abstract type AbstractClique end  # Defines a clique object

struct Clique <: AbstractClique
    head::BitVector
    member::BitVector

    function Clique(head::AbstractVector{Bool}, member::AbstractVector{Bool})
        size(head) == size(member) || throw(DimensionMismatch("size mismatch"))
        return new(BitVector(head), BitVector(member))
    end
end

function Clique(member::AbstractVector{Bool}; allowsingle=false)
    head = falses(length(member))
    head[findfirst(member)] = true
    @assert sum(member) > 1
    return Clique(head, member)
end

head(c::Clique) = c.head
member(c::Clique) = c.member
sizeindex(c::Clique) = length(head(c))
