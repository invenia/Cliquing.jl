using Cliquing
using Test

@testset "Cliquing.jl" begin
    @testset "Greedy Cliquing: Routine" begin
        @testset "AnyMaxClique" begin
            # AnyMaxClique
            a = Bool[1 1 0 0; 1 1 1 0; 0 1 1 1; 0 0 1 1]
            Cliquing.removediagonal!(a)
            out = Cliquing.anymaxclique(a)
            @test typeof(out) == GreedyClique
            @test Cliquing.mutuals(out) == BitVector([0, 0, 0, 0])
            @test Cliquing.vertices(out) == BitVector([0, 1, 1, 0])
        end

        @testset "NewClique" begin
            # NewClique
            connections = [true, false, true, false]
            v = [false, true, false, false]
            clique = GreedyClique(connections, v)
            @test Cliquing.mutuals(clique) == BitVector([1, 0, 1, 0])
            @test Cliquing.vertices(clique) == BitVector([0, 1, 0, 0])
        end

        @testset "CanMergeCliques" begin
            # CanMergeCliques
            c1 = GreedyClique(Bool[1, 0, 1, 0], Bool[0, 1, 0, 0])
            c2 = GreedyClique(Bool[0, 1, 0, 1], Bool[0, 0, 1, 0])
            out = Cliquing.mergeable(c1, c2)
            #@test size(out) == (4,)
            #@test out == [true, true, true, true]
            @test out == true
        end

        # UnionCliques
        @testset "UnionCliques" begin
            c1 = GreedyClique(Bool[1, 0, 1, 0,], Bool[0, 1, 0, 0,])
            c2 = GreedyClique(Bool[0, 1, 0, 1], Bool[0, 0, 1, 0])
            out = Cliquing.union(c1, c2)
            @test Cliquing.mutuals(out) == BitVector([0, 0, 0, 0])
            @test Cliquing.vertices(out) == BitVector([0, 1, 1, 0])
        end

        # GreedyCliquing
        @testset "GreedyCliqing" begin
            a = Bool[1 1 0 0; 1 1 1 0; 0 1 1 1; 0 0 1 1]
            cliques, singletons = greedycliquing(a, 2)
            @test Cliquing.member(cliques[1]) == BitVector([0, 1, 1, 0])

            # Use the cliques [1,2,5] and [3,4] from https://en.wikipedia.org/wiki/Adjacency_matrix
            M = Bool[1 1 0 0 1 0; 1 0 1 0 1 0; 0 1 0 1 0 0; 0 0 1 0 1 1; 1 1 0 1 0 0; 0 0 0 1 0 0]
            cliques, singletons = greedycliquing(M, 2)
            @test Cliquing.member(cliques[1]) == BitVector([1, 1, 0, 0, 1, 0])
            @test Cliquing.member(cliques[2]) == BitVector([0, 0, 1, 1, 0, 0])
            @test singletons == BitVector([0, 0, 0, 0, 0, 1])

            # Another test. Create a designed matrix where AnyMaxClique returns a clique
            # that does not contain the node with the largest number of neighbours
            a = Bool[
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
                0 0 0 0 1 0 0 0 0 0 0 0
            ]

            cliques, singletons = greedycliquing(a, 2)
            @test size(cliques) == (2,)
            @test Cliquing.member(cliques[2]) == BitVector([1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0])
            @test Cliquing.head(cliques[2]) == BitVector([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            @test Cliquing.member(cliques[1]) == BitVector([0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0])
            @test Cliquing.head(cliques[1]) == BitVector([0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0])
            @test singletons == BitVector([0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1])

            a = Bool[
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                1 1 1 1 0 0 0 0 0 0 0 0
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
                0 0 0 0 1 1 1 1 1 1 1 1
            ]

            cliques, singletons = greedycliquing(a, 2)
            @test size(cliques) == (2,)
            @test Cliquing.member(cliques[2]) == BitVector([1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0])
            @test Cliquing.head(cliques[2]) == BitVector([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
            @test Cliquing.member(cliques[1]) == BitVector([0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1])
            @test Cliquing.head(cliques[1]) == BitVector([0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0])
            @test singletons == BitVector([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

            # Non-symmetric matrix input
            A = Bool[1 1 1 0; 1 1 1 0; 0 1 1 1; 0 0 0 1]
            @test_throws ArgumentError greedycliquing(A, 2)
        end
    end
end
