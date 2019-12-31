# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadLAP.jl")
include("setTSP.jl")
include("setLAP.jl")
#include("solveTSPD.jl")
include("solveTSPD2.jl")



#=include("getfname.jl")

# =========================================================================== #

# Setting the data
fname = "Desktop/solveSPP/Data/didactic.dat"  # path for a standard config on macOS
cost, matrix = loadSPP(fname)

# Proceeding to the optimization
solverSelected = GLPK.Optimizer
ip, ip_x = setSPP(solverSelected, cost, matrix)
println("Solving..."); optimize!(ip)

# Displaying the results
println("z  = ", objective_value(ip))
print("x  = "); println(value.(ip_x))

# =========================================================================== #

# Collecting the names of instances to solve
target = "Desktop/solveSPP/Data"            # path for a standard config on macOS
fnames = getfname(target)
=#
