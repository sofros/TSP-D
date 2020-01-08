function solveNaifTSPD(ip, x, distancier, nbrNode)
    #
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
    permut = getSousCyles(permut)
    #permut = matToPermut(x)
    pos = getPosDepot(permut[1])
    per1 = permut[1][1:pos-1]
    per2 = permut[1][pos: end]
    per2=vcat(per2, per1)
    push!(per2, 1)
    return(per2)
end

function calculTempsOperation(i::Int, j::Int, k::Int, vDrone::Float64, vCamion::Float64, distancier::Array{Float64,2}, ordre::Array{Int64,1})
    distCamion :: Float64 = 0
    distDrone :: Float64 = 0
    m, n = size(distancier)


    if k == 0
        for l in i+1:j
            distCamion += distancier[ordre[l-1], ordre[l]]
        end
        tempsCamion = distCamion / vCamion
        tempsDrone = 0

    elseif j!=i+2   #On vérifie que l'opération n'est pas unitaire

        #Distance de i à k-1
        for l in i+1:k-1
            distCamion += distancier[ordre[l-1], ordre[l]]
        end


        #distance de k-1 à k+1
            distCamion += distancier[ordre[k-1],ordre[k+1]]


        #distance de k+1 à j
        for l in k+2:j
            distCamion += distancier[ordre[l-1], ordre[l]]
        end

        tempsCamion = distCamion / vCamion

        #Calcul dist drone
        distDrone += distancier[ordre[i],ordre[k]] + distancier[ordre[k], ordre[j]]
        tempsDrone =  distDrone / vDrone
    else
        #distance de i à j
        distCamion += distancier[ordre[k-1],ordre[k+1]]

        tempsCamion = distCamion / vCamion

        #Calcul dist drone
        distDrone += distancier[ordre[i],ordre[k]] + distancier[ordre[k], ordre[j]]
        tempsDrone =  distDrone / vDrone
    end
    return(max(tempsDrone, tempsCamion))
end

function calculToutesOperation(distancier::Array{Float64,2}, nbrNode::Int, vDrone::Float64, vCamion::Float64, ordre::Array{Int64,1})
    dist = hcat(distancier, distancier[1:end, 1])
    tempsOp = []
    for k in 1:nbrNode
        #println("================================\n k=  ", k, "   ==========")
        if k == 1
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:nbrNode
                for j in i+1:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, j, 0, vDrone, vCamion, dist, ordre)
                end
            end
            push!(tempsOp, tabOp)
        elseif k == nbrNode
            tabOp = fill(Inf, nbrNode, nbrNode)
            j = 1
            for i in 2:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, k+1, k, vDrone, vCamion, dist, ordre)
            end
            push!(tempsOp, tabOp)

        else
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:k-1
                for j in k+1:nbrNode+1
                    if j == nbrNode+1
                        tabOp[i,1]= calculTempsOperation(i, j, k, vDrone, vCamion, dist, ordre)
                    else
                        tabOp[i,j] = calculTempsOperation(i, j, k, vDrone, vCamion, dist, ordre)
                    end
                end
            end
            push!(tempsOp, tabOp)
        end
    end
    return(tempsOp)
end

function calculMeilleurTemps(i::Int, j::Int, tempsOp::Array{Any,1})
    min = Inf
    valK =  0
    n , m = size(tempsOp[1])
    a = i+1
    b = j-1
    for k in a:b
        if j == n+1 && tempsOp[k][i,1] < min
            valK = k
            min = tempsOp[k][i,1]
        elseif j != n+1 && tempsOp[k][i,j] < min
            valK = k
            min = tempsOp[k][i,j]
        end
    end
    return(valK, min)
end

function matriceMeilleurTemps(tempsOp::Array{Any,1}, nbrNode::Int)
    tempsMin = zeros(Float64, nbrNode+1, nbrNode+1)
    valeurK = zeros(Int, nbrNode+1, nbrNode+1)

    #On cherche le temps min des opératiosn (i,j,k)
    for i in 1: nbrNode-1
        for j in i+2 : nbrNode+1
            indiceK, tMin = calculMeilleurTemps(i, j, tempsOp)
            tempsMin[i,j] = tMin
            valeurK[i,j] = indiceK
        end
    end
    return(tempsMin, valeurK)
end

function voyageSimple(ordre, distancier, tMin, valeurK)
    #On ajoute de temps de l'opération (i,i+1,-1)
    for i in 1:length(ordre)-1
        for j in 1:i
            tMin[i, i+1] += distancier[ordre[j],ordre[j+1]]
        end
    end
    return(tMin, valeurK)
end

function meilleurSuiteOperation(ordre, tempsMin, valeurK)
    # V(i) = min(k=0; k=i-1)[V(k)+T(k,i+1)]
    #V(i)= min(k=1, k=i)[V(k)+T(k,i+1)]

    V = fill(Inf, length(ordre))
    P = zeros(Int64, length(ordre))
    V[1]=0
    P[1]=0

    for i in 2:length(ordre)
        valMin = Inf
        kMin = 0
        for k in 1:i-1
            if V[k] + tempsMin[k, i]  < valMin
                valMin = V[k] + tempsMin[k, i]
                kMin = k
            end
        end
        V[i] = valMin
        P[i] = kMin
    end

    return(V, P)
end

function synthèse(P, valK, tempsMin, ordre, vDrone, vCamion, V, f, distancier)
    println("\n============================== Synthèse ==============================")
    println("==  Instace: ", f, " ==\n")
    println("======= Resolution du TSP-D avec a-ep ====")
    println("Solution TSP: ", ordre)
    tempsTSP = calculTempsOperation(1, length(ordre), 0, vDrone, vCamion, distancier, ordre)
    println("Temps TSP: ", tempsTSP)

    println("\n===== Opérations =====")
    i = P[end]
    j = length(V)
    k = valK[i,j]
    if k == 0
        println("(", ordre[i], ", ", ordre[j], ", ", 0, ") Temps: ", tempsMin[i,j])
    else
        println("(", ordre[i], ", ", ordre[j], ", ", ordre[k], ") Temps: ", tempsMin[i,j])
    end

    while i != 1
        j = i
        i = P[i]
        k = valK[i,j]
        if k == 0
            println("(", ordre[i], ", ", ordre[j], ", ", 0, ") Temps: ", tempsMin[i,j])
        else
            println("(", ordre[i], ", ", ordre[j], ", ", ordre[k], ") Temps: ", tempsMin[i,j])
        end
    end

    println("\n Temps total aep-TSPD: ", V[end])

    println("\n===== Paramètres =====")
    println("v(Drone) = ", vDrone, "   v(Camion) = ", vCamion, "\n")

end
