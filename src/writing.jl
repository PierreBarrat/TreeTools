export write_newick, write_fasta


"""
"""
function write_newick(file::String, tree::Tree)
	write_newick(file, tree.root)
end


"""
"""
function write_newick(file::String, root::TreeNode)
	out = write_newick!(out, root)
	out *= ';'
	f = open(file, "w")
	write(f, out)
	close(f)
end


"""
"""
function write_newick!(s::String, root::TreeNode)
	if !isempty(root.child)
		s *= '('
		for c in root.child
			s = write_newick!(s, c)
			s *= ','
		end
		s = s[1:end-1] # Removing trailing ','
		s *= ')'
	end
	s *= root.label
	if !ismissing(root.data.tau)
		s *= ':'
		s *= string(root.data.tau)
	end
	return s
end

"""
"""
function write_fasta(file::String, tree::Tree ; internal = false)
	write_fasta(file, tree.root, internal = internal)
end

"""
"""
function write_fasta(file::String, root::TreeNode ; internal = false)
	out = write_fasta!("", root, internal)
	f = open(file, "w")
	write(f, out)
	close(f)
end

"""
"""
function write_fasta!(s::String, root::TreeNode, internal::Bool)
	if internal || root.isleaf
		s = s * ">$(root.label)\n$(num2seq(root.data.sequence))\n"
	end
	for c in root.child
		s = write_fasta!(s, c, internal)
	end
	return s
end

"""
"""
function num2seq(numseq::Array{Int64,1})
	mapping = "ACGT-"
	seq = ""
	for a in numseq
		seq *= mapping[a]
	end
	return seq
end	