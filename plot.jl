using PyPlot
function plotTSP(ins)
	S,D = loadTSP(ins)
	sol = solveTSP(D)
	w = 4
	h = 3
	d = 70

	# println(sol)
	# println(S)

	# verts
	verts = Tuple{Float64,Float64}[]
	for i in sol
		# println("i =",i)
		push!(verts, (S[i,1],S[i,2]))
	end
	codes = zeros(Int64, length(verts))
	codes[1]=1
	for i in 2:length(codes)
		codes[i] = 2
	end
	# figure(figsize=(w, h), dpi=d)
	fig, ax = subplots(figsize=(10,10))


	ax.axis([-10, 110, -10, 110])

	string_path = PyPlot.matplotlib.path.Path(verts, codes)

	for i in 1:length(verts)-1
		patch = PyPlot.matplotlib.patches.FancyArrowPatch(verts[i], verts[i+1], arrowstyle="->", mutation_scale=10,edgecolor="green")
		ax.add_patch(patch)
	end

	for i in verts
		println(i)
		ax.plot(i[1],i[2], marker="o", color="red",markeredgecolor="green")
	end
	for i in 1:size(S)[1]
		text(S[i,1],S[i,2]+2, S[i,3], fontsize=12,horizontalalignment="center")
	end

end
