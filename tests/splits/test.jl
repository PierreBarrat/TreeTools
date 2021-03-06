using Test
using TreeTools

println("##### splits #####")

nwk1 = "(((A1,A2),(B1,B2),(C1,C2)),D,E)"
t = node2tree(parse_newick(nwk1)) #
S = SplitList(t)

@testset "1" begin
	expected = [
		["A1", "A2"],
		["B1", "B2"],
		["C1", "C2"],
		["A1", "A2", "B1", "B2", "C1", "C2"],
		["A1", "A2", "B1", "B2", "C1", "C2", "D", "E"]
	]
	@test [leaves(S,i) for i in eachindex(S)] == expected
	@test isequal(S, expected)
	@test S == expected
end

s4 = S.splitmap["NODE_4"] # ["B1", "B2"] ~ [3,4]
s5 = S.splitmap["NODE_5"] # ["C1", "C2"] ~ [5,6]
s45 = TreeTools.joinsplits(s4,s5)
@testset "2" begin
	@test s4 == Split([3,4])
	@test s4 != Split([3,4,5])
	@test in(s4, S)
	@test in(s5, S)
	@test !in(s45, S)
	@test s45.dat == Int[3,4,5,6]
	@test !isnothing(findfirst(==(s5), S.splits))
	@test isnothing(findfirst(==(s45), S.splits))
end

@testset "3" begin
	@test !TreeTools.is_root_split(S.splitmap["NODE_4"], S.mask)
	@test !TreeTools.is_root_split(S.splitmap["NODE_2"], S.mask)
	@test TreeTools.is_root_split(S.splitmap["NODE_1"], S.mask)
	@testset for n in internals(t)
		@test !TreeTools.is_leaf_split(S.splitmap[n.label])
	end
end

@testset "4" begin
	@testset for s in S, t in S
		@test arecompatible(s,t)
		@test arecompatible(s,t,S.mask)
		@test arecompatible(s,t,rand(Bool,8))
	end
	@test arecompatible(s4, s45)
	@test arecompatible(s5, s45)
end

@testset "5" begin
	t1 = Split([1,3])
	t2 = Split([1,2,3])
	t3 = Split([1,3,7,8])
	u = Split([7,8])
	@test !iscompatible(t1, S)
	@test !iscompatible(t2, S)
	@test !iscompatible(t3, S)
	@test iscompatible(u, S)
end

# Let's pretend we found (A1,A2,B1,B2) and (C1,C2,D) to be MCCs
Smcc = SplitList(S.leaves)
append!(Smcc.splits, [Split([1,2,3,4]), Split([5,6,7])])
@testset "6" begin
	Smapped = TreeTools.map_splits_to_tree(Smcc, t)
	@test leaves(Smapped, 1) == ["A1", "A2", "B1", "B2"]
	@test leaves(Smapped, 2) == ["A1", "A2", "B1", "B2", "C1", "C2", "D"]
	@test iscompatible(Smapped[1], S)
	@test iscompatible(Smapped[2], S)
end

# Unions
U = union(S, Smcc)
Sc = deepcopy(S)
union!(Sc, Smcc)
@testset "7" begin
	@test in(Smcc.splits[1], U)
	@test in(Smcc.splits[2], U)
	@test length(U) == length(S) + 2
	@test U == Sc
end

println()
