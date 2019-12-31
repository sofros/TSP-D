function solveNaifTSPD(ip, x, distancier, nbrNode)
    #
end

function calculTempsOperation(i::Int, j::Int, k::Int, vDrone::Float64, vTruck::Float64, distancier::Array{Float64,2})
    distCamion :: Float64 = 0
    distDrone :: Float64 = 0
    m, n = size(distancier)
    if k == 0
        for l in i:j
            distCamion += distancier[i, l]
        end
        tempsCamion = distCamion * vCamion
        tempsDrone = 0
    elseif i>j #l'opération se finie au dépôt
        #Distance de i à k-1
        for l in i:k-2
            distCamion += distancier[l, l+1]
        end
        #distance de k-1 à k+1
        if k ==  n
            distCamion += distancier[k-1,1]
        else
            distCamion += distancier[k-1,k+1]
        end
        #distance de k+1 à n
        for l in k+1:n-1
            distCamion += distancier[l, l+1]
        end
        #distance de n au dépôt
        distCamion += distancier[n,1]


        #println("distance camion: ", distCamion)
        tempsCamion = distCamion * vCamion
        #println("Temps du camion: ", tempsCamion)

        #Calcul dist drone
        distDrone += distancier[i,k] + distancier[k, j]
        #println("Distance Drone: ", distDrone)
        tempsDrone =  distDrone * vDrone
        #println("Temps du Drone: ", tempsDrone)

    else
        #distance de i à k-1
        for l in i:k-2
            distCamion += distancier[l, l+1]
        end
        #distance de k-1 à k+1
        if k ==  n
            distCamion += distancier[k-1,1]
        else
            distCamion += distancier[k-1,k+1]
        end
        #distance de k+1 à j
        for l in k+1:j-1
            distCamion += distancier[l, l+1]
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
            push!(tempsOp, tabOp)
        elseif k == nbrNode
            tabOp = fill(Inf, nbrNode, nbrNode)
            j = 1
            for i in 2:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, 1, k, vDrone, vTruck, distancier)
                    println("i: ", i, "  j: ", j)
            end
        #    println(tabOp)
        #    tabOp = transpose(tabOp)
            println(tabOp)
            push!(tempsOp, tabOp)
        else
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:k-1
                for j in k+1:nbrNode+1
                    if j == nbrNode+1
                        tabOp[i,1]= calculTempsOperation(i, 1, k, vDrone, vTruck, distancier)
                        println("i: ", i, "  j: ", j)
                    else
                        tabOp[i,j] = calculTempsOperation(i, j, k, vDrone, vTruck, distancier)
                        println("i: ", i, "  j: ", j)
                    end
                end
            end
            println(tabOp)
            push!(tempsOp, tabOp)
        end
    end
    println(typeof(tempsOp))
    return(tempsOp)
end

function calculMeilleurTemps(i::Int, j::Int, tempsOp::Array{Any,1})
    min = Inf
    valK =  0
    n , m = size(tempsOp[1])
    a = i+1
    b = j-1
    if j > n
        j = 1
    end
    for k in a:b
        if k == 10
            if tempsOp[k][1,j] < min
                min = tempsOp[k][i,j]
                valK = k
            end
        end
        println("Temps ", i,",", j,",",k,": ", tempsOp[k][i,j])
        if tempsOp[k][i,j] < min
            min = tempsOp[k][i,j]
            valK = k
        end
    end
    return(valK, min)
end

function matriceMeilleurTemps(tempsOp::Array{Any,1}, nbrNode::Int)
    M = zeros(Float64, nbrNode, nbrNode)
    P = zeros(Int, nbrNode, nbrNode)
    for i in 1:nbrNode-1
        for j in i+2:nbrNode+1
            if j == nbrNode+1
                indice, mini = calculMeilleurTemps(i, j, tempsOp)
                M[i,1] = mini
                P[i,1] = indice
            else
                indice, mini = calculMeilleurTemps(i, j, tempsOp)
                M[i,j] = mini
                P[i,j] = indice
            end
        end
    end
    return(M, P)
end


function getPosDepot(permut:: Array{Int64,1})
    cpt = 1
    stop = false
    while cpt <= length(permut) && !stop
        if permut[cpt] == 1
            stop = true
            cpt -= 1
        end
        cpt += 1
    end
    return(cpt)
end

function ordonerPerm(x)
    permut = matToPermut(x)
    pos = getPosDepot(permut)
    per1 = permut[1:pos-1]
    per2 = permut[pos: end]
    per2=vcat(per2, per1)
    push!(per2, 1)
    return(per2)
end
