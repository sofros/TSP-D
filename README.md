Projet proposé par X.Gandibleux lors de l'année universitaire 2019-2020 à ses élèves de master 1 dans le cadre de son cours d'optimisation discrète et combinatoire réaliser avec A.Przybylski à la faculté de Nantes.

====================
Utilisation du programme:
Pour utiliser le programme, il vous suffi d'ajuster dans le main le chemin d'accès au dossier "Experimentation"

Exemple d'utilisation des différentes fonctions:

f = "doublecenter-54-n10.txt"
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
