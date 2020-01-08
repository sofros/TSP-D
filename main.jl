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
        @time TSPD(f)
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
    tempsMin, valK = matriceMeilleurTemps(tempsOp, nbrNode)
    tempsMin, valK = voyageSimple(ordrePassage, dist, tempsMin, valK)
    V, P = meilleurSuiteOperation(ordrePassage, tempsMin, valK)

    synthèse(P, valK, tempsMin, ordrePassage, vDrone, vCamion, V, fname, dist)
    println("======================================================================")

return(V, P)
end


# Collecting the names of instances to solve
dir = pwd()
target = string(dir,"/Experimentation")  # path for a standard config on windows10
TSPD("init.txt")
fnames = getfname(target)
callTSPD(fnames)
cd(dir)
