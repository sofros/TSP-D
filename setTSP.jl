


function setTSP(ip , x)
    #Transphormation de la matrice en objet plus simple à manipulé
    permut = matToPermut(x)
    sousCyles = []

    #detection des sous Cyles
    sousCyles = getSousCyles(permut)
    println(sousCyles)
    cpt = 0
    while length(sousCyles) != 1 #&& cpt < 4
        println("=======\n Boucle: ", cpt)
        #ajout des nouvelles contraintes
        ip, x = ajoutContrainte(ip, x, sousCyles)

        #résolution du nouveau problème
        println("Solving..."); optimize!(ip)

        #detection des sous Cyles
        permut = matToPermut(x)
        sousCyles = getSousCyles(permut)
        println("Sous Cyles: ",sousCyles)
        println("permut associé: ", permut)
        #println(ip)
        cpt += 1
    end

    println("=======================")
    println("z  = ", objective_value(ip))

    return(ip, x)

end

function matToPermut(x)
    #println("x:   ",x)
    n , m = size(x)
    permut = Array{Int64,1}(undef, n)
    for i in 1:n
        for j in 1:n
            if value(x[i, j]) == 1
                permut[i] = j
            end
        end
    end
    return permut
end

function getSousCyles(permut)
    sousCyles = []
    S = deepcopy(permut)
    stop = []
    while S != stop
        i = S[1]
        sousCyleActuel = [i]
        j = permut[i]
        deleteat!(S, getPos(S,i))
        while j != i
            push!(sousCyleActuel, j)
            deleteat!(S, getPos(S,j))
            j = permut[j]
        end
        push!(sousCyles, sousCyleActuel)
    end

    return(sousCyles)
    #=
    sousCyles = []
    S = deepcopy(permut)
    stop = []
    while S != stop
        i = S[1]
#        println("i: ", i)
        sousCyleActuel = [i]
        j = permut[i]
#        println("j:  ", j)
        deleteat!(S, getPos(S,i))
        while j != i
            push!(sousCyleActuel, j)
            deleteat!(S, getPos(S,j))
            j = permut[j]
#            println("j:  ", j)
        end
        push!(sousCyles, sousCyleActuel)
#        println("sTA: ", sousCyleActuel, "   sT: ", sousCyles)
    end
    return(sousCyles)
    =#
end

function getPos(liste, x)
    i = 1
    p = 0
    while p == 0 && i <= length(liste)
        if liste[i] == x
            p = i
        end
        i += 1
    end
    return(p)
end

function ajoutContrainte(ip, x, sousCycles)
        for k in sousCycles
            expression = AffExpr(0)
            taille = length(k)
            for l in 1:taille-1
                add_to_expression!(expression, x[k[l], k[l+1]])
                add_to_expression!(expression, x[k[l+1], k[l]])
            end
            if taille > 2
                add_to_expression!(expression, x[k[1], k[end]])
                add_to_expression!(expression, x[k[end], k[1]])
            end
            @constraint(ip, expression <= taille-1)
        end
        return ip, x
end

#=
function ajoutContrainte(ip, x, sousCyles)
    println("Ajout contraites: ")
    for k in 1:length(sousCyles)
        taille = length(sousCyles[k])
        @constraint(ip , [i=sousCyles[k]], sum(x[i,j]+x[j,i] for j=sousCyles[k]) <= taille-1)
        println("contrainte ", k, " ajouté!")
    end
    return ip, x
end

=#
#=
b= [3, 4, 1, 5, 2]
b = [6, 5, 4, 3, 2, 1, 7, 8]
for i in b
    println(b[1], "  taille: ", length(b))
    popfirst!(b)
end

B:

cd Cours\Nantes\Optimisation\TP\TSP-D

julia

include("main.jl")
f = "doublecenter-54-n10.txt"
#nom, pos, dist, vDrone, vCamion, nbrNode = loadLAP("doublecenter-60-n10.txt")
nom, pos, dist, vDrone, vCamion, nbrNode = loadLAP(f)
ip, x = setLAP(1, dist)
ip, x = setTSP(ip, x)
ordrePassage = ordonerPerm(x)
#vDrone = 4.0
tempsOp = calculToutesOperation(dist, nbrNode, vDrone, vCamion, ordrePassage)
M, P = matriceMeilleurTemps(tempsOp, nbrNode)
M, P = voyageSimple(ordrePassage, dist, M, P)
A, B = plusCourtTemps(ordrePassage, M, P)
synthèse(B, P, M, ordrePassage, vDrone, vCamion, A, f)


=#
