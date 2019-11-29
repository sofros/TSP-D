function solveNaifTSPD(ip, x, distancier, nbrNode)
    #
end

function calculTempsOperation(i::Int, j::Int, k::Int, vDrone::Float64, vTruck::Float64, distancier::Array{Float64,2})
    distCamion :: Float64 = 0
    distDrone :: Float64 = 0
    if k == 0
        for l in i:j
            distCamion += distancier[i, l]
        end
        tempsCamion = distCamion / vCamion
        tempsDrone = 0
    else
        #Calcul du dist total du camion
        for l in i:k-1
            distCamion += distancier[i, l]
        end
        distCamion += distancier[k-1,k+1]
        for l in k+1:j
            distCamion += distancier[j, l]
        end

        #println("distance camion: ", distCamion)
        tempsCamion = distCamion / vCamion
        #println("Temps du camion: ", tempsCamion)

        #Calcul dist drone
        distDrone += distancier[i,k] + distancier[k, j]
        #println("Distance Drone: ", distDrone)
        tempsDrone =  distDrone / vDrone
        #println("Temps du Drone: ", tempsDrone)
    end
    return(max(tempsDrone, tempsCamion))
end

function calculToutesOperation(distancier::Array{Float64,2}, nbrNode::Int, vDrone::Float64, vTruck::Float64)
    #tempsOp::Vector{Array{Float64,2}}
    tempsOp = []
    for k in 1:nbrNode
        println("================================\n", k, "   ==========")
        if k == 1
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:nbrNode
                for j in i+1:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, j, 0, vDrone, vTruck, distancier)
                    println("i: ", i, "  j: ", j)
                end
            end
            println(tabOp)
            #=
        elseif k == nbrNode
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:nbrNode
                for j in i+1:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, j, k, vDrone, vTruck, distancier)
                    println("i: ", i, "  j: ", j)
                end
            end
            println(tabOp)
            =#
        else
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:k-1
                for j in k+1:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, j, k, vDrone, vTruck, distancier)
                    println("i: ", i, "  j: ", j)
                end
            end
            println(tabOp)
        end
    end
end
