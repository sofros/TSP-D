# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadLAP.jl")
include("setTSP.jl")
include("setLAP.jl")
include("solveTSPD.jl")
include("getfname.jl")



function callTSPD(fnames)
    for f in fnames
        TSPD(f)
    end
end

function TSPD(fname)
println("\n======================================================================")
println("========= Calcul pour l'instance: ", fname, " ============")
println("======================================================================")
println("Mise en place du LAP:")
    nom, pos, dist, vDrone, vCamion, nbrNode = loadLAP(fname)
    ip, x = setLAP(1, dist)

println("\n Transphormation du LAP en TSP")
    ip, x = setTSP(ip, x)
    ordrePassage = ordonerPerm(x)


# Debut du Partitionnement exacte
    tempsOp = calculToutesOperation(dist, nbrNode, vDrone, vCamion, ordrePassage)
    M, P = matriceMeilleurTemps(tempsOp, nbrNode)
    M, P = voyageSimple(ordrePassage, dist, M, P)
    A, B = plusCourtTemps(ordrePassage, M, P)

    synthèse(B, P, M, ordrePassage, vDrone, vCamion, A, fname, dist)
    println("======================================================================")

return(A,B)
end


# Collecting the names of instances to solve
target = "B:/Cours/Nantes/Optimisation/TP/TSP-D/Experimentation"  # path for a standard config on windows10
dir = pwd()
TSPD("init.txt")
fnames = getfname(target)
@time callTSPD(fnames)
cd(dir)
