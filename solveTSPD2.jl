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

function calculTempsOperation(i::Int, j::Int, k::Int, vDrone::Float64, vTruck::Float64, distancier::Array{Float64,2}, ordre::Array{Int64,1})
    distCamion :: Float64 = 0
    distDrone :: Float64 = 0
    m, n = size(distancier)


    if k == 0
        println("Opération:  (", ordre[i], ", ", ordre[j], ", 0)")
        #println("vCamion: ", vTruck, "   vDrone: ", vDrone)
        for l in i+1:j
            distCamion += distancier[ordre[l-1], ordre[l]]
        end
        tempsCamion = distCamion / vCamion
        tempsDrone = 0

    elseif j!=i+2   #On vérifie que l'opération n'est pas unitaire
        println("Opération:  (", ordre[i], ", ", ordre[j], ", ", ordre[k], ")")
        #println("vCamion: ", vTruck, "   vDrone: ", vDrone)
        #Distance de i à k-1
        for l in i+1:k-1
            #println("Ajout de: dist(", ordre[l-1],",", ordre[l], ")" )
            distCamion += distancier[ordre[l-1], ordre[l]]
        end
        #println("dist i->k-1(camion): ", distCamion)
        #distance de k-1 à k+1
            distCamion += distancier[ordre[k-1],ordre[k+1]]
            #println("Ajout de: dist(", ordre[k-1],",", ordre[k+1], ")" )
            #println("dist i-> k+1 / k (camion): ", distCamion)
        #distance de k+1 à j
        for l in k+2:j
            #println("Ajout de: dist(", ordre[l-1],",", ordre[l], ")" )
            distCamion += distancier[ordre[l-1], ordre[l]]
        end
        #println("dist i->j/k(camion): ", distCamion)

        #println("distance camion: ", distCamion)
        tempsCamion = distCamion / vCamion
        #println("Temps du camion: ", tempsCamion)

        #Calcul dist drone
        distDrone += distancier[ordre[i],ordre[k]] + distancier[ordre[k], ordre[j]]
        #println("Distance Drone: ", distDrone)
        tempsDrone =  distDrone / vDrone
        #println("Temps du Drone: ", tempsDrone)
    else
        println("Opération:  (", ordre[i], ", ", ordre[j], ", ", ordre[k], ")")
        #println("vCamion: ", vTruck, "   vDrone: ", vDrone)
        #distance de i à j
        distCamion += distancier[ordre[k-1],ordre[k+1]]
        #println("Calcul de: dist(", ordre[k-1],",", ordre[k+1], ")" )
        #println("dist i => j: ", distCamion)

        #println("distance camion: ", distCamion)
        tempsCamion = distCamion / vCamion
        #println("Temps du camion: ", tempsCamion)

        #Calcul dist drone
        distDrone += distancier[ordre[i],ordre[k]] + distancier[ordre[k], ordre[j]]
        #println("Distance Drone: ", distDrone)
        tempsDrone =  distDrone / vDrone
        #println("Temps du Drone: ", tempsDrone)
    end
    println("max: ", max(tempsDrone, tempsCamion))
    return(max(tempsDrone, tempsCamion))
end

function calculToutesOperation(distancier::Array{Float64,2}, nbrNode::Int, vDrone::Float64, vTruck::Float64, ordre::Array{Int64,1})
    #tempsOp::Vector{Array{Float64,2}}
    dist = hcat(distancier, distancier[1:end, 1])
    tempsOp = []
    for k in 1:nbrNode
        println("================================\n k=  ", k, "   ==========")
        if k == 1
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:nbrNode
                for j in i+1:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, j, 0, vDrone, vTruck, dist, ordre)
                    println("i: ", i, "  j: ", j)
                end
            end
            println(tabOp)
            push!(tempsOp, tabOp)
        elseif k == nbrNode
            tabOp = fill(Inf, nbrNode, nbrNode)
            j = 1
            for i in 2:nbrNode
                    tabOp[i,j] = calculTempsOperation(i, k+1, k, vDrone, vTruck, dist, ordre)
                    println("i: ", i, "  j: ", j)
            end

            println(tabOp)
            push!(tempsOp, tabOp)

        else
            tabOp = fill(Inf, nbrNode, nbrNode)
            for i in 1:k-1
                for j in k+1:nbrNode+1
                    if j == nbrNode+1
                        tabOp[i,1]= calculTempsOperation(i, j, k, vDrone, vTruck, dist, ordre)
                        println("i: ", i, "  j: ", j, "   temps: ", tabOp[i,1])
                    else
                        tabOp[i,j] = calculTempsOperation(i, j, k, vDrone, vTruck, dist, ordre)
                        println("i: ", i, "  j: ", j, "   temps: ", tabOp[i,j])
                    end
                end
            end
            println(tabOp)
            push!(tempsOp, tabOp)
        end
    end
    #println(typeof(tempsOp))
    return(tempsOp)
end

