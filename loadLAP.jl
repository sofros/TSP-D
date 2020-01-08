

# --------------------------------------------------------------------------- #
# Loading an instance of SPP (format: OR-library)

function loadLAP(fname)
    f=open(fname)

    # lecture de la vitesse du camion
    readline(f)
    vitesseCamion = parse(Float64, readline(f) )
    vitesseCamion = 1/vitesseCamion

    # lecture de la vitesse du drone
    readline(f)
    vitesseDrone = parse(Float64, readline(f) )
    vitesseDrone = 1/vitesseDrone

    # lecture du nombre de nodes
    readline(f)
    nbrNode =  parse(Int64, readline(f))
    #lecture de la position  et du noms des points
    noms = String[]
    position = Tuple{Float64,Float64}[]
    readline(f)
        #Depot
        x, y, nom = split(readline(f))
        x = parse(Float64,x)
        y = parse(Float64,y)
        push!(position, (x, y))
        nom = String(nom)
        push!(noms, nom)

        #others
        readline(f)
        for i in 2:nbrNode
            x, y, nom = split(readline(f))
            x = parse(Float64,x)
            y = parse(Float64,y)
            push!(position, (x, y))
            nom = String(nom)
            push!(noms, nom)
        end

    distancier = calculDistancier(position)
    return(noms, position, distancier, vitesseDrone, vitesseCamion, nbrNode)
end


function calculDistancier(pos::Array{Tuple{Float64,Float64},1})
    taille = length(pos)
    distancier = Matrix{Float64}(undef,taille, taille)
    for i in 1:taille
        for j in 1:taille
            distancier[i,j] = sqrt((pos[i][1]-pos[j][1])^2 + (pos[i][2]-pos[j][2])^2)
        end
    end
    return(distancier)
end
