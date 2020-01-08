


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