function calculMeilleurTemps(i::Int, j::Int, tempsOp::Array{Any,1})
    min = Inf
    valK =  0
    n , m = size(tempsOp[1])
    a = i+1
    b = j-1
    for k in a:b
        #if k == n
            if j == n+1 && tempsOp[k][i,1] < min
                valK = k
                min = tempsOp[k][i,1]
            elseif j != n+1 && tempsOp[k][i,j] < min
                valK = k
                min = tempsOp[k][i,j]
            end
        #= elseif j == n+1 && tempsOp[k][i,1] < min
            valK = k
            min = tempsOp[k][i,1]
        elseif j != n+1  && tempsOp[k][i,j] < min
            valK = k
            min = tempsOp[k][i,j]
        end
        =#
        if j == n+1
            println("Temps ", i,",", j,",",k,": ", tempsOp[k][i,1])
        else
            println("Temps ", i,",", j,",",k,": ", tempsOp[k][i,j])
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



    #=
    for i in 1:nbrNode-1
        for j in i+2:nbrNode+1
            if j == nbrNode+1
                indiceK, tMin = calculMeilleurTemps(i, j, tempsOp)
                tempsMin[i,1] = tMin
                valeurK[i,1] = indiceK
            else
                indiceK, tMin = calculMeilleurTemps(i, j, tempsOp)
                tempsMin[i,j] = tMin
                valeurK[i,j] = indiceK
            end
        end
    end
    =#
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

function plusCourtTemps(ordre, tempsMin, valeurK)
    # V(i) = min(k=0; k=i-1)[V(k)+T(k,i+1)]
    #V(i)= min(k=1, k=i)[V(k)+T(k,i+1)]

    V = fill(Inf, length(ordre))
    P = zeros(Int64, length(ordre))
    V[1]=0
    P[1]=1

    for i in 2:length(ordre)
        println(" ")
        valMin = Inf
        kMin = 0
        for k in 1:i-1
            if V[k] + tempsMin[k, i]  < valMin
                valMin = V[k] + tempsMin[k, i]
                kMin = k
                print("choisit           ")
            end
            println("i = ", i, "   k= ", k, "   Valeur: ", V[k] + tempsMin[k, i])
        end
        V[i] = valMin
        P[i] = kMin
    end
    #=
    for i in 2:length(V)-1
        println(" ")
        vMin = Inf
        kMin = 0
        for k in 1:i-1
            if V[k] + tempsMin[k, i] < vMin
                # V[i] = V[k] + tempsMin[k, i]
                # P[i] = k
                vMin = V[ordre[k]] + tempsMin[ordre[k], ordre[i]]
                kMin = ordre[k]
                print("choisit           ")
            end
            #=
            if V[k] + tempsMin[k, i] < V[i]
                # V[i] = V[k] + tempsMin[k, i]
                # P[i] = k

                V[i] = V[ordre[k]] + tempsMin[ordre[k], ordre[i]]
                P[i] = k
                print("choisit           ")
            end
            =#
            println("i = ", i, "   k= ", k, "   Valeur: ", V[ordre[k]] + tempsMin[ordre[k], ordre[i]])
        end
        V[i] = vMin
        P[i] = kMin
    end
    =#
    return(V, P)
end

#=

julia> M
10×10 Array{Float64,2}:
 213.835   0.0  308.857  322.873  345.209  497.116  514.732  523.874  689.581  798.366
 220.167   0.0    0.0    230.345  220.421  372.329  389.945  399.087  564.793  673.579
 129.739   0.0    0.0      0.0    152.075  303.982  321.598  330.74   496.447  578.557
 129.926   0.0    0.0      0.0      0.0    281.834  209.475  206.131  371.837  440.665
 169.523   0.0    0.0      0.0      0.0      0.0    187.139  183.795  349.501  418.329
 141.633   0.0    0.0      0.0      0.0      0.0      0.0    112.964  197.594  266.422
  93.9954  0.0    0.0      0.0      0.0      0.0      0.0      0.0    326.563  248.806
  85.8745  0.0    0.0      0.0      0.0      0.0      0.0      0.0      0.0    239.664
 145.508   0.0    0.0      0.0      0.0      0.0      0.0      0.0      0.0      0.0
   0.0     0.0    0.0      0.0      0.0      0.0      0.0      0.0      0.0      0.0

julia> P
10×10 Array{Int64,2}:
  2  0  2  3  3  3  3  3  3  9
  3  0  0  3  3  3  3  3  3  9
  4  0  0  0  4  4  4  4  4  9
  5  0  0  0  0  5  6  7  7  9
  6  0  0  0  0  0  6  7  7  9
  7  0  0  0  0  0  0  7  7  9
  9  0  0  0  0  0  0  0  8  9
  9  0  0  0  0  0  0  0  0  9
 10  0  0  0  0  0  0  0  0  0
  0  0  0  0  0  0  0  0  0  0


  Boucle: 21
 Solving...
 Nouveaux sous Cyles: Any[[2, 4, 6, 7, 3, 9, 8, 10, 5, 1]]
 permut associé: [2, 4, 9, 6, 1, 7, 3, 10, 8, 5]

 2   ==========
 i: 1  j: 3   temps: 60.505394047136555
 i: 1  j: 4   temps: 81.07362790422961


 doublecenter-60-n10.txt

 TSP:   1  9  3  4 10  2  7  5  6  8  1

 Partitionnement [1, 1, 1, 1, 3, 3, 5, 5, 7, 8, 9]
 T(6,1)  = ..., 8
 T(7,6) = ..., 5
 T(10,7)= ..., 2
 T(3,10)= ..., 4
 T(1,3) = ..., 9

 Valeur: 725.964587929057


=#
