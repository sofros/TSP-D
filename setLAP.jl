using JuMP, GLPKMathProgInterface, GLPK


# --------------------------------------------------------------------------- #

# Setting an ip model of SPP
function setLAP(solverSelected, distancier)
  m, n = size(distancier)
  ip = Model( with_optimizer(GLPK.Optimizer) )
  @variable(ip, x[1:n, 1:n], Bin)
  @objective(ip, Min, sum(x[i,j]*distancier[i,j] for j=1:n, i=1:n))
  @constraint(ip , cte1[i=1:m], sum(x[i,j] for j=1:n) == 1)
  @constraint(ip , cte2[j=1:m], sum(x[i,j] for i=1:n) == 1)
  @constraint(ip , cte3[j=1:m], sum(x[i,i] for i=1:n) == 0)

    #solving
    println("Solving..."); optimize!(ip)

    # Displaying the results
    println("z  = ", objective_value(ip))

  return ip, x
end
