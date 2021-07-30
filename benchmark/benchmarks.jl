using BenchmarkTools

using Cliquing: greedycliquing, greedycliquing!, anymaxclique
using LinearAlgebra
using Random

const SUITE = BenchmarkGroup()

# The functions here take milliseconds
# Up the time tolerance to avoid errors during comparison
BenchmarkTools.DEFAULT_PARAMETERS.time_tolerance = 0.10

rng = MersenneTwister(1234)

# Show how performance changes when Matrix size increases
# Matrices in NodeSelection tests are approx 50x50
for (n, A) in ("random$x" => rand(rng, Bool, x, x) for x in (25, 50, 100))
    # The type of matrix affects performance
    M = Matrix(Symmetric(A))
    B = BitMatrix(M)

    group = BenchmarkGroup()

    for f in (greedycliquing, greedycliquing!)
        function_group = BenchmarkGroup()
        function_group["Matrix{Bool}"] = BenchmarkGroup()
        function_group["BitMatrix"] = BenchmarkGroup()

        # Show how performance changes when minsize increases
        for i in (2, 4, 10)
            function_group["Matrix{Bool}"]["minsize=$i"] = @benchmarkable $f(X, $i) setup=(X = deepcopy($M))
            function_group["BitMatrix"]["minsize=$i"] = @benchmarkable $f(X, $i) setup=(X = deepcopy($B))
        end

        group["$f"] = function_group
    end

    function_group = BenchmarkGroup()
    # This is an internal function that is called repeatedly in greedycliquing
    function_group["Matrix{Bool}"] = @benchmarkable anymaxclique(X) setup=(X = deepcopy($M))
    function_group["BitMatrix"] = @benchmarkable anymaxclique(X) setup=(X = deepcopy($B))

    group["anymaxclique"] = function_group
    SUITE["$n"] = group
end
